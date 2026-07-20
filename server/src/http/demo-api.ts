import { createServer, type IncomingMessage, type Server, type ServerResponse } from 'node:http';
import { pathToFileURL } from 'node:url';

import { evaluateApprovalGate } from '../core/approval-policy.js';
import { compilePatch, provenanceCoverage, rollbackCompiledPatch } from '../core/patch-compiler.js';
import { runSimulation } from '../core/simulation-engine.js';
import { candidatePatchV07, northstarBaseline, revisedPatchV08, specialistReviewFixture, syntheticPathways } from '../fixtures/northstar.js';
import type { LiveReasoningPipelineResult } from '../openai/live-reasoning-pipeline.js';
import { createLiveReasoningPipeline, createLiveRunId } from '../openai/live-pipeline-factory.js';

const candidateCompiled = compilePatch(northstarBaseline, candidatePatchV07);
const candidateSimulation = runSimulation(candidateCompiled, syntheticPathways);
const revisedCompiled = compilePatch(northstarBaseline, revisedPatchV08);
const revisedSimulation = runSimulation(revisedCompiled, syntheticPathways);
const revisedRollback = rollbackCompiledPatch(revisedCompiled);

const snapshot = {
  synthetic: true,
  fixtureId: northstarBaseline.fixtureId,
  incidentId: revisedPatchV08.incidentId,
  runId: 'RUN-24-0717-A',
  candidate: {
    patchVersion: candidatePatchV07.version,
    diffCount: candidateCompiled.diffs.length,
    pathwayCount: candidateSimulation.pathwayCount,
    passedPathways: candidateSimulation.passedPathways,
    assertionCount: candidateSimulation.assertionCount,
    passedAssertions: candidateSimulation.passedAssertions,
    blockerIds: candidateSimulation.results.flatMap((result) => result.assertions).filter((item) => !item.passed).map((item) => item.id),
  },
  revised: {
    patchVersion: revisedPatchV08.version,
    diffCount: revisedCompiled.diffs.length,
    pathwayCount: revisedSimulation.pathwayCount,
    passedPathways: revisedSimulation.passedPathways,
    assertionCount: revisedSimulation.assertionCount,
    passedAssertions: revisedSimulation.passedAssertions,
    provenanceCoverage: provenanceCoverage(revisedCompiled),
    exactRollbackVerified: revisedRollback.exact,
  },
  finalCommitAllowed: false,
} as const;

function allowedOrigins(env: NodeJS.ProcessEnv): Set<string> {
  const configured = (env.RENKEVIA_ALLOWED_ORIGINS ?? '').split(',').map((item) => item.trim()).filter(Boolean);
  return new Set(configured);
}

function isLoopbackOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    return ['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname);
  } catch {
    return false;
  }
}

function setHeaders(response: ServerResponse, request: IncomingMessage, env: NodeJS.ProcessEnv): boolean {
  response.setHeader('content-type', 'application/json; charset=utf-8');
  response.setHeader('cache-control', 'no-store');
  response.setHeader('x-content-type-options', 'nosniff');
  response.setHeader('referrer-policy', 'no-referrer');
  response.setHeader('content-security-policy', "default-src 'none'; frame-ancestors 'none'");
  const origin = request.headers.origin;
  if (!origin) return true;
  if (!isLoopbackOrigin(origin) && !allowedOrigins(env).has(origin)) return false;
  response.setHeader('access-control-allow-origin', origin);
  response.setHeader('vary', 'Origin');
  response.setHeader('access-control-allow-methods', 'GET, POST, OPTIONS');
  response.setHeader('access-control-allow-headers', 'content-type');
  return true;
}

function send(response: ServerResponse, status: number, body: unknown): void {
  response.statusCode = status;
  response.end(JSON.stringify(body));
}

async function body(request: IncomingMessage): Promise<Record<string, unknown>> {
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of request) {
    const buffer = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    size += buffer.length;
    if (size > 16_384) throw new Error('request_too_large');
    chunks.push(buffer);
  }
  if (!chunks.length) return {};
  const parsed = JSON.parse(Buffer.concat(chunks).toString('utf8')) as unknown;
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error('invalid_json');
  return parsed as Record<string, unknown>;
}

function assertFixture(input: Record<string, unknown>): void {
  if (input.fixtureId !== undefined && input.fixtureId !== northstarBaseline.fixtureId) {
    throw new Error('unknown_fixture');
  }
}

export interface LivePipelineRunner {
  run(rootRunId: string): Promise<LiveReasoningPipelineResult>;
}

export function createDemoApiServer(
  env: NodeJS.ProcessEnv = process.env,
  livePipelineFactory: () => LivePipelineRunner = () => createLiveReasoningPipeline(env),
): Server {
  return createServer(async (request, response) => {
    if (!setHeaders(response, request, env)) {
      send(response, 403, { error: 'origin_not_allowed' });
      return;
    }
    if (request.method === 'OPTIONS') {
      response.statusCode = 204;
      response.end();
      return;
    }
    const url = new URL(request.url ?? '/', 'http://localhost');
    try {
      if (request.method === 'GET' && url.pathname === '/api/health') {
        send(response, 200, { status: 'ok', mode: 'deterministic_synthetic', finalCommitAllowed: false });
        return;
      }
      if (request.method === 'GET' && url.pathname === '/api/demo/snapshot') {
        send(response, 200, snapshot);
        return;
      }
      if (request.method === 'POST' && url.pathname === '/api/demo/compile') {
        assertFixture(await body(request));
        send(response, 200, { synthetic: true, ...snapshot.candidate, status: 'blocked', finalCommitAllowed: false });
        return;
      }
      if (request.method === 'POST' && url.pathname === '/api/demo/recompile') {
        assertFixture(await body(request));
        send(response, 200, { synthetic: true, patchVersion: revisedPatchV08.version, diffCount: revisedCompiled.diffs.length, status: revisedPatchV08.status, finalCommitAllowed: false });
        return;
      }
      if (request.method === 'POST' && url.pathname === '/api/demo/simulate') {
        assertFixture(await body(request));
        send(response, 200, { synthetic: true, ...snapshot.revised, failedPathways: revisedSimulation.failedPathways, failedAssertions: revisedSimulation.failedAssertions, finalCommitAllowed: false });
        return;
      }
      if (request.method === 'POST' && url.pathname === '/api/demo/audit') {
        assertFixture(await body(request));
        const reviews = specialistReviewFixture(false);
        const gate = evaluateApprovalGate({
          patch: revisedPatchV08,
          simulation: revisedSimulation,
          reviews,
          provenanceCoverage: provenanceCoverage(revisedCompiled),
          exactRollbackVerified: revisedRollback.exact,
          legacyVisualProofVerified: false,
          unresolvedEvidenceIds: [],
        });
        send(response, 200, {
          synthetic: true,
          reviewCount: reviews.length,
          roles: reviews.map((review) => review.role),
          preservedDissentIds: reviews.filter((review) => review.verdict === 'dissent').map((review) => review.id),
          approvalControlEnabled: gate.approvalControlEnabled,
          blockers: gate.blockers,
          finalCommitAllowed: false,
        });
        return;
      }
      if (request.method === 'POST' && url.pathname === '/api/live/reasoning') {
        if (env.LIVE_OPENAI_ENABLED !== 'true') {
          send(response, 503, { error: 'live_disabled', finalCommitAllowed: false });
          return;
        }
        const input = await body(request);
        assertFixture(input);
        if (input.confirmLive !== true) {
          send(response, 400, { error: 'live_confirmation_required', finalCommitAllowed: false });
          return;
        }
        try {
          const result = await livePipelineFactory().run(createLiveRunId());
          const compiled = compilePatch(northstarBaseline, result.patch);
          send(response, 200, {
            synthetic: true,
            mode: 'live_gpt_5_6',
            rootRunId: result.rootRunId,
            responseIds: [result.patchResponseId, result.programmaticResponseId, result.auditResponseId],
            patchVersion: result.patch.version,
            patchStatus: result.patch.status,
            diffCount: compiled.diffs.length,
            pathwayCount: result.simulation.pathwayCount,
            passedPathways: result.simulation.passedPathways,
            assertionCount: result.simulation.assertionCount,
            passedAssertions: result.simulation.passedAssertions,
            provenanceCoverage: provenanceCoverage(compiled),
            exactRollbackVerified: result.exactRollbackVerified,
            reviewCount: result.reviews.length,
            roles: result.reviews.map((review) => review.role),
            preservedDissentIds: result.reviews.filter((review) => review.verdict === 'dissent').map((review) => review.id),
            approvalControlEnabled: result.approval.approvalControlEnabled,
            blockers: result.approval.blockers,
            finalCommitAllowed: false,
          });
        } catch (error) {
          const code = error && typeof error === 'object' && 'code' in error && typeof (error as { code?: unknown }).code === 'string'
            ? (error as { code: string }).code
            : error instanceof Error ? error.name : 'live_run_failed';
          send(response, 502, { error: code, finalCommitAllowed: false });
        }
        return;
      }
      send(response, 404, { error: 'not_found' });
    } catch (error) {
      const code = error instanceof Error ? error.message : 'invalid_request';
      send(response, code === 'request_too_large' ? 413 : 400, { error: code });
    }
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const host = process.env.RENKEVIA_API_HOST ?? '127.0.0.1';
  const port = Number(process.env.RENKEVIA_API_PORT ?? '8787');
  createDemoApiServer().listen(port, host, () => {
    process.stdout.write(`RENKEVIA deterministic API listening on http://${host}:${port}\n`);
  });
}
