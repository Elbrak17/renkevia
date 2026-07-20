import assert from 'node:assert/strict';
import test from 'node:test';

import { compilePatch, provenanceCoverage } from '../src/core/patch-compiler.js';
import { runSimulation } from '../src/core/simulation-engine.js';
import { revisedPatchV08, northstarBaseline, specialistReviewFixture, syntheticPathways } from '../src/fixtures/northstar.js';
import { LiveReasoningPipeline, type AuditStage, type PatchStage, type ProgrammaticStage } from '../src/openai/live-reasoning-pipeline.js';

test('live pipeline sequences model judgment through deterministic proof boundaries', async () => {
  const runIds: string[] = [];
  const compiled = compilePatch(northstarBaseline, revisedPatchV08);
  const simulation = runSimulation(compiled, syntheticPathways);
  const patchStage: PatchStage = {
    async synthesize(input) {
      runIds.push(input.runId);
      assert.equal(input.challenge !== undefined, true);
      return {
        responseId: 'resp_patch',
        patch: revisedPatchV08,
        compiledDiffs: compiled.diffs.length,
        provenanceCoverage: provenanceCoverage(compiled),
      };
    },
  };
  const programmaticStage: ProgrammaticStage = {
    async run(input) {
      runIds.push(input.runId);
      return {
        responseId: 'resp_program',
        report: simulation,
        invokedPathwayIds: syntheticPathways.map((pathway) => pathway.id),
      };
    },
  };
  const auditStage: AuditStage = {
    async run(input) {
      runIds.push(input.runId);
      return {
        responseId: 'resp_audit',
        reviews: specialistReviewFixture(false),
        rootVerdict: 'revise',
      };
    },
  };

  const result = await new LiveReasoningPipeline(patchStage, programmaticStage, auditStage).run('RUN-LIVE');

  assert.deepEqual(runIds, ['RUN-LIVE:patch', 'RUN-LIVE:programmatic', 'RUN-LIVE:multi-agent']);
  assert.equal(result.simulation.passedAssertions, 96);
  assert.equal(result.exactRollbackVerified, true);
  assert.equal(result.status, 'awaiting_legacy_visual_proof');
  assert.ok(result.approval.blockers.includes('DISSENT_OPEN:LEGACY-01'));
  assert.ok(result.approval.blockers.includes('LEGACY_VISUAL_PROOF_MISSING'));
  assert.equal(result.finalCommitAllowed, false);
});

test('live pipeline rejects a programmatic summary that diverges from software truth', async () => {
  const compiled = compilePatch(northstarBaseline, revisedPatchV08);
  const simulation = runSimulation(compiled, syntheticPathways);
  const divergent = structuredClone(simulation);
  divergent.passedAssertions = 95;
  const patchStage: PatchStage = {
    async synthesize() {
      return { responseId: 'p', patch: revisedPatchV08, compiledDiffs: 12, provenanceCoverage: 100 };
    },
  };
  const programmaticStage: ProgrammaticStage = {
    async run() {
      return { responseId: 's', report: divergent, invokedPathwayIds: syntheticPathways.map((item) => item.id) };
    },
  };
  const auditStage: AuditStage = {
    async run() {
      throw new Error('Audit must not run after divergence.');
    },
  };
  await assert.rejects(
    new LiveReasoningPipeline(patchStage, programmaticStage, auditStage).run('RUN-DIVERGENT'),
    /diverged/,
  );
});
