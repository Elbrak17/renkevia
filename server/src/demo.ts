import {
  AuditLedger,
  compilePatch,
  evaluateApprovalGate,
  provenanceCoverage,
  rollbackCompiledPatch,
  runSimulation,
} from './index.js';
import {
  candidatePatchV07,
  northstarBaseline,
  revisedPatchV08,
  specialistReviewFixture,
  syntheticPathways,
} from './fixtures/northstar.js';

const candidate = compilePatch(northstarBaseline, candidatePatchV07);
const candidateReport = runSimulation(candidate, syntheticPathways);
const revised = compilePatch(northstarBaseline, revisedPatchV08);
const revisedReport = runSimulation(revised, syntheticPathways);
const rollback = rollbackCompiledPatch(revised);
const approval = evaluateApprovalGate({
  patch: revisedPatchV08,
  simulation: revisedReport,
  reviews: specialistReviewFixture(true),
  provenanceCoverage: provenanceCoverage(revised),
  exactRollbackVerified: rollback.exact,
  legacyVisualProofVerified: true,
  unresolvedEvidenceIds: [],
});

const ledger = new AuditLedger('RUN-24-0717-A');
ledger.append({
  timestamp: '2026-07-18T14:02:11.084Z',
  actor: 'patch-compiler',
  action: 'compiled candidate v0.7',
  input: northstarBaseline,
  output: candidate,
});
ledger.append({
  timestamp: '2026-07-18T14:02:11.112Z',
  actor: 'simulation-core',
  action: 'detected hidden pediatric failure',
  input: candidate,
  output: candidateReport,
});
ledger.append({
  timestamp: '2026-07-18T14:02:12.004Z',
  actor: 'patch-compiler',
  action: 'compiled revised v0.8',
  input: candidateReport,
  output: revised,
});
ledger.append({
  timestamp: '2026-07-18T14:02:12.230Z',
  actor: 'approval-policy',
  action: 'evaluated human approval gate',
  input: revisedReport,
  output: approval,
});

console.log(
  JSON.stringify(
    {
      synthetic: true,
      candidate: {
        patchVersion: candidate.patchVersion,
        projections: candidate.diffs.length,
        passedPathways: candidateReport.passedPathways,
        passedAssertions: candidateReport.passedAssertions,
        failingAssertions: candidateReport.results
          .flatMap((result) => result.assertions)
          .filter((assertion) => !assertion.passed)
          .map((assertion) => assertion.id),
      },
      revised: {
        patchVersion: revised.patchVersion,
        projections: revised.diffs.length,
        passedPathways: revisedReport.passedPathways,
        passedAssertions: revisedReport.passedAssertions,
        provenanceCoverage: provenanceCoverage(revised),
      },
      rollback: {
        exact: rollback.exact,
        revertedTargets: rollback.revertedTargetCount,
      },
      approval: {
        controlEnabled: approval.approvalControlEnabled,
        finalCommitAllowed: approval.finalCommitAllowed,
      },
      audit: {
        events: ledger.entries().length,
        chainValid: ledger.verify(),
      },
    },
    null,
    2,
  ),
);
