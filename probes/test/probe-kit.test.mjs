import assert from 'node:assert/strict';
import test from 'node:test';

import {
  assertProbe,
  extractOutputText,
  ProbeError,
  usageSummary,
} from '../src/probe-kit.mjs';

test('extractOutputText prefers the top-level convenience field', () => {
  assert.equal(
    extractOutputText({ output_text: 'RENKEVIA_OK', output: [] }),
    'RENKEVIA_OK',
  );
});

test('extractOutputText joins output_text parts from message items', () => {
  const response = {
    output: [
      { type: 'reasoning' },
      {
        type: 'message',
        content: [
          { type: 'output_text', text: 'RENKE' },
          { type: 'refusal', refusal: 'ignored' },
          { type: 'output_text', text: 'VIA' },
        ],
      },
    ],
  };
  assert.equal(extractOutputText(response), 'RENKEVIA');
});

test('usageSummary exposes only the counters needed by sanitized evidence', () => {
  assert.deepEqual(
    usageSummary({
      usage: {
        input_tokens: 1200,
        output_tokens: 10,
        input_tokens_details: {
          cached_tokens: 1024,
          cache_write_tokens: 0,
          sensitive_provider_field: 'must not escape',
        },
      },
    }),
    {
      inputTokens: 1200,
      outputTokens: 10,
      cachedTokens: 1024,
      cacheWriteTokens: 0,
    },
  );
});

test('assertProbe throws a typed error without embedding response content', () => {
  assert.throws(
    () => assertProbe(false, 'contract failed', { kind: 'test_contract', count: 2 }),
    (error) => {
      assert.ok(error instanceof ProbeError);
      assert.equal(error.message, 'contract failed');
      assert.deepEqual(error.details, { kind: 'test_contract', count: 2 });
      return true;
    },
  );
});

