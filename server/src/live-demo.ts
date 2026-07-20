import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

import { BudgetGuard, budgetConfigFromEnv } from './openai/budget-guard.js';
import { CostLedger } from './openai/cost-ledger.js';
import { LiveReasoningPipeline } from './openai/live-reasoning-pipeline.js';
import { MultiAgentAuditOrchestrator } from './openai/multi-agent-audit.js';
import { PatchOrchestrator } from './openai/patch-orchestrator.js';
import { ProgrammaticSimulationOrchestrator } from './openai/programmatic-simulation.js';
import { HttpResponsesTransport } from './openai/responses-transport.js';

function rootRunId(): string {
  return `LIVE-${new Date().toISOString().replace(/[-:.TZ]/g, '')}-${Math.random().toString(36).slice(2, 8)}`;
}

function safeErrorCode(error: unknown): string {
  if (error && typeof error === 'object' && 'code' in error && typeof (error as { code?: unknown }).code === 'string') {
    return (error as { code: string }).code;
  }
  return error instanceof Error ? error.name : 'unknown_error';
}

async function saveEvidence(name: string, value: unknown): Promise<string> {
  const directory = process.env.OPENAI_EVIDENCE_DIR ?? 'probes/results';
  await mkdir(directory, { recursive: true });
  const path = join(directory, name);
  await writeFile(path, `${JSON.stringify(value, null, 2)}\n`, { encoding: 'utf8', mode: 0o600, flag: 'wx' });
  return path;
}

async function main(): Promise<void> {
  const runId = rootRunId();
  const ledger = new CostLedger(process.env.OPENAI_COST_LEDGER_PATH ?? 'server/runtime/openai-cost-ledger.jsonl');
  const budget = new BudgetGuard(ledger, budgetConfigFromEnv());
  const transport = new HttpResponsesTransport();
  const pipeline = new LiveReasoningPipeline(
    new PatchOrchestrator(transport, budget),
    new ProgrammaticSimulationOrchestrator(transport, budget),
    new MultiAgentAuditOrchestrator(transport, budget),
  );
  try {
    const result = await pipeline.run(runId);
    const path = await saveEvidence(`${runId}.json`, {
      status: 'passed',
      recordedAt: new Date().toISOString(),
      rootRunId: runId,
      responseIds: [result.patchResponseId, result.programmaticResponseId, result.auditResponseId],
      patchVersion: result.patch.version,
      passedPathways: result.simulation.passedPathways,
      pathwayCount: result.simulation.pathwayCount,
      passedAssertions: result.simulation.passedAssertions,
      assertionCount: result.simulation.assertionCount,
      exactRollbackVerified: result.exactRollbackVerified,
      approvalBlockers: result.approval.blockers,
      finalCommitAllowed: false,
    });
    process.stdout.write(`${JSON.stringify({ status: 'passed', runId, evidencePath: path })}\n`);
  } catch (error) {
    const code = safeErrorCode(error);
    const path = await saveEvidence(`${runId}-failed.json`, {
      status: 'failed', recordedAt: new Date().toISOString(), rootRunId: runId, code,
      finalCommitAllowed: false,
    });
    process.stderr.write(`${JSON.stringify({ status: 'failed', runId, code, evidencePath: path })}\n`);
    process.exitCode = 1;
  }
}

await main();
