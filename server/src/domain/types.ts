export type Scalar = string | number | boolean | null;

export type ArtifactType =
  | 'policy'
  | 'order_set'
  | 'pump_library'
  | 'label'
  | 'communication'
  | 'legacy_staging';

export type ReviewRole =
  | 'pharmacy'
  | 'clinical_informatics'
  | 'pediatric_safety'
  | 'adversarial_auditor';

export interface EvidenceReference {
  id: string;
  artifactId: string;
  region: string;
  checksum: string;
}

export interface CorpusRegion {
  sourceId: string;
  locator: string;
  syntheticContent: string;
  checksum: string;
}

export interface EvidenceArtifactManifest {
  id: string;
  name: string;
  mediaType: 'text/plain' | 'text/csv' | 'application/json' | 'image/png';
  synthetic: true;
  trust: 'untrusted_input';
  regions: CorpusRegion[];
}

export interface PatchPrecondition {
  id: string;
  description: string;
  evidenceRefs: string[];
}

export interface MutationTarget {
  artifactId: string;
  artifactType: ArtifactType;
  fieldPath: string;
  expectedBefore: Scalar;
  proposedAfter: Scalar;
}

export interface PatchMutation {
  id: string;
  intent: string;
  operation: 'replace';
  targets: MutationTarget[];
  evidenceRefs: string[];
}

export interface PopulationException {
  id: string;
  population: 'synthetic_pediatric';
  predicate: string;
  mutationId: string;
  evidenceRefs: string[];
  testIds: string[];
}

export interface ValidationPlan {
  requiredTestIds: string[];
  requiredReviews: ReviewRole[];
  requireExactRollback: true;
  requireLegacyVisualProof: true;
}

export interface ApprovalRequirement {
  role: ReviewRole;
  required: true;
  state: 'pending' | 'approved' | 'rejected';
}

export interface RollbackAction {
  id: string;
  mutationId: string;
  artifactId: string;
  fieldPath: string;
  restoreValue: Scalar;
  expectedPatchedValue: Scalar;
}

export interface PatchIR {
  schemaVersion: 'renkevia.patch-ir/v1';
  patchId: string;
  version: string;
  incidentId: string;
  synthetic: true;
  status: 'candidate' | 'revised';
  sourceEvidence: EvidenceReference[];
  preconditions: PatchPrecondition[];
  mutations: PatchMutation[];
  exceptions: PopulationException[];
  validationPlan: ValidationPlan;
  approvals: ApprovalRequirement[];
  rollback: RollbackAction[];
}

export interface InstitutionArtifact {
  id: string;
  type: ArtifactType;
  fields: Record<string, Scalar | Record<string, Scalar>>;
}

export interface InstitutionState {
  fixtureId: string;
  synthetic: true;
  artifacts: InstitutionArtifact[];
}

export interface ArtifactDiff {
  mutationId: string;
  artifactId: string;
  artifactType: ArtifactType;
  fieldPath: string;
  before: Scalar;
  after: Scalar;
  evidenceRefs: string[];
}

export interface CompiledPatch {
  patchId: string;
  patchVersion: string;
  status: 'complete' | 'partial';
  beforeStateHash: string;
  candidateStateHash: string;
  state: InstitutionState;
  diffs: ArtifactDiff[];
  appliedTargetCount: number;
  totalTargetCount: number;
  patch: PatchIR;
}

export type AssertionSpec =
  | {
      id: string;
      kind: 'field_equals';
      artifactId: string;
      fieldPath: string;
      expected: Scalar;
    }
  | {
      id: string;
      kind: 'field_matches';
      leftArtifactId: string;
      rightArtifactId: string;
      fieldPath: string;
    }
  | {
      id: string;
      kind: 'diff_supported';
      artifactId: string;
      fieldPath: string;
    }
  | {
      id: string;
      kind: 'rollback_declared';
      artifactId: string;
      fieldPath: string;
    };

export interface PatientPathway {
  id: string;
  suiteId: string;
  name: string;
  population: 'synthetic_adult' | 'synthetic_pediatric' | 'system';
  assertions: AssertionSpec[];
}

export interface AssertionResult {
  id: string;
  pathwayId: string;
  passed: boolean;
  expected: string;
  actual: string;
}

export interface PathwayResult {
  pathwayId: string;
  suiteId: string;
  passed: boolean;
  assertions: AssertionResult[];
}

export interface SimulationReport {
  patchVersion: string;
  pathwayCount: number;
  passedPathways: number;
  failedPathways: number;
  assertionCount: number;
  passedAssertions: number;
  failedAssertions: number;
  results: PathwayResult[];
}

export interface ReviewFinding {
  id: string;
  role: ReviewRole;
  completed: boolean;
  verdict: 'agree' | 'conditional' | 'dissent';
  blocking: boolean;
  disposition: 'open' | 'resolved' | 'accepted';
  evidenceRefs: string[];
}

export interface ApprovalGateInput {
  patch: PatchIR;
  simulation: SimulationReport;
  reviews: ReviewFinding[];
  provenanceCoverage: number;
  exactRollbackVerified: boolean;
  legacyVisualProofVerified: boolean;
  unresolvedEvidenceIds: string[];
}

export interface ApprovalGateDecision {
  approvalControlEnabled: boolean;
  finalCommitAllowed: false;
  blockers: string[];
}

export interface AuditEvent {
  id: string;
  runId: string;
  sequence: number;
  timestamp: string;
  actor: string;
  action: string;
  inputHash: string;
  outputHash: string;
  previousEventHash: string;
  eventHash: string;
}
