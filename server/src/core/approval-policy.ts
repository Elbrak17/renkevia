import type {
  ApprovalGateDecision,
  ApprovalGateInput,
  ReviewRole,
} from '../domain/types.js';

export function evaluateApprovalGate(input: ApprovalGateInput): ApprovalGateDecision {
  const blockers: string[] = [];
  const requiredTestIds = new Set(input.patch.validationPlan.requiredTestIds);
  const observedPathways = new Map(
    input.simulation.results.map((result) => [result.pathwayId, result]),
  );

  for (const testId of requiredTestIds) {
    const result = observedPathways.get(testId);
    if (!result) blockers.push(`TEST_MISSING:${testId}`);
    else if (!result.passed) blockers.push(`TEST_FAILED:${testId}`);
  }
  if (input.simulation.failedAssertions > 0) {
    blockers.push(`ASSERTIONS_FAILED:${input.simulation.failedAssertions}`);
  }

  const reviewsByRole = new Map<ReviewRole, typeof input.reviews>();
  for (const role of input.patch.validationPlan.requiredReviews) reviewsByRole.set(role, []);
  for (const review of input.reviews) {
    const roleReviews = reviewsByRole.get(review.role);
    if (roleReviews) roleReviews.push(review);
  }
  for (const [role, reviews] of reviewsByRole) {
    if (reviews.length === 0 || reviews.every((review) => !review.completed)) {
      blockers.push(`REVIEW_MISSING:${role}`);
    }
  }
  for (const finding of input.reviews) {
    if (finding.completed && finding.blocking && finding.disposition === 'open') {
      blockers.push(`DISSENT_OPEN:${finding.id}`);
    }
  }

  if (input.provenanceCoverage !== 100) {
    blockers.push(`PROVENANCE_INCOMPLETE:${input.provenanceCoverage}`);
  }
  for (const evidenceId of input.unresolvedEvidenceIds) {
    blockers.push(`EVIDENCE_UNRESOLVED:${evidenceId}`);
  }
  if (input.patch.validationPlan.requireExactRollback && !input.exactRollbackVerified) {
    blockers.push('ROLLBACK_UNVERIFIED');
  }
  if (
    input.patch.validationPlan.requireLegacyVisualProof &&
    !input.legacyVisualProofVerified
  ) {
    blockers.push('LEGACY_VISUAL_PROOF_MISSING');
  }

  return {
    approvalControlEnabled: blockers.length === 0,
    // The hackathon prototype may expose a human approval control, but it never
    // authorizes or performs a final legacy-system write.
    finalCommitAllowed: false,
    blockers,
  };
}
