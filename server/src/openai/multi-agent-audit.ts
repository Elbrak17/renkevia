import type { PatchIR, ReviewFinding, ReviewRole, SimulationReport } from '../domain/types.js';
import { BudgetGuard } from './budget-guard.js';
import { routeModel } from './model-router.js';
import { OpenAIProtocolError } from './response-utils.js';
import type { ResponsesApiResponse, ResponsesTransport, SpecialistAuditResult, TokenCeiling } from './types.js';

const roles: ReviewRole[] = ['pharmacy', 'clinical_informatics', 'pediatric_safety', 'adversarial_auditor'];
const ceiling: TokenCeiling = { maxInputTokens: 180_000, maxOutputTokens: 10_000 };

const auditSchema = {
  type: 'object', additionalProperties: false,
  required: ['reviewTraces', 'reviews', 'rootVerdict'],
  properties: {
    reviewTraces: { type: 'array', minItems: 4, maxItems: 4, uniqueItems: true, items: { type: 'string', enum: roles } },
    rootVerdict: { type: 'string', enum: ['accept', 'revise'] },
    reviews: {
      type: 'array', minItems: 4, maxItems: 4,
      items: {
        type: 'object', additionalProperties: false,
        required: ['id', 'role', 'completed', 'verdict', 'blocking', 'disposition', 'evidenceRefs'],
        properties: {
          id: { type: 'string' }, role: { type: 'string', enum: roles }, completed: { const: true },
          verdict: { type: 'string', enum: ['agree', 'conditional', 'dissent'] },
          blocking: { type: 'boolean' }, disposition: { type: 'string', enum: ['open', 'resolved', 'accepted'] },
          evidenceRefs: { type: 'array', minItems: 1, items: { type: 'string' } },
        },
      },
    },
  },
} as const;

function rootFinalText(response: ResponsesApiResponse): string {
  if (response.output_text?.trim()) return response.output_text;
  for (const item of response.output ?? []) {
    const agent = item.agent as { agent_name?: unknown } | undefined;
    if (item.type !== 'message' || agent?.agent_name !== '/root' || item.phase !== 'final_answer') continue;
    const content = item.content;
    if (!Array.isArray(content)) continue;
    const text = content.map((part) => part && typeof part === 'object' ? (part as { text?: unknown }).text : '').filter((part): part is string => typeof part === 'string').join('');
    if (text) return text;
  }
  throw new OpenAIProtocolError('Multi-agent response contained no root final answer.', response.id);
}

function validateAudit(value: unknown, evidenceIds: Set<string>): Omit<SpecialistAuditResult, 'responseId'> {
  if (!value || typeof value !== 'object') throw new Error('Specialist audit was not an object.');
  const candidate = value as { reviewTraces?: unknown; reviews?: unknown; rootVerdict?: unknown };
  const reviewTraces = Array.isArray(candidate.reviewTraces) ? candidate.reviewTraces : [];
  if (reviewTraces.length !== 4 || new Set(reviewTraces).size !== 4 || roles.some((role) => !reviewTraces.includes(role))) {
    throw new Error('Specialist audit must contain exactly four independent role traces.');
  }
  if (!Array.isArray(candidate.reviews) || candidate.reviews.length !== 4) throw new Error('Specialist audit must contain four reviews.');
  const reviews = candidate.reviews as ReviewFinding[];
  if (new Set(reviews.map((review) => review.role)).size !== 4 || roles.some((role) => !reviews.some((review) => review.role === role))) {
    throw new Error('Specialist audit roles were incomplete or duplicated.');
  }
  for (const review of reviews) {
    if (!review.completed || !review.id || !review.evidenceRefs?.length || review.evidenceRefs.some((id) => !evidenceIds.has(id))) {
      throw new Error(`Specialist review ${review.id || '<unknown>'} lacked valid evidence.`);
    }
  }
  if (candidate.rootVerdict !== 'accept' && candidate.rootVerdict !== 'revise') throw new Error('Root verdict was invalid.');
  const mustRevise = reviews.some((review) => review.blocking && review.disposition === 'open');
  if (mustRevise && candidate.rootVerdict !== 'revise') throw new Error('Root compiler tried to accept an unresolved blocking finding.');
  return { reviews, rootVerdict: candidate.rootVerdict };
}

export class MultiAgentAuditOrchestrator {
  constructor(
    private readonly transport: ResponsesTransport,
    private readonly budget: BudgetGuard,
  ) {}

  async run(input: { runId: string; patch: PatchIR; simulation: SimulationReport }): Promise<SpecialistAuditResult> {
    const route = routeModel('multi_agent_audit');
    const reserved = await this.budget.reserve(input.runId, route.model, ceiling);
    let received = false;
    try {
      const response = await this.transport.create({
        model: route.model,
        store: false,
        reasoning: { effort: route.reasoning },
        max_output_tokens: route.maxOutputTokens,
        multi_agent: { enabled: true, max_concurrent_subagents: 4 },
        input: [
          { role: 'developer', content: 'Proactive Multi-agent delegation is active for exactly four independent bounded reviews. Spawn pharmacy, clinical_informatics, pediatric_safety, and adversarial_auditor agents. Preserve disagreement. The root synthesizes evidence-linked findings but cannot approve or write.' },
          { role: 'user', content: JSON.stringify({ patch: input.patch, simulation: input.simulation }) },
        ],
        text: { format: { type: 'json_schema', name: 'renkevia_specialist_audit', strict: true, schema: auditSchema } },
      }, { beta: 'responses_multi_agent=v1' });
      received = true;
      await this.budget.settle(input.runId, route.model, reserved, response.usage, ceiling);
      const value = JSON.parse(rootFinalText(response)) as unknown;
      return { responseId: response.id, ...validateAudit(value, new Set(input.patch.sourceEvidence.map((item) => item.id))) };
    } catch (error) {
      if (!received) await this.budget.retainUnknown(input.runId, route.model, reserved);
      throw error;
    }
  }
}
