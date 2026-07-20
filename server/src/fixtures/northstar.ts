import type {
  ApprovalRequirement,
  ArtifactType,
  InstitutionArtifact,
  InstitutionState,
  MutationTarget,
  PatientPathway,
  PatchIR,
  PatchMutation,
  ReviewFinding,
  ReviewRole,
  RollbackAction,
} from '../domain/types.js';
import { evidenceReference } from './corpus.js';

export const artifactIds = [
  'POL-IV-006',
  'EHR-OS-014',
  'PUMP-LIB-092',
  'LBL-IV-021',
  'COMMS-842',
  'LEGACY-STAGE',
] as const;

const artifactTypeById: Record<(typeof artifactIds)[number], ArtifactType> = {
  'POL-IV-006': 'policy',
  'EHR-OS-014': 'order_set',
  'PUMP-LIB-092': 'pump_library',
  'LBL-IV-021': 'label',
  'COMMS-842': 'communication',
  'LEGACY-STAGE': 'legacy_staging',
};

const requiredReviews: ReviewRole[] = [
  'pharmacy',
  'clinical_informatics',
  'pediatric_safety',
  'adversarial_auditor',
];

const baseArtifacts: InstitutionArtifact[] = artifactIds.map((id) => ({
  id,
  type: artifactTypeById[id],
  fields: {
    substitutionToken: 'SYNTH-CARRIER-A',
    exceptionReference: 'NONE',
    changeTicket: 'CHANGE-842',
    approvalState: 'LOCKED',
  },
}));

export const northstarBaseline: InstitutionState = {
  fixtureId: 'FIXTURE-8D4A',
  synthetic: true,
  artifacts: baseArtifacts,
};

function targetsFor(fieldPath: string, expectedBefore: string, proposedAfter: string): MutationTarget[] {
  return artifactIds.map((artifactId) => ({
    artifactId,
    artifactType: artifactTypeById[artifactId],
    fieldPath,
    expectedBefore,
    proposedAfter,
  }));
}

const substitutionMutation: PatchMutation = {
  id: 'MUT-01',
  intent: 'Synchronize the synthetic shortage token across six institutional projections.',
  operation: 'replace',
  targets: targetsFor('/substitutionToken', 'SYNTH-CARRIER-A', 'SYNTH-CARRIER-B'),
  evidenceRefs: ['SRC-002'],
};

const pediatricExceptionMutation: PatchMutation = {
  id: 'MUT-02',
  intent: 'Represent the hidden synthetic pediatric exception in every projection.',
  operation: 'replace',
  targets: targetsFor('/exceptionReference', 'NONE', 'PED-07'),
  evidenceRefs: ['SRC-006'],
};

function rollbackFor(mutations: PatchMutation[]): RollbackAction[] {
  return mutations.flatMap((mutation) =>
    mutation.targets.map((target, index) => ({
      id: `RBK-${mutation.id}-${String(index + 1).padStart(2, '0')}`,
      mutationId: mutation.id,
      artifactId: target.artifactId,
      fieldPath: target.fieldPath,
      restoreValue: target.expectedBefore,
      expectedPatchedValue: target.proposedAfter,
    })),
  );
}

function approvals(): ApprovalRequirement[] {
  return requiredReviews.map((role) => ({ role, required: true, state: 'pending' }));
}

const pathwayIds = [
  'ADU-01',
  'ADU-02',
  'ADU-03',
  'ADU-04',
  'OVR-01',
  'OVR-02',
  'OVR-03',
  'OVR-04',
  'CRT-01',
  'CRT-02',
  'CRT-03',
  'CRT-04',
  'PED-07-01',
  'PED-07-02',
  'PED-07-03',
  'PATH-PED-07-04',
  'PAR-01',
  'PAR-02',
  'PAR-03',
  'PAR-04',
  'RBK-01',
  'RBK-02',
  'RBK-03',
  'RBK-04',
] as const;

function patchBase(
  version: string,
  status: PatchIR['status'],
  mutations: PatchMutation[],
): Omit<PatchIR, 'exceptions'> {
  return {
    schemaVersion: 'renkevia.patch-ir/v1',
    patchId: `PATCH-IR-${version}`,
    version,
    incidentId: 'INC-SYNTH-842',
    synthetic: true,
    status,
    sourceEvidence: [
      evidenceReference('SRC-001'),
      evidenceReference('SRC-002'),
      evidenceReference('SRC-006'),
      evidenceReference('SRC-009'),
    ],
    preconditions: [
      {
        id: 'PRE-01',
        description: 'The six synthetic projections still match sealed fixture FIXTURE-8D4A.',
        evidenceRefs: ['SRC-009'],
      },
      {
        id: 'PRE-02',
        description: 'The shortage notice and institutional policy refer to the same synthetic token.',
        evidenceRefs: ['SRC-001', 'SRC-002'],
      },
    ],
    mutations,
    validationPlan: {
      requiredTestIds: [...pathwayIds],
      requiredReviews: [...requiredReviews],
      requireExactRollback: true,
      requireLegacyVisualProof: true,
    },
    approvals: approvals(),
    rollback: rollbackFor(mutations),
  };
}

export const candidatePatchV07: PatchIR = {
  ...patchBase('v0.7', 'candidate', [substitutionMutation]),
  exceptions: [],
};

export const revisedPatchV08: PatchIR = {
  ...patchBase('v0.8', 'revised', [substitutionMutation, pediatricExceptionMutation]),
  exceptions: [
    {
      id: 'PED-07',
      population: 'synthetic_pediatric',
      predicate: 'population == SYNTHETIC_PEDIATRIC',
      mutationId: 'MUT-02',
      evidenceRefs: ['SRC-006'],
      testIds: ['PATH-PED-07-04'],
    },
  ],
};

function fieldEquals(
  id: string,
  artifactId: string,
  fieldPath: string,
  expected: string,
) {
  return { id, kind: 'field_equals' as const, artifactId, fieldPath, expected };
}

function fieldMatches(
  id: string,
  leftArtifactId: string,
  rightArtifactId: string,
  fieldPath: string,
) {
  return { id, kind: 'field_matches' as const, leftArtifactId, rightArtifactId, fieldPath };
}

function diffSupported(id: string, artifactId: string, fieldPath: string) {
  return { id, kind: 'diff_supported' as const, artifactId, fieldPath };
}

function rollbackDeclared(id: string, artifactId: string, fieldPath: string) {
  return { id, kind: 'rollback_declared' as const, artifactId, fieldPath };
}

function pathway(
  id: string,
  suiteId: string,
  population: PatientPathway['population'],
  assertions: PatientPathway['assertions'],
): PatientPathway {
  if (assertions.length !== 4) throw new Error(`${id} must contain exactly four assertions.`);
  return { id, suiteId, name: `${suiteId} synthetic pathway ${id}`, population, assertions };
}

const rotatingArtifacts = [...artifactIds];

const adultPathways = ['ADU-01', 'ADU-02', 'ADU-03', 'ADU-04'].map((id, index) => {
  const artifactId = rotatingArtifacts[index]!;
  return pathway(id, 'ADULT-CORE', 'synthetic_adult', [
    fieldEquals(`${id}/A1`, artifactId, '/substitutionToken', 'SYNTH-CARRIER-B'),
    fieldMatches(`${id}/A2`, 'POL-IV-006', 'EHR-OS-014', '/substitutionToken'),
    diffSupported(`${id}/A3`, artifactId, '/substitutionToken'),
    rollbackDeclared(`${id}/A4`, artifactId, '/substitutionToken'),
  ]);
});

const overridePathways = ['OVR-01', 'OVR-02', 'OVR-03', 'OVR-04'].map((id, index) => {
  const artifactId = rotatingArtifacts[index + 1]!;
  return pathway(id, 'OVERRIDE', 'system', [
    fieldEquals(`${id}/A1`, artifactId, '/changeTicket', 'CHANGE-842'),
    fieldEquals(`${id}/A2`, artifactId, '/approvalState', 'LOCKED'),
    fieldMatches(`${id}/A3`, artifactId, 'COMMS-842', '/changeTicket'),
    rollbackDeclared(`${id}/A4`, artifactId, '/substitutionToken'),
  ]);
});

const criticalPathways = ['CRT-01', 'CRT-02', 'CRT-03', 'CRT-04'].map((id, index) => {
  const artifactId = rotatingArtifacts[index + 2]!;
  const peerId = rotatingArtifacts[(index + 3) % rotatingArtifacts.length]!;
  return pathway(id, 'CRITICAL', 'system', [
    fieldEquals(`${id}/A1`, artifactId, '/substitutionToken', 'SYNTH-CARRIER-B'),
    fieldMatches(`${id}/A2`, artifactId, peerId, '/substitutionToken'),
    diffSupported(`${id}/A3`, artifactId, '/substitutionToken'),
    fieldEquals(`${id}/A4`, artifactId, '/approvalState', 'LOCKED'),
  ]);
});

const pediatricPathways = ['PED-07-01', 'PED-07-02', 'PED-07-03'].map((id, index) => {
  const artifactId = rotatingArtifacts[index]!;
  return pathway(id, 'PED-07', 'synthetic_pediatric', [
    fieldEquals(`${id}/A1`, artifactId, '/substitutionToken', 'SYNTH-CARRIER-B'),
    fieldMatches(`${id}/A2`, artifactId, 'EHR-OS-014', '/substitutionToken'),
    diffSupported(`${id}/A3`, artifactId, '/substitutionToken'),
    rollbackDeclared(`${id}/A4`, artifactId, '/substitutionToken'),
  ]);
});

const hiddenPediatricPathway = pathway(
  'PATH-PED-07-04',
  'PED-07',
  'synthetic_pediatric',
  [
    fieldEquals('PATH-PED-07-04/A1', 'EHR-OS-014', '/exceptionReference', 'PED-07'),
    fieldEquals('PATH-PED-07-04/A2', 'EHR-OS-014', '/substitutionToken', 'SYNTH-CARRIER-B'),
    diffSupported('PATH-PED-07-04/A3', 'EHR-OS-014', '/substitutionToken'),
    rollbackDeclared('PATH-PED-07-04/A4', 'EHR-OS-014', '/substitutionToken'),
  ],
);

const parityPairs = [
  ['POL-IV-006', 'EHR-OS-014'],
  ['EHR-OS-014', 'PUMP-LIB-092'],
  ['PUMP-LIB-092', 'LBL-IV-021'],
  ['LBL-IV-021', 'COMMS-842'],
  ['COMMS-842', 'LEGACY-STAGE'],
  ['LEGACY-STAGE', 'POL-IV-006'],
] as const;

const parityPathways = ['PAR-01', 'PAR-02', 'PAR-03', 'PAR-04'].map((id, index) =>
  pathway(id, 'PARITY', 'system', [0, 1, 2, 3].map((offset) => {
    const [left, right] = parityPairs[(index + offset) % parityPairs.length]!;
    return fieldMatches(`${id}/A${offset + 1}`, left, right, '/substitutionToken');
  })),
);

const rollbackPathways = ['RBK-01', 'RBK-02', 'RBK-03', 'RBK-04'].map((id, index) =>
  pathway(id, 'ROLLBACK', 'system', [0, 1, 2, 3].map((offset) => {
    const artifactId = rotatingArtifacts[(index + offset) % rotatingArtifacts.length]!;
    return rollbackDeclared(`${id}/A${offset + 1}`, artifactId, '/substitutionToken');
  })),
);

export const syntheticPathways: PatientPathway[] = [
  ...adultPathways,
  ...overridePathways,
  ...criticalPathways,
  ...pediatricPathways,
  hiddenPediatricPathway,
  ...parityPathways,
  ...rollbackPathways,
];

export function specialistReviewFixture(legacyProofVerified: boolean): ReviewFinding[] {
  return [
    {
      id: 'PHARM-04',
      role: 'pharmacy',
      completed: true,
      verdict: 'agree',
      blocking: false,
      disposition: 'accepted',
      evidenceRefs: ['SRC-002'],
    },
    {
      id: 'LEGACY-01',
      role: 'clinical_informatics',
      completed: true,
      verdict: 'dissent',
      blocking: true,
      disposition: legacyProofVerified ? 'resolved' : 'open',
      evidenceRefs: ['SRC-009'],
    },
    {
      id: 'PED-07',
      role: 'pediatric_safety',
      completed: true,
      verdict: 'agree',
      blocking: false,
      disposition: 'accepted',
      evidenceRefs: ['SRC-006'],
    },
    {
      id: 'RBK-02',
      role: 'adversarial_auditor',
      completed: true,
      verdict: 'conditional',
      blocking: false,
      disposition: 'resolved',
      evidenceRefs: ['SRC-009'],
    },
  ];
}
