import { assertProbe, createResponse, extractOutputText, runLiveProbe, usageSummary } from './probe-kit.mjs';

const implementations = {
  run_pathway_test: async ({ testId }) => {
    const results = {
      'PT-ADULT-01': { testId: 'PT-ADULT-01', passed: true, severity: 'critical' },
      'PT-PED-07': { testId: 'PT-PED-07', passed: false, severity: 'critical' },
    };
    return results[testId] || { testId, passed: false, severity: 'unknown' };
  },
};

const tools = [
  {
    type: 'function',
    name: 'run_pathway_test',
    description: 'Run one deterministic synthetic RENKEVIA patient-pathway test.',
    parameters: {
      type: 'object',
      properties: {
        testId: { type: 'string', enum: ['PT-ADULT-01', 'PT-PED-07'] },
      },
      required: ['testId'],
      additionalProperties: false,
    },
    output_schema: {
      type: 'object',
      properties: {
        testId: { type: 'string' },
        passed: { type: 'boolean' },
        severity: { type: 'string' },
      },
      required: ['testId', 'passed', 'severity'],
      additionalProperties: false,
    },
    allowed_callers: ['programmatic'],
  },
  { type: 'programmatic_tool_calling' },
];

await runLiveProbe('programmatic-tool-calling', async () => {
  const input = [
    {
      role: 'user',
      content:
        'Use Programmatic Tool Calling and only run_pathway_test. Run PT-ADULT-01 and PT-PED-07 concurrently. ' +
        'Filter out passing tests inside the program. The program must emit exactly one JSON object with ' +
        'suite="renkevia_probe", failing as an array of failed test IDs, and blockingCount as the number of failures. ' +
        'Do not call either tool directly.',
    },
  ];

  let programSeen = false;
  let programOutput;
  let programmaticFunctionCalls = 0;
  let lastResponse;
  const requestIds = [];

  for (let turn = 0; turn < 8; turn += 1) {
    const result = await createResponse({
      model: 'gpt-5.6-sol',
      reasoning: { effort: 'low' },
      store: false,
      input,
      tools,
      max_output_tokens: 1024,
    });
    lastResponse = result.payload;
    requestIds.push(result.requestId);
    assertProbe(lastResponse.status === 'completed', 'Programmatic response did not complete.', {
      responseStatus: lastResponse.status,
    });

    input.push(...lastResponse.output);
    for (const item of lastResponse.output) {
      if (item.type === 'program') programSeen = true;
      if (item.type === 'program_output') programOutput = item.result;
    }

    const calls = lastResponse.output.filter((item) => item.type === 'function_call');
    if (calls.length > 0) {
      const outputs = await Promise.all(calls.map(async (call) => {
        assertProbe(call.caller?.type === 'program', 'A probe function was called outside the hosted program.', {
          toolName: call.name,
        });
        const implementation = implementations[call.name];
        assertProbe(Boolean(implementation), 'The model requested an unknown probe tool.', { toolName: call.name });
        programmaticFunctionCalls += 1;
        const value = await implementation(JSON.parse(call.arguments));
        return {
          type: 'function_call_output',
          call_id: call.call_id,
          caller: call.caller,
          output: JSON.stringify(value),
        };
      }));
      input.push(...outputs);
      continue;
    }

    const finalMessage = lastResponse.output.some((item) => item.type === 'message');
    if (finalMessage) break;
  }

  assertProbe(programSeen, 'No hosted program item was observed.');
  assertProbe(programmaticFunctionCalls === 2, 'The hosted program did not call exactly two pathway tests.', {
    programmaticFunctionCalls,
  });
  assertProbe(typeof programOutput === 'string', 'No program_output result was observed.');
  const aggregate = JSON.parse(programOutput);
  assertProbe(aggregate.suite === 'renkevia_probe', 'The program returned the wrong suite.');
  assertProbe(aggregate.blockingCount === 1, 'The program returned the wrong blocking count.');
  assertProbe(
    Array.isArray(aggregate.failing) && aggregate.failing.length === 1 && aggregate.failing[0] === 'PT-PED-07',
    'The program did not reduce the deterministic results to the expected anomaly.',
  );
  assertProbe(extractOutputText(lastResponse).length > 0, 'The programmatic loop did not reach a final message.');

  return {
    model: lastResponse.model,
    requestIds,
    programSeen,
    programmaticFunctionCalls,
    aggregate,
    usage: usageSummary(lastResponse),
  };
});

