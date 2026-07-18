import { readScalarAtPointer } from './json-pointer.js';
import type {
  AssertionResult,
  AssertionSpec,
  CompiledPatch,
  PatientPathway,
  PathwayResult,
  Scalar,
  SimulationReport,
} from '../domain/types.js';

function render(value: Scalar | undefined): string {
  return value === undefined ? '<missing>' : JSON.stringify(value);
}

function artifactField(
  compiled: CompiledPatch,
  artifactId: string,
  fieldPath: string,
): Scalar | undefined {
  const artifact = compiled.state.artifacts.find((candidate) => candidate.id === artifactId);
  if (!artifact) return undefined;
  try {
    return readScalarAtPointer(artifact.fields, fieldPath);
  } catch {
    return undefined;
  }
}

function evaluateAssertion(
  compiled: CompiledPatch,
  pathwayId: string,
  assertion: AssertionSpec,
): AssertionResult {
  if (assertion.kind === 'field_equals') {
    const actual = artifactField(compiled, assertion.artifactId, assertion.fieldPath);
    return {
      id: assertion.id,
      pathwayId,
      passed: Object.is(actual, assertion.expected),
      expected: render(assertion.expected),
      actual: render(actual),
    };
  }

  if (assertion.kind === 'field_matches') {
    const left = artifactField(compiled, assertion.leftArtifactId, assertion.fieldPath);
    const right = artifactField(compiled, assertion.rightArtifactId, assertion.fieldPath);
    return {
      id: assertion.id,
      pathwayId,
      passed: left !== undefined && Object.is(left, right),
      expected: `${assertion.leftArtifactId} == ${assertion.rightArtifactId}`,
      actual: `${render(left)} / ${render(right)}`,
    };
  }

  if (assertion.kind === 'diff_supported') {
    const diff = compiled.diffs.find(
      (candidate) =>
        candidate.artifactId === assertion.artifactId &&
        candidate.fieldPath === assertion.fieldPath,
    );
    const knownEvidence = new Set(compiled.patch.sourceEvidence.map((evidence) => evidence.id));
    const passed = Boolean(
      diff &&
        diff.evidenceRefs.length > 0 &&
        diff.evidenceRefs.every((reference) => knownEvidence.has(reference)),
    );
    return {
      id: assertion.id,
      pathwayId,
      passed,
      expected: 'evidence-backed diff',
      actual: diff ? `${diff.evidenceRefs.length} evidence reference(s)` : '<missing diff>',
    };
  }

  const rollback = compiled.patch.rollback.find(
    (candidate) =>
      candidate.artifactId === assertion.artifactId &&
      candidate.fieldPath === assertion.fieldPath,
  );
  return {
    id: assertion.id,
    pathwayId,
    passed: Boolean(rollback),
    expected: 'declared rollback action',
    actual: rollback?.id ?? '<missing rollback>',
  };
}

function runPathway(compiled: CompiledPatch, pathway: PatientPathway): PathwayResult {
  const assertions = pathway.assertions.map((assertion) =>
    evaluateAssertion(compiled, pathway.id, assertion),
  );
  return {
    pathwayId: pathway.id,
    suiteId: pathway.suiteId,
    passed: assertions.every((assertion) => assertion.passed),
    assertions,
  };
}

export function runSimulation(
  compiled: CompiledPatch,
  pathways: PatientPathway[],
): SimulationReport {
  if (compiled.status !== 'complete') {
    throw new Error('Simulation requires a completely compiled patch.');
  }
  const ids = new Set<string>();
  for (const pathway of pathways) {
    if (ids.has(pathway.id)) throw new Error(`Duplicate pathway id: ${pathway.id}`);
    ids.add(pathway.id);
    if (pathway.assertions.length === 0) {
      throw new Error(`Pathway ${pathway.id} has no assertions.`);
    }
  }

  const results = pathways.map((pathway) => runPathway(compiled, pathway));
  const assertions = results.flatMap((result) => result.assertions);
  const passedAssertions = assertions.filter((assertion) => assertion.passed).length;
  const passedPathways = results.filter((result) => result.passed).length;

  return {
    patchVersion: compiled.patchVersion,
    pathwayCount: results.length,
    passedPathways,
    failedPathways: results.length - passedPathways,
    assertionCount: assertions.length,
    passedAssertions,
    failedAssertions: assertions.length - passedAssertions,
    results,
  };
}
