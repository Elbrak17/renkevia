import { BudgetGuard, budgetConfigFromEnv } from './budget-guard.js';
import { CostLedger } from './cost-ledger.js';
import { LiveReasoningPipeline } from './live-reasoning-pipeline.js';
import { MultiAgentAuditOrchestrator } from './multi-agent-audit.js';
import { PatchOrchestrator } from './patch-orchestrator.js';
import { ProgrammaticSimulationOrchestrator } from './programmatic-simulation.js';
import { HttpResponsesTransport } from './responses-transport.js';

export function createLiveRunId(): string {
  return `LIVE-${new Date().toISOString().replace(/[-:.TZ]/g, '')}-${Math.random().toString(36).slice(2, 8)}`;
}

export function createLiveReasoningPipeline(env: NodeJS.ProcessEnv = process.env): LiveReasoningPipeline {
  const ledger = new CostLedger(env.OPENAI_COST_LEDGER_PATH ?? 'server/runtime/openai-cost-ledger.jsonl');
  const budget = new BudgetGuard(ledger, budgetConfigFromEnv(env));
  const transport = new HttpResponsesTransport({ apiKey: env.OPENAI_API_KEY, baseUrl: env.OPENAI_BASE_URL });
  return new LiveReasoningPipeline(
    new PatchOrchestrator(transport, budget),
    new ProgrammaticSimulationOrchestrator(transport, budget),
    new MultiAgentAuditOrchestrator(transport, budget),
  );
}
