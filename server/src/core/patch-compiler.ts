import { stableHash } from './canonical.js';
import { readScalarAtPointer, writeScalarAtPointer } from './json-pointer.js';
import { validatePatchIR } from '../domain/patch-ir-schema.js';
import type {
  ArtifactDiff,
  CompiledPatch,
  InstitutionArtifact,
  InstitutionState,
  PatchIR,
  RollbackAction,
} from '../domain/types.js';

export class PatchCompileError extends Error {
  constructor(
    message: string,
    readonly code:
      | 'DUPLICATE_ARTIFACT'
      | 'ARTIFACT_NOT_FOUND'
      | 'ARTIFACT_TYPE_MISMATCH'
      | 'PRECONDITION_MISMATCH'
      | 'INVALID_PARTIAL_LIMIT'
      | 'ROLLBACK_MISMATCH',
    readonly context: Record<string, unknown> = {},
  ) {
    super(message);
    this.name = 'PatchCompileError';
  }
}

function cloneState(state: InstitutionState): InstitutionState {
  return structuredClone(state);
}

function artifactIndex(state: InstitutionState): Map<string, InstitutionArtifact> {
  const index = new Map<string, InstitutionArtifact>();
  for (const artifact of state.artifacts) {
    if (index.has(artifact.id)) {
      throw new PatchCompileError(
        `Institution state contains duplicate artifact ${artifact.id}.`,
        'DUPLICATE_ARTIFACT',
        { artifactId: artifact.id },
      );
    }
    index.set(artifact.id, artifact);
  }
  return index;
}

function totalTargetCount(patch: PatchIR): number {
  return patch.mutations.reduce((sum, mutation) => sum + mutation.targets.length, 0);
}

export interface CompileOptions {
  stopAfterTargets?: number;
}

export function compilePatch(
  sourceState: InstitutionState,
  patchInput: unknown,
  options: CompileOptions = {},
): CompiledPatch {
  const patch = validatePatchIR(patchInput);
  const totalTargets = totalTargetCount(patch);
  const limit = options.stopAfterTargets ?? totalTargets;
  if (!Number.isInteger(limit) || limit < 1 || limit > totalTargets) {
    throw new PatchCompileError(
      `stopAfterTargets must be between 1 and ${totalTargets}.`,
      'INVALID_PARTIAL_LIMIT',
      { limit, totalTargets },
    );
  }

  const beforeStateHash = stableHash(sourceState);
  const candidate = cloneState(sourceState);
  const artifacts = artifactIndex(candidate);
  const diffs: ArtifactDiff[] = [];

  outer: for (const mutation of patch.mutations) {
    for (const target of mutation.targets) {
      if (diffs.length >= limit) break outer;
      const artifact = artifacts.get(target.artifactId);
      if (!artifact) {
        throw new PatchCompileError(
          `Patch target ${target.artifactId} does not exist.`,
          'ARTIFACT_NOT_FOUND',
          { mutationId: mutation.id, artifactId: target.artifactId },
        );
      }
      if (artifact.type !== target.artifactType) {
        throw new PatchCompileError(
          `Patch target ${target.artifactId} has type ${artifact.type}, expected ${target.artifactType}.`,
          'ARTIFACT_TYPE_MISMATCH',
          { mutationId: mutation.id, artifactId: target.artifactId },
        );
      }

      const before = readScalarAtPointer(artifact.fields, target.fieldPath);
      if (!Object.is(before, target.expectedBefore)) {
        throw new PatchCompileError(
          `Precondition mismatch for ${target.artifactId}${target.fieldPath}.`,
          'PRECONDITION_MISMATCH',
          {
            mutationId: mutation.id,
            artifactId: target.artifactId,
            fieldPath: target.fieldPath,
            expected: target.expectedBefore,
            actual: before,
          },
        );
      }
      writeScalarAtPointer(artifact.fields, target.fieldPath, target.proposedAfter);
      diffs.push({
        mutationId: mutation.id,
        artifactId: artifact.id,
        artifactType: artifact.type,
        fieldPath: target.fieldPath,
        before,
        after: target.proposedAfter,
        evidenceRefs: [...mutation.evidenceRefs],
      });
    }
  }

  return {
    patchId: patch.patchId,
    patchVersion: patch.version,
    status: diffs.length === totalTargets ? 'complete' : 'partial',
    beforeStateHash,
    candidateStateHash: stableHash(candidate),
    state: candidate,
    diffs,
    appliedTargetCount: diffs.length,
    totalTargetCount: totalTargets,
    patch,
  };
}

function rollbackForDiff(patch: PatchIR, diff: ArtifactDiff): RollbackAction {
  const action = patch.rollback.find(
    (candidate) =>
      candidate.mutationId === diff.mutationId &&
      candidate.artifactId === diff.artifactId &&
      candidate.fieldPath === diff.fieldPath,
  );
  if (!action) {
    throw new PatchCompileError('A compiled diff has no rollback action.', 'ROLLBACK_MISMATCH', {
      mutationId: diff.mutationId,
      artifactId: diff.artifactId,
      fieldPath: diff.fieldPath,
    });
  }
  return action;
}

export interface RollbackResult {
  state: InstitutionState;
  restoredStateHash: string;
  exact: boolean;
  revertedTargetCount: number;
}

export function rollbackCompiledPatch(compiled: CompiledPatch): RollbackResult {
  const restored = cloneState(compiled.state);
  const artifacts = artifactIndex(restored);

  for (const diff of [...compiled.diffs].reverse()) {
    const action = rollbackForDiff(compiled.patch, diff);
    const artifact = artifacts.get(action.artifactId);
    if (!artifact) {
      throw new PatchCompileError('Rollback target disappeared.', 'ROLLBACK_MISMATCH', {
        artifactId: action.artifactId,
      });
    }
    const current = readScalarAtPointer(artifact.fields, action.fieldPath);
    if (!Object.is(current, action.expectedPatchedValue)) {
      throw new PatchCompileError('Rollback refused because staged state drifted.', 'ROLLBACK_MISMATCH', {
        artifactId: action.artifactId,
        fieldPath: action.fieldPath,
        expected: action.expectedPatchedValue,
        actual: current,
      });
    }
    writeScalarAtPointer(artifact.fields, action.fieldPath, action.restoreValue);
  }

  const restoredStateHash = stableHash(restored);
  return {
    state: restored,
    restoredStateHash,
    exact: restoredStateHash === compiled.beforeStateHash,
    revertedTargetCount: compiled.diffs.length,
  };
}

export function provenanceCoverage(compiled: CompiledPatch): number {
  if (compiled.diffs.length === 0) return 0;
  const knownEvidence = new Set(compiled.patch.sourceEvidence.map((evidence) => evidence.id));
  const supported = compiled.diffs.filter(
    (diff) =>
      diff.evidenceRefs.length > 0 &&
      diff.evidenceRefs.every((reference) => knownEvidence.has(reference)),
  ).length;
  return Math.round((supported / compiled.diffs.length) * 100);
}
