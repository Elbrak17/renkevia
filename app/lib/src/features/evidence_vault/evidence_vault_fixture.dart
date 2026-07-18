enum EvidenceVaultRunState { ready, reviewing, sealed }

enum VaultLedgerView { provenance, rollback, auditLog }

enum ReviewVerdict { agree, conditional, dissent }

class SpecialistReview {
  const SpecialistReview({
    required this.id,
    required this.role,
    required this.scope,
    required this.findingId,
    required this.verdict,
    required this.finding,
    required this.evidenceIds,
    required this.inputHash,
    required this.disposition,
    this.isBlocking = false,
  });

  final String id;
  final String role;
  final String scope;
  final String findingId;
  final ReviewVerdict verdict;
  final String finding;
  final List<String> evidenceIds;
  final String inputHash;
  final String disposition;
  final bool isBlocking;
}

class ProvenanceRecord {
  const ProvenanceRecord({
    required this.artifactId,
    required this.artifact,
    required this.mutationId,
    required this.sourceId,
    required this.region,
    required this.claimHash,
  });

  final String artifactId;
  final String artifact;
  final String mutationId;
  final String sourceId;
  final String region;
  final String claimHash;
}

class RollbackRecord {
  const RollbackRecord({
    required this.artifactId,
    required this.beforeHash,
    required this.candidateHash,
    required this.restoredHash,
  });

  final String artifactId;
  final String beforeHash;
  final String candidateHash;
  final String restoredHash;

  bool get isExact => beforeHash == restoredHash;
}

class VaultAuditEvent {
  const VaultAuditEvent({
    required this.id,
    required this.time,
    required this.actor,
    required this.action,
    required this.inputHash,
    required this.outputHash,
  });

  final String id;
  final String time;
  final String actor;
  final String action;
  final String inputHash;
  final String outputHash;
}

const specialistReviews = <SpecialistReview>[
  SpecialistReview(
    id: 'pharmacy',
    role: 'Pharmacy reviewer',
    scope: 'Formulation and protocol coherence',
    findingId: 'PHARM-04',
    verdict: ReviewVerdict.agree,
    finding:
        'The v0.8 Patch IR keeps the synthetic formulation identity consistent across policy, label, and communications.',
    evidenceIds: ['SRC-002#P4', 'SRC-008#R12', 'MUT-01'],
    inputHash: 'CTX-71C0A4',
    disposition:
        'Accepted without mutation. Independent evidence set retained.',
  ),
  SpecialistReview(
    id: 'clinical-informatics',
    role: 'Clinical informatics',
    scope: 'Order set, pump, and legacy compatibility',
    findingId: 'LEGACY-01',
    verdict: ReviewVerdict.dissent,
    finding:
        'Structured parity is proven, but the no-API legacy screen state cannot be inferred from exports. Require visual staging proof before approval.',
    evidenceIds: ['EHR-OS-014', 'PUMP-LIB-092', 'MUT-02'],
    inputHash: 'CTX-39BB18',
    disposition:
        'Preserved as a blocking precondition. The root compiler cannot overwrite or downgrade it.',
    isBlocking: true,
  ),
  SpecialistReview(
    id: 'pediatric-safety',
    role: 'Pediatric safety',
    scope: 'Population exceptions and hidden assumptions',
    findingId: 'PED-07',
    verdict: ReviewVerdict.agree,
    finding:
        'The population-scoped exception is source-linked, present in all six projections, and covered by PATH-PED-07-04.',
    evidenceIds: ['SRC-006#T3:C7', 'MUT-02', 'PATH-PED-07-04'],
    inputHash: 'CTX-A82F06',
    disposition:
        'Accepted with the original v0.7 failure retained in the audit bundle.',
  ),
  SpecialistReview(
    id: 'adversarial-auditor',
    role: 'Adversarial auditor',
    scope: 'Missing dependencies and reversibility',
    findingId: 'RBK-02',
    verdict: ReviewVerdict.conditional,
    finding:
        'A complete rollback is insufficient unless a partially staged run restores the same sealed pre-patch hash set.',
    evidenceIds: ['RBK-01', 'RBK-02', 'FIXTURE-8D4A'],
    inputHash: 'CTX-D041F2',
    disposition:
        'Condition satisfied by deterministic partial-stage rollback; challenge remains inspectable.',
  ),
];

const provenanceRecords = <ProvenanceRecord>[
  ProvenanceRecord(
    artifactId: 'POL-IV-006',
    artifact: 'Policy',
    mutationId: 'MUT-01',
    sourceId: 'SRC-002',
    region: 'P4:L18–27',
    claimHash: 'CLM-8A71',
  ),
  ProvenanceRecord(
    artifactId: 'EHR-OS-014',
    artifact: 'Order set',
    mutationId: 'MUT-02',
    sourceId: 'SRC-006',
    region: 'T3:C7',
    claimHash: 'CLM-20F6',
  ),
  ProvenanceRecord(
    artifactId: 'PUMP-LIB-092',
    artifact: 'Pump library',
    mutationId: 'MUT-02',
    sourceId: 'SRC-006',
    region: 'T3:C7',
    claimHash: 'CLM-69BD',
  ),
  ProvenanceRecord(
    artifactId: 'LBL-IV-021',
    artifact: 'Label',
    mutationId: 'MUT-02',
    sourceId: 'SRC-006',
    region: 'T3:C7',
    claimHash: 'CLM-C122',
  ),
  ProvenanceRecord(
    artifactId: 'COMMS-842',
    artifact: 'Communication',
    mutationId: 'MUT-02',
    sourceId: 'SRC-009',
    region: 'P1:L7–14',
    claimHash: 'CLM-3E90',
  ),
  ProvenanceRecord(
    artifactId: 'LEGACY-STAGE',
    artifact: 'Legacy staging draft',
    mutationId: 'MUT-02',
    sourceId: 'SRC-006',
    region: 'T3:C7',
    claimHash: 'CLM-FF08',
  ),
];

const rollbackRecords = <RollbackRecord>[
  RollbackRecord(
    artifactId: 'POL-IV-006',
    beforeHash: 'A18C-42D0',
    candidateHash: 'D09E-7B11',
    restoredHash: 'A18C-42D0',
  ),
  RollbackRecord(
    artifactId: 'EHR-OS-014',
    beforeHash: 'B711-02EF',
    candidateHash: 'C220-A841',
    restoredHash: 'B711-02EF',
  ),
  RollbackRecord(
    artifactId: 'PUMP-LIB-092',
    beforeHash: '91F0-17BC',
    candidateHash: '88AD-109C',
    restoredHash: '91F0-17BC',
  ),
  RollbackRecord(
    artifactId: 'LBL-IV-021',
    beforeHash: '4CE1-A277',
    candidateHash: '61F9-BB40',
    restoredHash: '4CE1-A277',
  ),
  RollbackRecord(
    artifactId: 'COMMS-842',
    beforeHash: 'EF02-C611',
    candidateHash: 'A40D-734E',
    restoredHash: 'EF02-C611',
  ),
  RollbackRecord(
    artifactId: 'LEGACY-STAGE',
    beforeHash: '0C78-91A3',
    candidateHash: 'B8F1-237D',
    restoredHash: '0C78-91A3',
  ),
];

const vaultAuditEvents = <VaultAuditEvent>[
  VaultAuditEvent(
    id: 'EVT-031',
    time: '14:02:11.084',
    actor: 'simulation-core',
    action: 'sealed 24 / 24 outcomes',
    inputHash: 'SIM-8D4A',
    outputHash: 'TST-24FF',
  ),
  VaultAuditEvent(
    id: 'EVT-032',
    time: '14:02:11.112',
    actor: 'review-mesh',
    action: 'forked four independent contexts',
    inputHash: 'PIR-0.8',
    outputHash: 'REV-4C01',
  ),
  VaultAuditEvent(
    id: 'EVT-033',
    time: '14:02:12.004',
    actor: 'root-compiler',
    action: 'preserved LEGACY-01 dissent',
    inputHash: 'REV-4C01',
    outputHash: 'DSP-019A',
  ),
  VaultAuditEvent(
    id: 'EVT-034',
    time: '14:02:12.188',
    actor: 'rollback-core',
    action: 'verified complete + partial restore',
    inputHash: 'RBK-0.8',
    outputHash: 'PRE-6A10',
  ),
  VaultAuditEvent(
    id: 'EVT-035',
    time: '14:02:12.230',
    actor: 'approval-policy',
    action: 'locked pending legacy proof',
    inputHash: 'GATE-71B2',
    outputHash: 'LOCK-0001',
  ),
];

SpecialistReview specialistReviewById(String id) =>
    specialistReviews.firstWhere(
      (review) => review.id == id,
      orElse: () => specialistReviews[1],
    );

List<String> evidenceVaultBlockers({
  required bool simulationVerified,
  required EvidenceVaultRunState state,
  bool legacyStagingVerified = false,
}) {
  if (!simulationVerified) {
    return const ['Deterministic regression suite is not verified'];
  }
  if (state == EvidenceVaultRunState.ready) {
    return const [
      'Four required specialist reviews are absent',
      'Rollback package is not verified',
    ];
  }
  if (state == EvidenceVaultRunState.reviewing) {
    return const [
      'Specialist review mesh is incomplete',
      'Rollback verification is still running',
    ];
  }
  if (!legacyStagingVerified) {
    return const [
      'LEGACY-01 requires visual staging proof from the fictional EHR',
    ];
  }
  return const [];
}
