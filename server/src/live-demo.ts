import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

import { createLiveReasoningPipeline, createLiveRunId } from './openai/live-pipeline-factory.js';

function safeErrorCode(error: unknown): string {
  if (error && typeof error === 'object' && 'code' in error && typeof (error as { code?: unknown }).code === 'string') {
    return (error as { code: string }).code;
  }
  return error instanceof Error ? error.name : 'unknown_error';
}

async function saveEvidence(name: string, value: unknown): Promise<string> {
  const directory = process.env.OPENAI_EVIDENCE_DIR ?? 'probes/results';
  await mkdir(directory, { recursive: true });
  const path = join(directory, name);
  await writeFile(path, `${JSON.stringify(value, null, 2)}\n`, { encoding: 'utf8', mode: 0o600, flag: 'wx' });
  return path;
}

async function main(): Promise<void> {
  const runId = createLiveRunId();
  const pipeline = createLiveReasoningPipeline();
  try {
    const result = await pipeline.run(runId);
    const path = await saveEvidence(`${runId}.json`, {
      status: 'passed',
      recordedAt: new Date().toISOString(),
      rootRunId: runId,
      responseIds: [result.patchResponseId, result.programmaticResponseId, result.auditResponseId],
      patchVersion: result.patch.version,
      passedPathways: result.simulation.passedPathways,
      pathwayCount: result.simulation.pathwayCount,
      passedAssertions: result.simulation.passedAssertions,
      assertionCount: result.simulation.assertionCount,
      exactRollbackVerified: result.exactRollbackVerified,
      approvalBlockers: result.approval.blockers,
      finalCommitAllowed: false,
    });
    process.stdout.write(`${JSON.stringify({ status: 'passed', runId, evidencePath: path })}\n`);
  } catch (error) {
    const code = safeErrorCode(error);
    const path = await saveEvidence(`${runId}-failed.json`, {
      status: 'failed', recordedAt: new Date().toISOString(), rootRunId: runId, code,
      finalCommitAllowed: false,
    });
    process.stderr.write(`${JSON.stringify({ status: 'failed', runId, code, evidencePath: path })}\n`);
    process.exitCode = 1;
  }
}

await main();
