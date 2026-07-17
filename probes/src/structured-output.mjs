import { assertProbe, createResponse, extractOutputText, runLiveProbe, usageSummary } from './probe-kit.mjs';

await runLiveProbe('structured-output', async () => {
  const { payload, requestId } = await createResponse({
    model: 'gpt-5.6-luna',
    reasoning: { effort: 'low' },
    store: false,
    input: [
      {
        role: 'system',
        content: 'Extract only the supplied synthetic incident metadata. Never infer missing fields.',
      },
      {
        role: 'user',
        content: 'Incident RK-001 affects the order_set artifact. Severity is blocking.',
      },
    ],
    text: {
      format: {
        type: 'json_schema',
        name: 'renkevia_incident_probe',
        strict: true,
        schema: {
          type: 'object',
          properties: {
            incidentId: { type: 'string' },
            artifactType: { type: 'string', enum: ['order_set', 'policy', 'pump_library'] },
            severity: { type: 'string', enum: ['informational', 'warning', 'blocking'] },
          },
          required: ['incidentId', 'artifactType', 'severity'],
          additionalProperties: false,
        },
      },
    },
    max_output_tokens: 256,
  });

  const parsed = JSON.parse(extractOutputText(payload));
  assertProbe(parsed.incidentId === 'RK-001', 'Structured output changed the incident ID.');
  assertProbe(parsed.artifactType === 'order_set', 'Structured output changed the artifact type.');
  assertProbe(parsed.severity === 'blocking', 'Structured output changed the severity.');

  return {
    model: payload.model,
    requestId,
    schema: 'renkevia_incident_probe',
    assertionCount: 3,
    usage: usageSummary(payload),
  };
});

