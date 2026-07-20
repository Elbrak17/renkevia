import { evaluateApprovalGate } from '../core/approval-policy.js';
import { compilePatch, provenanceCoverage, rollbackCompiledPatch } from '../core/patch-compiler.js';
import { runSimulation } from '../core/simulation-engine.js';
import type { ApprovalGateDecision, PatchIR, ReviewFinding, SimulationReport } from '../domain/types.js';
import { candidatePatchV07, northstarBaseline, syntheticPathways } from '../fixtures/northstar.js';
import { syntheticCorpus } from '../fixtures/corpus.js';
import type { PatchSynthesisResult, ProgrammaticSimulationResult, SpecialistAuditResult } from './types.js';

export interface PatchStage {
  synthesize(input: Parameters<import('./patch-orchestrator.js').PatchOrchestrator['synthesize']>[0]): Promise<PatchSynthesisResult>;
}

export interface ProgrammaticStage {
  run(input: Parameters<import('./programmatic-simulation.js').ProgrammaticSimulationOrchestrator['run']>[0]): Promise<ProgrammaticSimulationResult>;
}

export interface AuditStage {
  run(input: Parameters<import('./multi-agent-audit.js').MultiAgentAuditOrchestrator['run']>[0]): Promise<SpecialistAuditResult>;
}

export interface LiveReasoningPipelineResult {
  rootRunId: string;
  synthetic: true;
  patch: PatchIR;
  patchResponseId: string;
  programmaticResponseId: string;
  auditResponseId: string;
  simulation: SimulationReport;
  reviews: ReviewFinding[];
  exactRollbackVerified: boolean;
  approval: ApprovalGateDecision;
  status: 'awaiting_legacy_visual_proof';
  finalCommitAllowed: false;
}

export class LiveReasoningPipeline {
  constructor(
    private readonly patchStage: PatchStage,
    private readonly programmaticStage: ProgrammaticStage,
    private readonly auditStage: AuditStage,
  ) {}

  async run(rootRunId: string): Promise<LiveReasoningPipelineResult> {
    const candidateCompiled = compilePatch(northstarBaseline, candidatePatchV07);
    const candidateSimulation = runSimulation(candidateCompiled, syntheticPathways);
    const proposal = await this.patchStage.synthesize({
      runId: `${rootRunId}:patch`,
      incidentId: candidatePatchV07.incidentId,
      corpus: syntheticCorpus,
      baseline: northstarBaseline,
      challenge: {
        candidatePatch: candidatePatchV07,
        failedAssertions: candidateSimulation.results
          .flatMap((result) => result.assertions)
          .filter((assertion) => !assertion.passed),
        instruction: 'Produce a revised Patch IR that resolves the hidden failure without weakening rollback or approval requirements.',
      },
    });
    if (proposal.patch.status !== 'revised') throw new Error('Live root compiler did not produce a revised Patch IR.');
    const compiled = compilePatch(northstarBaseline, proposal.patch);
    const programmatic = await this.programmaticStage.run({
      runId: `${rootRunId}:programmatic`,
      compiled,
      pathways: syntheticPathways,
    });
    const softwareSimulation = runSimulation(compiled, syntheticPathways);
    if (JSON.stringify(programmatic.report) !== JSON.stringify(softwareSimulation)) {
      throw new Error('Programmatic aggregate diverged from the deterministic simulation core.');
    }
    const rollback = rollbackCompiledPatch(compiled);
    if (!rollback.exact) throw new Error('Live Patch IR failed exact rollback verification.');
    const audit = await this.auditStage.run({
      runId: `${rootRunId}:multi-agent`,
      patch: proposal.patch,
      simulation: programmatic.report,
    });
    const approval = evaluateApprovalGate({
      patch: proposal.patch,
      simulation: programmatic.report,
      reviews: audit.reviews,
      provenanceCoverage: provenanceCoverage(compiled),
      exactRollbackVerified: rollback.exact,
      legacyVisualProofVerified: false,
      unresolvedEvidenceIds: [],
    });
    if (approval.finalCommitAllowed) throw new Error('Approval policy violated the no-final-commit invariant.');
    return {
      rootRunId,
      synthetic: true,
      patch: proposal.patch,
      patchResponseId: proposal.responseId,
      programmaticResponseId: programmatic.responseId,
      auditResponseId: audit.responseId,
      simulation: programmatic.report,
      reviews: audit.reviews,
      exactRollbackVerified: rollback.exact,
      approval,
      status: 'awaiting_legacy_visual_proof',
      finalCommitAllowed: false,
    };
  }
}
