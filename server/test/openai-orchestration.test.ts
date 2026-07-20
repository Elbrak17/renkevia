import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

import { compilePatch } from '../src/core/patch-compiler.js';
import { runSimulation } from '../src/core/simulation-engine.js';
import { revisedPatchV08, northstarBaseline, syntheticPathways } from '../src/fixtures/northstar.js';
import { syntheticCorpus } from '../src/fixtures/corpus.js';
import { BudgetGuard, OpenAIBudgetError, actualUsageUsd, estimateWorstCaseUsd } from '../src/openai/budget-guard.js';
import { ComputerUseStagingOrchestrator, type ComputerActionExecutor } from '../src/openai/computer-use-staging.js';
import { CostLedger } from '../src/openai/cost-ledger.js';
import { routeModel } from '../src/openai/model-router.js';
import { MultiAgentAuditOrchestrator } from '../src/openai/multi-agent-audit.js';
import { PatchOrchestrator } from '../src/openai/patch-orchestrator.js';
import { ProgrammaticSimulationOrchestrator } from '../src/openai/programmatic-simulation.js';
import { HttpResponsesTransport, OpenAITransportError } from '../src/openai/responses-transport.js';
import type { ResponsesApiResponse, ResponsesRequest, ResponsesTransport } from '../src/openai/types.js';

class QueueTransport implements ResponsesTransport {
  readonly requests: Array<{ request: ResponsesRequest; beta?: string }> = [];
  constructor(private readonly responses: ResponsesApiResponse[]) {}
  async create(request: ResponsesRequest, options: { beta?: string } = {}): Promise<ResponsesApiResponse> {
    this.requests.push({ request, beta: options.beta });
    const next = this.responses.shift();
    if (!next) throw new Error('Unexpected transport call.');
    return next;
  }
}

async function liveBudget(name: string): Promise<BudgetGuard> {
  const directory = await mkdtemp(join(tmpdir(), `renkevia-${name}-`));
  return new BudgetGuard(new CostLedger(join(directory, 'ledger.jsonl')), {
    liveEnabled: true, apiKeyPresent: true, runLimitUsd: 1.5, totalLimitUsd: 5,
  });
}

const lowUsage = { input_tokens: 1_000, output_tokens: 200, input_tokens_details: { cached_tokens: 500 } };

test('model routing uses the whole family only where consequence and cost justify it', () => {
  assert.equal(routeModel('classify').model, 'gpt-5.6-luna');
  assert.equal(routeModel('extract').model, 'gpt-5.6-terra');
  assert.deepEqual([routeModel('patch').model, routeModel('patch').reasoning], ['gpt-5.6-sol', 'max']);
});

test('budget rejects disabled live mode before any network call', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'renkevia-budget-off-'));
  const transport = new QueueTransport([]);
  const orchestrator = new PatchOrchestrator(transport, new BudgetGuard(new CostLedger(join(directory, 'ledger.jsonl')), {
    liveEnabled: false, apiKeyPresent: true, runLimitUsd: 2, totalLimitUsd: 5,
  }));
  await assert.rejects(
    orchestrator.synthesize({ runId: 'RUN-OFF', incidentId: revisedPatchV08.incidentId, corpus: syntheticCorpus, baseline: northstarBaseline }),
    (error: unknown) => error instanceof OpenAIBudgetError && error.code === 'live_disabled',
  );
  assert.equal(transport.requests.length, 0);
});

test('cost estimates are conservative and cached usage is settled at the lower rate', () => {
  assert.equal(estimateWorstCaseUsd('gpt-5.6-sol', { maxInputTokens: 120_000, maxOutputTokens: 12_000 }), 0.96);
  assert.equal(actualUsageUsd('gpt-5.6-sol', lowUsage), 0.00875);
});

test('append-only cost ledger detects tampering and unknown billing retains reservation', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'renkevia-ledger-'));
  const path = join(directory, 'ledger.jsonl');
  const ledger = new CostLedger(path);
  await ledger.append({ runId: 'R1', model: 'gpt-5.6-sol', state: 'reserved', reservedUsd: 0.5 });
  await ledger.append({ runId: 'R1', model: 'gpt-5.6-sol', state: 'unknown', reservedUsd: 0.5 });
  assert.equal(await ledger.committedUsd(), 0.5);
  const source = await readFile(path, 'utf8');
  await writeFile(path, source.replace('unknown', 'settled'));
  await assert.rejects(ledger.entries(), /integrity/);
});

test('HTTP transport sends the key server-side and sanitizes upstream error text', async () => {
  let authorization = '';
  const transport = new HttpResponsesTransport({
    apiKey: 'secret-test-key',
    fetchImpl: async (_url, init) => {
      authorization = new Headers(init?.headers).get('authorization') ?? '';
      return new Response(JSON.stringify({ error: { code: 'insufficient_quota', message: 'do not leak me' } }), {
        status: 429, headers: { 'content-type': 'application/json', 'x-request-id': 'req_safe' },
      });
    },
  });
  await assert.rejects(
    transport.create({ model: 'gpt-5.6-sol', input: 'x' }),
    (error: unknown) => error instanceof OpenAITransportError && error.requestId === 'req_safe' && !error.message.includes('do not leak me'),
  );
  assert.equal(authorization, 'Bearer secret-test-key');
});

test('Sol proposal remains untrusted until schema, provenance and deterministic compilation pass', async () => {
  const transport = new QueueTransport([{ id: 'resp_patch', output_text: JSON.stringify(revisedPatchV08), usage: lowUsage }]);
  const result = await new PatchOrchestrator(transport, await liveBudget('patch')).synthesize({
    runId: 'RUN-PATCH', incidentId: revisedPatchV08.incidentId, corpus: syntheticCorpus, baseline: northstarBaseline,
  });
  assert.equal(result.compiledDiffs, 12);
  assert.equal(result.provenanceCoverage, 100);
  assert.equal(transport.requests[0]?.request.model, 'gpt-5.6-sol');
  assert.equal((transport.requests[0]?.request.reasoning as { effort: string }).effort, 'max');
  assert.equal(transport.requests[0]?.request.store, false);
  assert.ok(transport.requests[0]?.request.prompt_cache_key);
});

test('Patch orchestrator rejects a schema-valid proposal for the wrong incident', async () => {
  const patch = structuredClone(revisedPatchV08);
  patch.incidentId = 'INC-OTHER';
  const transport = new QueueTransport([{ id: 'resp_wrong', output_text: JSON.stringify(patch), usage: lowUsage }]);
  await assert.rejects(
    new PatchOrchestrator(transport, await liveBudget('wrong-incident')).synthesize({
      runId: 'RUN-WRONG', incidentId: revisedPatchV08.incidentId, corpus: syntheticCorpus, baseline: northstarBaseline,
    }),
    /incident boundary/,
  );
});

test('hosted program must call every deterministic pathway exactly once and matches core report', async () => {
  const calls = syntheticPathways.map((pathway, index) => ({
    type: 'function_call', name: 'run_patient_pathway', call_id: `call_${index}`,
    caller: { type: 'program', id: 'program_1' }, arguments: JSON.stringify({ pathwayId: pathway.id }),
  }));
  const transport = new QueueTransport([
    { id: 'resp_program_1', output: calls, usage: lowUsage },
    { id: 'resp_program_2', output: [{ type: 'message', content: [{ type: 'output_text', text: '{"done":true}' }] }], usage: lowUsage },
  ]);
  const compiled = compilePatch(northstarBaseline, revisedPatchV08);
  const result = await new ProgrammaticSimulationOrchestrator(transport, await liveBudget('program')).run({
    runId: 'RUN-PROGRAM', compiled, pathways: syntheticPathways,
  });
  assert.deepEqual(result.report, runSimulation(compiled, syntheticPathways));
  assert.equal(result.invokedPathwayIds.length, 24);
  const tools = transport.requests[0]?.request.tools ?? [];
  assert.ok(tools.some((tool) => tool.type === 'programmatic_tool_calling'));
  assert.deepEqual(tools[0]?.allowed_callers, ['programmatic']);
});

test('programmatic simulation rejects duplicate calls instead of hiding them in aggregation', async () => {
  const pathwayId = syntheticPathways[0]!.id;
  const call = { type: 'function_call', name: 'run_patient_pathway', caller: { type: 'program' }, arguments: JSON.stringify({ pathwayId }) };
  const transport = new QueueTransport([{ id: 'resp_dup', output: [{ ...call, call_id: 'a' }, { ...call, call_id: 'b' }], usage: lowUsage }]);
  await assert.rejects(
    new ProgrammaticSimulationOrchestrator(transport, await liveBudget('duplicate')).run({
      runId: 'RUN-DUP', compiled: compilePatch(northstarBaseline, revisedPatchV08), pathways: syntheticPathways,
    }),
    /duplicate pathway/,
  );
});

function reviews(blocking = false) {
  return [
    { id: 'PHARM-1', role: 'pharmacy', completed: true, verdict: 'agree', blocking: false, disposition: 'accepted', evidenceRefs: ['SRC-002'] },
    { id: 'LEGACY-1', role: 'clinical_informatics', completed: true, verdict: blocking ? 'dissent' : 'conditional', blocking, disposition: blocking ? 'open' : 'resolved', evidenceRefs: ['SRC-009'] },
    { id: 'PED-1', role: 'pediatric_safety', completed: true, verdict: 'agree', blocking: false, disposition: 'accepted', evidenceRefs: ['SRC-006'] },
    { id: 'ADV-1', role: 'adversarial_auditor', completed: true, verdict: 'conditional', blocking: false, disposition: 'resolved', evidenceRefs: ['SRC-001'] },
  ];
}

test('native Multi-agent audit requires four independent specialists and beta contract', async () => {
  const payload = { reviewTraces: ['pharmacy', 'clinical_informatics', 'pediatric_safety', 'adversarial_auditor'], reviews: reviews(), rootVerdict: 'accept' };
  const transport = new QueueTransport([{ id: 'resp_agents', output_text: JSON.stringify(payload), usage: lowUsage }]);
  const result = await new MultiAgentAuditOrchestrator(transport, await liveBudget('agents')).run({
    runId: 'RUN-AGENTS', patch: revisedPatchV08, simulation: runSimulation(compilePatch(northstarBaseline, revisedPatchV08), syntheticPathways),
  });
  assert.equal(result.reviews.length, 4);
  assert.equal(transport.requests[0]?.beta, 'responses_multi_agent=v1');
  assert.deepEqual(transport.requests[0]?.request.multi_agent, { enabled: true, max_concurrent_subagents: 4 });
});

test('root compiler cannot erase open specialist dissent', async () => {
  const payload = { reviewTraces: ['pharmacy', 'clinical_informatics', 'pediatric_safety', 'adversarial_auditor'], reviews: reviews(true), rootVerdict: 'accept' };
  const transport = new QueueTransport([{ id: 'resp_dissent', output_text: JSON.stringify(payload), usage: lowUsage }]);
  await assert.rejects(
    new MultiAgentAuditOrchestrator(transport, await liveBudget('dissent')).run({
      runId: 'RUN-DISSENT', patch: revisedPatchV08, simulation: runSimulation(compilePatch(northstarBaseline, revisedPatchV08), syntheticPathways),
    }),
    /unresolved blocking finding/,
  );
});

test('Computer Use is screenshot-first and intercepts final commit for human approval', async () => {
  const events: string[] = [];
  const executor: ComputerActionExecutor = {
    async currentOrigin() { events.push('origin'); return 'http://127.0.0.1:9191'; },
    async screenshot() { events.push('screenshot'); return 'data:image/png;base64,cHJvb2Y='; },
    async apply(action) { events.push(`apply:${String(action.type)}`); },
    async isFinalCommitTarget(action) { return action.target === 'final-commit'; },
  };
  const transport = new QueueTransport([{
    id: 'resp_computer', usage: lowUsage,
    output: [{ type: 'computer_call', call_id: 'computer_1', actions: [
      { type: 'click', target: 'edit' }, { type: 'click', target: 'final-commit' },
    ] }],
  }]);
  const result = await new ComputerUseStagingOrchestrator(
    transport, await liveBudget('computer'), executor, 'http://127.0.0.1:9191',
  ).run({ runId: 'RUN-COMPUTER', patchSummary: { patchId: revisedPatchV08.patchId } });
  assert.equal(result.status, 'awaiting_human_approval');
  assert.equal(result.finalCommitExecuted, false);
  assert.equal(result.actionCount, 1);
  assert.deepEqual(events.slice(0, 2), ['origin', 'screenshot']);
  assert.ok(!events.includes('apply:final-commit'));
});

test('Computer Use rejects an origin outside the isolated Northstar allow-list before network', async () => {
  const transport = new QueueTransport([]);
  const executor: ComputerActionExecutor = {
    async currentOrigin() { return 'https://external.example'; }, async screenshot() { return 'x'; },
    async apply() {}, async isFinalCommitTarget() { return false; },
  };
  await assert.rejects(
    new ComputerUseStagingOrchestrator(transport, await liveBudget('origin'), executor, 'http://127.0.0.1:9191').run({ runId: 'RUN-ORIGIN', patchSummary: {} }),
    /allow-listed/,
  );
  assert.equal(transport.requests.length, 0);
});
