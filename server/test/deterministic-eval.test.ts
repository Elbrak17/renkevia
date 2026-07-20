import assert from 'node:assert/strict';
import test from 'node:test';

import { runDeterministicRobustnessSuite } from '../src/evals/deterministic-robustness.js';

test('the versioned twelve-scenario robustness suite passes without network access', () => {
  const report = runDeterministicRobustnessSuite();

  assert.equal(report.synthetic, true);
  assert.equal(report.scenarioCount, 12);
  assert.equal(report.passed, 12);
  assert.equal(report.failed, 0);
  assert.ok(report.results.every((scenario) => scenario.observed.length > 0));
});
