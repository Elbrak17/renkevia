import { Ajv, type ErrorObject } from 'ajv';

import type { PatchIR, ReviewRole } from './types.js';

const artifactTypes = [
  'policy',
  'order_set',
  'pump_library',
  'label',
  'communication',
  'legacy_staging',
] as const;

const reviewRoles: ReviewRole[] = [
  'pharmacy',
  'clinical_informatics',
  'pediatric_safety',
  'adversarial_auditor',
];

const scalarSchema = {
  anyOf: [
    { type: 'string' },
    { type: 'number' },
    { type: 'boolean' },
    { type: 'null' },
  ],
} as const;

const evidenceReferenceSchema = {
  type: 'object',
  additionalProperties: false,
  required: ['id', 'artifactId', 'region', 'checksum'],
  properties: {
    id: { type: 'string', minLength: 1 },
    artifactId: { type: 'string', minLength: 1 },
    region: { type: 'string', minLength: 1 },
    checksum: { type: 'string', minLength: 8 },
  },
} as const;

export const patchIrSchema = {
  $id: 'https://renkevia.dev/schemas/patch-ir-v1.json',
  type: 'object',
  additionalProperties: false,
  required: [
    'schemaVersion',
    'patchId',
    'version',
    'incidentId',
    'synthetic',
    'status',
    'sourceEvidence',
    'preconditions',
    'mutations',
    'exceptions',
    'validationPlan',
    'approvals',
    'rollback',
  ],
  properties: {
    schemaVersion: { const: 'renkevia.patch-ir/v1' },
    patchId: { type: 'string', minLength: 1 },
    version: { type: 'string', minLength: 1 },
    incidentId: { type: 'string', minLength: 1 },
    synthetic: { const: true },
    status: { enum: ['candidate', 'revised'] },
    sourceEvidence: {
      type: 'array',
      minItems: 1,
      items: evidenceReferenceSchema,
    },
    preconditions: {
      type: 'array',
      minItems: 1,
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['id', 'description', 'evidenceRefs'],
        properties: {
          id: { type: 'string', minLength: 1 },
          description: { type: 'string', minLength: 1 },
          evidenceRefs: {
            type: 'array',
            minItems: 1,
            uniqueItems: true,
            items: { type: 'string', minLength: 1 },
          },
        },
      },
    },
    mutations: {
      type: 'array',
      minItems: 1,
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['id', 'intent', 'operation', 'targets', 'evidenceRefs'],
        properties: {
          id: { type: 'string', minLength: 1 },
          intent: { type: 'string', minLength: 1 },
          operation: { const: 'replace' },
          targets: {
            type: 'array',
            minItems: 1,
            items: {
              type: 'object',
              additionalProperties: false,
              required: [
                'artifactId',
                'artifactType',
                'fieldPath',
                'expectedBefore',
                'proposedAfter',
              ],
              properties: {
                artifactId: { type: 'string', minLength: 1 },
                artifactType: { enum: artifactTypes },
                fieldPath: { type: 'string', pattern: '^/' },
                expectedBefore: scalarSchema,
                proposedAfter: scalarSchema,
              },
            },
          },
          evidenceRefs: {
            type: 'array',
            minItems: 1,
            uniqueItems: true,
            items: { type: 'string', minLength: 1 },
          },
        },
      },
    },
    exceptions: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: [
          'id',
          'population',
          'predicate',
          'mutationId',
          'evidenceRefs',
          'testIds',
        ],
        properties: {
          id: { type: 'string', minLength: 1 },
          population: { const: 'synthetic_pediatric' },
          predicate: { type: 'string', minLength: 1 },
          mutationId: { type: 'string', minLength: 1 },
          evidenceRefs: {
            type: 'array',
            minItems: 1,
            uniqueItems: true,
            items: { type: 'string', minLength: 1 },
          },
          testIds: {
            type: 'array',
            minItems: 1,
            uniqueItems: true,
            items: { type: 'string', minLength: 1 },
          },
        },
      },
    },
    validationPlan: {
      type: 'object',
      additionalProperties: false,
      required: [
        'requiredTestIds',
        'requiredReviews',
        'requireExactRollback',
        'requireLegacyVisualProof',
      ],
      properties: {
        requiredTestIds: {
          type: 'array',
          minItems: 1,
          uniqueItems: true,
          items: { type: 'string', minLength: 1 },
        },
        requiredReviews: {
          type: 'array',
          minItems: 4,
          uniqueItems: true,
          items: { enum: reviewRoles },
        },
        requireExactRollback: { const: true },
        requireLegacyVisualProof: { const: true },
      },
    },
    approvals: {
      type: 'array',
      minItems: 4,
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['role', 'required', 'state'],
        properties: {
          role: { enum: reviewRoles },
          required: { const: true },
          state: { enum: ['pending', 'approved', 'rejected'] },
        },
      },
    },
    rollback: {
      type: 'array',
      minItems: 1,
      items: {
        type: 'object',
        additionalProperties: false,
        required: [
          'id',
          'mutationId',
          'artifactId',
          'fieldPath',
          'restoreValue',
          'expectedPatchedValue',
        ],
        properties: {
          id: { type: 'string', minLength: 1 },
          mutationId: { type: 'string', minLength: 1 },
          artifactId: { type: 'string', minLength: 1 },
          fieldPath: { type: 'string', pattern: '^/' },
          restoreValue: scalarSchema,
          expectedPatchedValue: scalarSchema,
        },
      },
    },
  },
} as const;

export class PatchValidationError extends Error {
  constructor(
    message: string,
    readonly issues: string[],
  ) {
    super(message);
    this.name = 'PatchValidationError';
  }
}

const ajv = new Ajv({ allErrors: true, strict: true });
const validateSchema = ajv.compile(patchIrSchema);

function formatAjvError(error: ErrorObject): string {
  const path = error.instancePath || '/';
  return `${path} ${error.message ?? 'is invalid'}`;
}

function duplicateValues(values: string[]): string[] {
  const seen = new Set<string>();
  const duplicates = new Set<string>();
  for (const value of values) {
    if (seen.has(value)) duplicates.add(value);
    seen.add(value);
  }
  return [...duplicates];
}

function collectSemanticIssues(patch: PatchIR): string[] {
  const issues: string[] = [];
  const evidenceIds = new Set(patch.sourceEvidence.map((evidence) => evidence.id));
  const mutationIds = new Set(patch.mutations.map((mutation) => mutation.id));
  const requiredTests = new Set(patch.validationPlan.requiredTestIds);

  for (const duplicate of duplicateValues(patch.sourceEvidence.map((item) => item.id))) {
    issues.push(`duplicate evidence id: ${duplicate}`);
  }
  for (const duplicate of duplicateValues(patch.mutations.map((item) => item.id))) {
    issues.push(`duplicate mutation id: ${duplicate}`);
  }
  for (const duplicate of duplicateValues(patch.rollback.map((item) => item.id))) {
    issues.push(`duplicate rollback id: ${duplicate}`);
  }

  const assertEvidenceRefs = (owner: string, refs: string[]) => {
    for (const ref of refs) {
      if (!evidenceIds.has(ref)) issues.push(`${owner} references unknown evidence: ${ref}`);
    }
  };

  for (const precondition of patch.preconditions) {
    assertEvidenceRefs(`precondition ${precondition.id}`, precondition.evidenceRefs);
  }

  const targetKeys = new Set<string>();
  const expectedRollbacks = new Map<string, { before: unknown; after: unknown }>();
  for (const mutation of patch.mutations) {
    assertEvidenceRefs(`mutation ${mutation.id}`, mutation.evidenceRefs);
    for (const target of mutation.targets) {
      const key = `${mutation.id}:${target.artifactId}:${target.fieldPath}`;
      const globalKey = `${target.artifactId}:${target.fieldPath}`;
      if (targetKeys.has(globalKey)) issues.push(`duplicate mutation target: ${globalKey}`);
      targetKeys.add(globalKey);
      expectedRollbacks.set(key, {
        before: target.expectedBefore,
        after: target.proposedAfter,
      });
      const segments = target.fieldPath.toLowerCase().split('/');
      if (segments.some((segment) => ['finalcommit', 'productioncommit', 'livewrite'].includes(segment))) {
        issues.push(`forbidden sensitive target: ${target.fieldPath}`);
      }
    }
  }

  for (const exception of patch.exceptions) {
    assertEvidenceRefs(`exception ${exception.id}`, exception.evidenceRefs);
    if (!mutationIds.has(exception.mutationId)) {
      issues.push(`exception ${exception.id} references unknown mutation: ${exception.mutationId}`);
    }
    for (const testId of exception.testIds) {
      if (!requiredTests.has(testId)) {
        issues.push(`exception ${exception.id} references unrequired test: ${testId}`);
      }
    }
  }

  const rollbackKeys = new Set<string>();
  for (const action of patch.rollback) {
    const key = `${action.mutationId}:${action.artifactId}:${action.fieldPath}`;
    if (rollbackKeys.has(key)) issues.push(`duplicate rollback target: ${key}`);
    rollbackKeys.add(key);
    const expected = expectedRollbacks.get(key);
    if (!expected) {
      issues.push(`rollback action ${action.id} has no matching mutation target`);
      continue;
    }
    if (!Object.is(action.restoreValue, expected.before)) {
      issues.push(`rollback action ${action.id} does not restore expectedBefore`);
    }
    if (!Object.is(action.expectedPatchedValue, expected.after)) {
      issues.push(`rollback action ${action.id} does not match proposedAfter`);
    }
  }
  for (const key of expectedRollbacks.keys()) {
    if (!rollbackKeys.has(key)) issues.push(`missing rollback action for ${key}`);
  }

  for (const role of reviewRoles) {
    if (!patch.validationPlan.requiredReviews.includes(role)) {
      issues.push(`missing required review role: ${role}`);
    }
    if (!patch.approvals.some((approval) => approval.role === role && approval.required)) {
      issues.push(`missing required approval role: ${role}`);
    }
  }

  return issues;
}

export function validatePatchIR(input: unknown): PatchIR {
  if (!validateSchema(input)) {
    throw new PatchValidationError(
      'Patch IR failed structural validation.',
      (validateSchema.errors ?? []).map(formatAjvError),
    );
  }

  const patch = input as PatchIR;
  const issues = collectSemanticIssues(patch);
  if (issues.length > 0) {
    throw new PatchValidationError('Patch IR failed semantic validation.', issues);
  }
  return patch;
}
