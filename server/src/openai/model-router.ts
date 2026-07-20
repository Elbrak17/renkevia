import { OPENAI_MODELS, type ModelRoute } from './types.js';

const routes: Record<ModelRoute['purpose'], ModelRoute> = {
  classify: { model: OPENAI_MODELS.luna, reasoning: 'low', purpose: 'classify', maxOutputTokens: 900 },
  extract: { model: OPENAI_MODELS.terra, reasoning: 'medium', purpose: 'extract', maxOutputTokens: 2_500 },
  communications: { model: OPENAI_MODELS.terra, reasoning: 'medium', purpose: 'communications', maxOutputTokens: 2_000 },
  patch: { model: OPENAI_MODELS.sol, reasoning: 'max', purpose: 'patch', maxOutputTokens: 12_000 },
  programmatic_simulation: { model: OPENAI_MODELS.sol, reasoning: 'high', purpose: 'programmatic_simulation', maxOutputTokens: 4_000 },
  multi_agent_audit: { model: OPENAI_MODELS.sol, reasoning: 'max', purpose: 'multi_agent_audit', maxOutputTokens: 10_000 },
  computer_use: { model: OPENAI_MODELS.sol, reasoning: 'high', purpose: 'computer_use', maxOutputTokens: 1_024 },
};

export function routeModel(purpose: ModelRoute['purpose']): ModelRoute {
  return { ...routes[purpose] };
}
