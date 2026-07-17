import { assertProbe, createResponse, runLiveProbe, usageSummary } from './probe-kit.mjs';

const stablePolicyPrefix = Array.from(
  { length: 360 },
  (_, index) =>
    `Synthetic policy clause ${String(index + 1).padStart(3, '0')}: every material patch mutation requires source evidence, deterministic tests, rollback, and human approval.`,
).join('\n');

function request(question) {
  return {
    model: 'gpt-5.6-luna',
    reasoning: { effort: 'low' },
    store: false,
    prompt_cache_key: 'renkevia:probe:synthetic-policy-v1',
    prompt_cache_options: {
      mode: 'explicit',
      ttl: '30m',
    },
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: stablePolicyPrefix,
            prompt_cache_breakpoint: { mode: 'explicit' },
          },
          {
            type: 'input_text',
            text: question,
          },
        ],
      },
    ],
    max_output_tokens: 64,
  };
}

await runLiveProbe('explicit-prompt-cache', async () => {
  const first = await createResponse(request('Return exactly CACHE_WRITE_PROBE.'));
  const second = await createResponse(request('Return exactly CACHE_READ_PROBE.'));
  const firstUsage = usageSummary(first.payload);
  const secondUsage = usageSummary(second.payload);

  assertProbe((firstUsage.cacheWriteTokens || 0) > 0, 'The first request reported no explicit cache write.', {
    firstUsage,
  });
  assertProbe((secondUsage.cachedTokens || 0) > 0, 'The second request reported no cache read.', {
    secondUsage,
  });

  return {
    model: second.payload.model,
    requestIds: [first.requestId, second.requestId],
    firstUsage,
    secondUsage,
    breakpointMode: 'explicit',
    ttl: '30m',
  };
});

