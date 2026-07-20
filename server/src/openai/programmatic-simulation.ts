import { runPathway } from '../core/simulation-engine.js';
import type { CompiledPatch, PatientPathway, PathwayResult, SimulationReport } from '../domain/types.js';
import { BudgetGuard } from './budget-guard.js';
import { routeModel } from './model-router.js';
import type { ProgrammaticSimulationResult, ResponsesApiResponse, ResponsesTransport, ResponsesUsage, TokenCeiling } from './types.js';

const maxTurns = 4;
const ceiling: TokenCeiling = { maxInputTokens: 160_000, maxOutputTokens: 16_000 };

function callsFrom(response: ResponsesApiResponse): Array<Record<string, unknown>> {
  return (response.output ?? []).filter((item) => item.type === 'function_call');
}

function hasMessage(response: ResponsesApiResponse): boolean {
  return (response.output ?? []).some((item) => item.type === 'message');
}

function totalUsage(items: ResponsesUsage[]): ResponsesUsage {
  return items.reduce<ResponsesUsage>((sum, usage) => ({
    input_tokens: (sum.input_tokens ?? 0) + (usage.input_tokens ?? 0),
    output_tokens: (sum.output_tokens ?? 0) + (usage.output_tokens ?? 0),
    input_tokens_details: {
      cached_tokens: (sum.input_tokens_details?.cached_tokens ?? 0) + (usage.input_tokens_details?.cached_tokens ?? 0),
    },
  }), {});
}

function aggregate(patchVersion: string, results: PathwayResult[]): SimulationReport {
  const assertions = results.flatMap((result) => result.assertions);
  const passedPathways = results.filter((result) => result.passed).length;
  const passedAssertions = assertions.filter((assertion) => assertion.passed).length;
  return {
    patchVersion,
    pathwayCount: results.length,
    passedPathways,
    failedPathways: results.length - passedPathways,
    assertionCount: assertions.length,
    passedAssertions,
    failedAssertions: assertions.length - passedAssertions,
    results,
  };
}

export class ProgrammaticSimulationOrchestrator {
  constructor(
    private readonly transport: ResponsesTransport,
    private readonly budget: BudgetGuard,
  ) {}

  async run(input: {
    runId: string;
    compiled: CompiledPatch;
    pathways: PatientPathway[];
  }): Promise<ProgrammaticSimulationResult> {
    if (!input.compiled.state.synthetic) throw new Error('Programmatic simulation is synthetic-only.');
    const route = routeModel('programmatic_simulation');
    const reserved = await this.budget.reserve(input.runId, route.model, ceiling);
    const usage: ResponsesUsage[] = [];
    const invoked = new Set<string>();
    const results = new Map<string, PathwayResult>();
    const pathwayById = new Map(input.pathways.map((pathway) => [pathway.id, pathway]));
    const tools: Array<Record<string, unknown>> = [
      {
        type: 'function',
        name: 'run_patient_pathway',
        description: 'Run exactly one deterministic synthetic patient pathway.',
        strict: true,
        parameters: {
          type: 'object', additionalProperties: false, required: ['pathwayId'],
          properties: { pathwayId: { type: 'string', enum: input.pathways.map((pathway) => pathway.id) } },
        },
        output_schema: {
          type: 'object', additionalProperties: false, required: ['pathwayId', 'passed', 'failedAssertionIds'],
          properties: {
            pathwayId: { type: 'string' }, passed: { type: 'boolean' },
            failedAssertionIds: { type: 'array', items: { type: 'string' } },
          },
        },
        allowed_callers: ['programmatic'],
      },
      { type: 'programmatic_tool_calling' },
    ];
    const history: unknown[] = [{
      role: 'user',
      content: `Use one isolated JavaScript program to call run_patient_pathway once for each of these ${input.pathways.length} IDs, in parallel where possible. Return only aggregate counts and anomalies: ${JSON.stringify([...pathwayById.keys()])}`,
    }];
    let response: ResponsesApiResponse | undefined;
    let received = false;
    try {
      for (let turn = 0; turn < maxTurns; turn += 1) {
        response = await this.transport.create({
          model: route.model,
          store: false,
          reasoning: { effort: route.reasoning },
          max_output_tokens: route.maxOutputTokens,
          input: history,
          tools,
        });
        received = true;
        usage.push(response.usage ?? {});
        history.push(...(response.output ?? []));
        const calls = callsFrom(response);
        if (!calls.length && hasMessage(response)) break;
        if (!calls.length) continue;
        for (const call of calls) {
          if (call.name !== 'run_patient_pathway') throw new Error('Program requested an unknown tool.');
          const caller = call.caller as { type?: unknown } | undefined;
          if (caller?.type !== 'program') throw new Error('Patient tools may only be called by a hosted program.');
          const args = JSON.parse(String(call.arguments ?? '{}')) as { pathwayId?: string };
          const pathway = args.pathwayId ? pathwayById.get(args.pathwayId) : undefined;
          if (!pathway || invoked.has(pathway.id)) throw new Error('Program emitted an unknown or duplicate pathway call.');
          invoked.add(pathway.id);
          const result = runPathway(input.compiled, pathway);
          results.set(pathway.id, result);
          history.push({
            type: 'function_call_output',
            call_id: call.call_id,
            caller: call.caller,
            output: JSON.stringify({
              pathwayId: pathway.id,
              passed: result.passed,
              failedAssertionIds: result.assertions.filter((item) => !item.passed).map((item) => item.id),
            }),
          });
        }
      }
      await this.budget.settle(input.runId, route.model, reserved, totalUsage(usage), ceiling);
      if (!response || !hasMessage(response)) throw new Error('Programmatic simulation did not reach a final message.');
      if (invoked.size !== input.pathways.length) throw new Error(`Program ran ${invoked.size}/${input.pathways.length} pathways.`);
      const ordered = input.pathways.map((pathway) => results.get(pathway.id)!);
      return { responseId: response.id, report: aggregate(input.compiled.patchVersion, ordered), invokedPathwayIds: [...invoked] };
    } catch (error) {
      if (!received) await this.budget.retainUnknown(input.runId, route.model, reserved);
      throw error;
    }
  }
}
