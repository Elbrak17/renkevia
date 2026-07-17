import { assertProbe, createResponse, runLiveProbe, usageSummary } from './probe-kit.mjs';

await runLiveProbe('computer-use-handshake', async () => {
  const { payload, requestId } = await createResponse({
    model: 'gpt-5.6-sol',
    store: false,
    tools: [{ type: 'computer' }],
    input:
      'This is a capability handshake for an isolated fictional EHR browser. ' +
      'Use the computer tool. Your first and only action on this turn must be to request a screenshot. ' +
      'Do not click, type, navigate, authenticate, or perform any write.',
    max_output_tokens: 256,
  });

  const computerCalls = (payload.output || []).filter((item) => item.type === 'computer_call');
  assertProbe(computerCalls.length === 1, 'The response did not contain exactly one computer_call.', {
    computerCallCount: computerCalls.length,
  });
  const actions = computerCalls[0].actions || [];
  assertProbe(actions.length === 1 && actions[0].type === 'screenshot', 'The first Computer Use action was not screenshot-only.', {
    actionTypes: actions.map((action) => action.type),
  });

  return {
    model: payload.model,
    requestId,
    tool: 'computer',
    actionTypes: actions.map((action) => action.type),
    browserActionsExecuted: 0,
    usage: usageSummary(payload),
  };
});

