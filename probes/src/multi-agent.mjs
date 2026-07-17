import { assertProbe, createResponse, extractOutputText, runLiveProbe, usageSummary } from './probe-kit.mjs';

await runLiveProbe('multi-agent', async () => {
  const { payload, requestId } = await createResponse({
    model: 'gpt-5.6-sol',
    reasoning: { effort: 'low' },
    store: false,
    multi_agent: {
      enabled: true,
      max_concurrent_subagents: 2,
    },
    input:
      'This is a synthetic software-review probe. You must spawn exactly two independent subagents: ' +
      'one checks whether the rule "approval is disabled when tests fail" is preserved; the other checks ' +
      'whether "rollback restores the original hash" is testable. Give each a bounded task, wait for both, ' +
      'then return a short root synthesis. Do not invent medical guidance.',
    max_output_tokens: 1024,
  }, {
    beta: 'responses_multi_agent=v1',
    timeoutMs: 180_000,
  });

  const output = payload.output || [];
  const agentNames = new Set(
    output
      .map((item) => item?.agent?.agent_name)
      .filter((name) => typeof name === 'string' && name !== '/root'),
  );
  const multiAgentCalls = output.filter((item) => item.type === 'multi_agent_call').length;
  const rootText = output
    .filter((item) => item.type === 'message' && item?.agent?.agent_name === '/root')
    .flatMap((item) => item.content || [])
    .filter((part) => part.type === 'output_text')
    .map((part) => part.text)
    .join('') || extractOutputText(payload);

  assertProbe(agentNames.size >= 2 || multiAgentCalls >= 2, 'The response did not prove two hosted subagent workstreams.', {
    observedAgentCount: agentNames.size,
    multiAgentCalls,
  });
  assertProbe(rootText.length > 0, 'The root agent did not return a final synthesis.');

  return {
    model: payload.model,
    requestId,
    observedAgentCount: agentNames.size,
    multiAgentCalls,
    rootSynthesisPresent: true,
    usage: usageSummary(payload),
    beta: 'responses_multi_agent=v1',
  };
});

