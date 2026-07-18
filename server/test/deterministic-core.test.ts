import assert from 'node:assert/strict';
import test from 'node:test';

import {
  AuditLedger,
  compilePatch,
  evaluateApprovalGate,
  PatchCompileError,
  PatchValidationError,
  provenanceCoverage,
  resolveEvidenceReferences,
  rollbackCompiledPatch,
  runSimulation,
  stableHash,
  validatePatchIR,
} from '../src/index.js';
import {
  artifactIds,
  candidatePatchV07,
  northstarBaseline,
  revisedPatchV08,
  specialistReviewFixture,
  syntheticPathways,
} from '../src/fixtures/northstar.js';
import { syntheticCorpus } from '../src/fixtures/corpus.js';
import type { ApprovalGateInput, PatchIR } from '../src/domain/types.js';

function clone<T>(value: T): T {
  return structuredClone(value);
}

test('both synthetic Patch IR candidates satisfy structural and semantic contracts', () => {
  assert.equal(validatePatchIR(candidatePatchV07), candidatePatchV07);
  assert.equal(validatePatchIR(revisedPatchV08), revisedPatchV08);
  assert.equal(syntheticPathways.length, 24);
  assert.equal(
    syntheticPathways.reduce((sum, pathway) => sum + pathway.assertions.length, 0),
    96,
  );
});

test('every Patch IR source resolves to an immutable corpus region checksum', () => {
  const resolution = resolveEvidenceReferences(
    syntheticCorpus,
    revisedPatchV08.sourceEvidence,
  );

  assert.equal(syntheticCorpus.length, 9);
  assert.equal(resolution.valid, true);
  assert.equal(resolution.resolved, revisedPatchV08.sourceEvidence.length);
  assert.deepEqual(resolution.issues, []);
});

test('provenance resolution detects checksum drift', () => {
  const references = clone(revisedPatchV08.sourceEvidence);
  references[0]!.checksum = 'sha256:drifted';
  const resolution = resolveEvidenceReferences(syntheticCorpus, references);

  assert.equal(resolution.valid, false);
  assert.ok(resolution.issues.includes('checksum mismatch for SRC-001'));
});

test('candidate v0.7 compiles six evidence-backed projections', () => {
  const compiled = compilePatch(northstarBaseline, candidatePatchV07);

  assert.equal(compiled.status, 'complete');
  assert.equal(compiled.diffs.length, 6);
  assert.equal(provenanceCoverage(compiled), 100);
  assert.deepEqual(new Set(compiled.diffs.map((diff) => diff.artifactId)), new Set(artifactIds));
  assert.ok(compiled.diffs.every((diff) => diff.evidenceRefs.includes('SRC-002')));
});

test('candidate v0.7 exposes exactly the seeded hidden pediatric failure', () => {
  const report = runSimulation(
    compilePatch(northstarBaseline, candidatePatchV07),
    syntheticPathways,
  );

  assert.equal(report.pathwayCount, 24);
  assert.equal(report.passedPathways, 23);
  assert.equal(report.failedPathways, 1);
  assert.equal(report.assertionCount, 96);
  assert.equal(report.passedAssertions, 95);
  assert.equal(report.failedAssertions, 1);

  const failures = report.results
    .flatMap((result) => result.assertions)
    .filter((assertion) => !assertion.passed);
  assert.deepEqual(failures.map((failure) => failure.id), ['PATH-PED-07-04/A1']);
  assert.equal(failures[0]?.actual, '"NONE"');
  assert.equal(failures[0]?.expected, '"PED-07"');
});

test('revised v0.8 recompiles all projections and passes 96 assertions', () => {
  const compiled = compilePatch(northstarBaseline, revisedPatchV08);
  const report = runSimulation(compiled, syntheticPathways);

  assert.equal(compiled.diffs.length, 12);
  assert.equal(report.passedPathways, 24);
  assert.equal(report.failedPathways, 0);
  assert.equal(report.passedAssertions, 96);
  assert.equal(report.failedAssertions, 0);
  assert.equal(provenanceCoverage(compiled), 100);

  for (const artifact of compiled.state.artifacts) {
    assert.equal(artifact.fields.exceptionReference, 'PED-07');
  }
});

test('complete rollback restores the exact sealed fixture hash', () => {
  const compiled = compilePatch(northstarBaseline, revisedPatchV08);
  const rollback = rollbackCompiledPatch(compiled);

  assert.equal(rollback.revertedTargetCount, 12);
  assert.equal(rollback.exact, true);
  assert.equal(rollback.restoredStateHash, stableHash(northstarBaseline));
  assert.deepEqual(rollback.state, northstarBaseline);
});

test('partial staging rollback also restores the exact sealed fixture hash', () => {
  const staged = compilePatch(northstarBaseline, revisedPatchV08, {
    stopAfterTargets: 8,
  });
  const rollback = rollbackCompiledPatch(staged);

  assert.equal(staged.status, 'partial');
  assert.equal(staged.appliedTargetCount, 8);
  assert.equal(rollback.revertedTargetCount, 8);
  assert.equal(rollback.exact, true);
  assert.deepEqual(rollback.state, northstarBaseline);
});

test('compilation is deterministic and does not mutate its source fixture', () => {
  const source = clone(northstarBaseline);
  const sourceHash = stableHash(source);
  const first = compilePatch(source, revisedPatchV08);
  const second = compilePatch(source, revisedPatchV08);

  assert.equal(first.candidateStateHash, second.candidateStateHash);
  assert.deepEqual(first.diffs, second.diffs);
  assert.equal(stableHash(source), sourceHash);
  assert.deepEqual(source, northstarBaseline);
});

test('compiler refuses stale expected-before values without mutating source state', () => {
  const drifted = clone(northstarBaseline);
  drifted.artifacts[0]!.fields.substitutionToken = 'DRIFTED';
  const before = stableHash(drifted);

  assert.throws(
    () => compilePatch(drifted, candidatePatchV07),
    (error: unknown) =>
      error instanceof PatchCompileError && error.code === 'PRECONDITION_MISMATCH',
  );
  assert.equal(stableHash(drifted), before);
});

test('Patch IR rejects unknown provenance and incomplete rollback coverage', () => {
  const unknownEvidence = clone(revisedPatchV08);
  unknownEvidence.mutations[0]!.evidenceRefs = ['SRC-DOES-NOT-EXIST'];
  assert.throws(
    () => validatePatchIR(unknownEvidence),
    (error: unknown) =>
      error instanceof PatchValidationError &&
      error.issues.some((issue) => issue.includes('unknown evidence')),
  );

  const incompleteRollback = clone(revisedPatchV08);
  incompleteRollback.rollback.pop();
  assert.throws(
    () => validatePatchIR(incompleteRollback),
    (error: unknown) =>
      error instanceof PatchValidationError &&
      error.issues.some((issue) => issue.includes('missing rollback action')),
  );
});

test('Patch IR cannot target a final commit field', () => {
  const unsafe = clone(revisedPatchV08);
  unsafe.mutations[0]!.targets[0]!.fieldPath = '/finalCommit';
  unsafe.rollback[0]!.fieldPath = '/finalCommit';

  assert.throws(
    () => validatePatchIR(unsafe),
    (error: unknown) =>
      error instanceof PatchValidationError &&
      error.issues.some((issue) => issue.includes('forbidden sensitive target')),
  );
});

function gateInput(patch: PatchIR): ApprovalGateInput {
  const compiled = compilePatch(northstarBaseline, patch);
  return {
    patch,
    simulation: runSimulation(compiled, syntheticPathways),
    reviews: specialistReviewFixture(true),
    provenanceCoverage: provenanceCoverage(compiled),
    exactRollbackVerified: rollbackCompiledPatch(compiled).exact,
    legacyVisualProofVerified: true,
    unresolvedEvidenceIds: [],
  };
}

test('approval gate blocks the unsafe candidate even when every other proof is present', () => {
  const decision = evaluateApprovalGate(gateInput(candidatePatchV07));

  assert.equal(decision.approvalControlEnabled, false);
  assert.equal(decision.finalCommitAllowed, false);
  assert.ok(decision.blockers.includes('TEST_FAILED:PATH-PED-07-04'));
  assert.ok(decision.blockers.includes('ASSERTIONS_FAILED:1'));
});

test('approval gate preserves legacy dissent until visual proof resolves it', () => {
  const input = gateInput(revisedPatchV08);
  input.reviews = specialistReviewFixture(false);
  input.legacyVisualProofVerified = false;

  const decision = evaluateApprovalGate(input);
  assert.equal(decision.approvalControlEnabled, false);
  assert.ok(decision.blockers.includes('DISSENT_OPEN:LEGACY-01'));
  assert.ok(decision.blockers.includes('LEGACY_VISUAL_PROOF_MISSING'));
});

test('verified v0.8 may enable human approval but can never perform final commit', () => {
  const decision = evaluateApprovalGate(gateInput(revisedPatchV08));

  assert.deepEqual(decision.blockers, []);
  assert.equal(decision.approvalControlEnabled, true);
  assert.equal(decision.finalCommitAllowed, false);
});

test('approval gate rejects incomplete provenance even with a passing simulation', () => {
  const input = gateInput(revisedPatchV08);
  input.provenanceCoverage = 99;
  const decision = evaluateApprovalGate(input);

  assert.equal(decision.approvalControlEnabled, false);
  assert.ok(decision.blockers.includes('PROVENANCE_INCOMPLETE:99'));
});

test('audit ledger exposes hashes only and detects event-chain tampering', () => {
  const ledger = new AuditLedger('RUN-TEST-001');
  ledger.append({
    timestamp: '2026-07-18T14:00:00.000Z',
    actor: 'patch-compiler',
    action: 'compiled synthetic patch',
    input: northstarBaseline,
    output: { patchId: revisedPatchV08.patchId },
  });
  ledger.append({
    timestamp: '2026-07-18T14:00:01.000Z',
    actor: 'simulation-core',
    action: 'ran synthetic pathways',
    input: { patchId: revisedPatchV08.patchId },
    output: { passed: 96 },
  });

  assert.equal(ledger.verify(), true);
  const exported = ledger.entries();
  assert.equal(exported.length, 2);
  assert.equal('input' in exported[0]!, false);
  assert.equal('output' in exported[0]!, false);

  exported[0]!.action = 'tampered';
  assert.equal(AuditLedger.verify(exported), false);
  assert.equal(ledger.verify(), true);
});
