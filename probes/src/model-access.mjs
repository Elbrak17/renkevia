import { assertProbe, createResponse, extractOutputText, MODELS, runLiveProbe, usageSummary } from './probe-kit.mjs';

await runLiveProbe('model-access', async () => {
  const results = [];
  for (const model of MODELS) {
    const { payload, requestId } = await createResponse({
      model,
      input: 'Return exactly RENKEVIA_OK and nothing else.',
      reasoning: { effort: 'low' },
      max_output_tokens: 64,
      store: false,
    });
    const output = extractOutputText(payload).trim();
    assertProbe(output === 'RENKEVIA_OK', `${model} did not return the expected access token.`, {
      model,
      responseStatus: payload.status,
    });
    results.push({ model, requestId, responseStatus: payload.status, usage: usageSummary(payload) });
  }
  return { models: results };
});

