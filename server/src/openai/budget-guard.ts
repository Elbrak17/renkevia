import { CostLedger } from './cost-ledger.js';
import { normalizedUsage } from './response-utils.js';
import type { OpenAIModel, ResponsesUsage, TokenCeiling } from './types.js';

const prices: Record<OpenAIModel, { input: number; cachedInput: number; output: number }> = {
  'gpt-5.6-luna': { input: 1, cachedInput: 0.1, output: 6 },
  'gpt-5.6-terra': { input: 2.5, cachedInput: 0.25, output: 15 },
  'gpt-5.6-sol': { input: 5, cachedInput: 0.5, output: 30 },
};

function money(value: number): number {
  return Math.ceil(value * 1_000_000) / 1_000_000;
}

export function estimateWorstCaseUsd(model: OpenAIModel, ceiling: TokenCeiling): number {
  const rate = prices[model];
  return money((ceiling.maxInputTokens * rate.input + ceiling.maxOutputTokens * rate.output) / 1_000_000);
}

export function actualUsageUsd(model: OpenAIModel, usage?: ResponsesUsage): number {
  const normalized = normalizedUsage(usage);
  const cached = Math.min(normalized.input_tokens, normalized.input_tokens_details.cached_tokens);
  const uncached = normalized.input_tokens - cached;
  const rate = prices[model];
  return money((uncached * rate.input + cached * rate.cachedInput + normalized.output_tokens * rate.output) / 1_000_000);
}

export class OpenAIBudgetError extends Error {
  constructor(readonly code: 'live_disabled' | 'missing_key' | 'run_limit' | 'total_limit' | 'usage_limit') {
    super(`OpenAI execution blocked: ${code}.`);
    this.name = 'OpenAIBudgetError';
  }
}

export interface BudgetConfig {
  liveEnabled: boolean;
  apiKeyPresent: boolean;
  runLimitUsd: number;
  totalLimitUsd: number;
}

export function budgetConfigFromEnv(env: NodeJS.ProcessEnv = process.env): BudgetConfig {
  return {
    liveEnabled: env.LIVE_OPENAI_ENABLED === 'true',
    apiKeyPresent: Boolean(env.OPENAI_API_KEY),
    runLimitUsd: Number(env.OPENAI_RUN_BUDGET_USD ?? '1.50'),
    totalLimitUsd: Number(env.OPENAI_TOTAL_BUDGET_USD ?? '5.00'),
  };
}

export class BudgetGuard {
  constructor(
    readonly ledger: CostLedger,
    readonly config: BudgetConfig = budgetConfigFromEnv(),
  ) {}

  async reserve(runId: string, model: OpenAIModel, ceiling: TokenCeiling): Promise<number> {
    if (!this.config.liveEnabled) throw new OpenAIBudgetError('live_disabled');
    if (!this.config.apiKeyPresent) throw new OpenAIBudgetError('missing_key');
    const reservedUsd = estimateWorstCaseUsd(model, ceiling);
    if (reservedUsd > this.config.runLimitUsd) throw new OpenAIBudgetError('run_limit');
    if ((await this.ledger.committedUsd()) + reservedUsd > this.config.totalLimitUsd) {
      throw new OpenAIBudgetError('total_limit');
    }
    await this.ledger.append({ runId, model, state: 'reserved', reservedUsd });
    return reservedUsd;
  }

  async settle(
    runId: string,
    model: OpenAIModel,
    reservedUsd: number,
    usage: ResponsesUsage | undefined,
    ceiling: TokenCeiling,
  ): Promise<number> {
    const normalized = normalizedUsage(usage);
    const actualUsd = actualUsageUsd(model, usage);
    await this.ledger.append({ runId, model, state: 'settled', reservedUsd, actualUsd, usage });
    if (normalized.input_tokens > ceiling.maxInputTokens || normalized.output_tokens > ceiling.maxOutputTokens) {
      throw new OpenAIBudgetError('usage_limit');
    }
    return actualUsd;
  }

  async retainUnknown(runId: string, model: OpenAIModel, reservedUsd: number): Promise<void> {
    await this.ledger.append({ runId, model, state: 'unknown', reservedUsd });
  }
}
