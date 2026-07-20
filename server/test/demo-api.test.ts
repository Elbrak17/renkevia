import assert from 'node:assert/strict';
import test, { after, before } from 'node:test';

import { createDemoApiServer } from '../src/http/demo-api.js';

const server = createDemoApiServer();
let baseUrl = '';

before(async () => {
  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
  const address = server.address();
  if (!address || typeof address === 'string') throw new Error('No test server address.');
  baseUrl = `http://127.0.0.1:${address.port}`;
});

after(async () => {
  await new Promise<void>((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
});

test('health route is explicitly deterministic, synthetic and never commit-capable', async () => {
  const response = await fetch(`${baseUrl}/api/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok', mode: 'deterministic_synthetic', finalCommitAllowed: false });
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.equal(response.headers.get('x-content-type-options'), 'nosniff');
});

test('sealed snapshot exposes the exact red-to-green demo contract', async () => {
  const response = await fetch(`${baseUrl}/api/demo/snapshot`);
  const value = await response.json() as Record<string, any>;
  assert.equal(value.synthetic, true);
  assert.deepEqual([value.candidate.passedPathways, value.candidate.pathwayCount], [23, 24]);
  assert.deepEqual([value.candidate.passedAssertions, value.candidate.assertionCount], [95, 96]);
  assert.deepEqual(value.candidate.blockerIds, ['PATH-PED-07-04/A1']);
  assert.deepEqual([value.revised.passedPathways, value.revised.pathwayCount], [24, 24]);
  assert.equal(value.revised.exactRollbackVerified, true);
  assert.equal(value.finalCommitAllowed, false);
});

test('compile, recompile and simulate are computed from the sealed fixture', async () => {
  const post = (path: string) => fetch(`${baseUrl}${path}`, {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ fixtureId: 'FIXTURE-8D4A' }),
  }).then((response) => response.json() as Promise<Record<string, any>>);
  const [candidate, revised, simulation] = await Promise.all([
    post('/api/demo/compile'), post('/api/demo/recompile'), post('/api/demo/simulate'),
  ]);
  assert.deepEqual([candidate.patchVersion, candidate.diffCount, candidate.status], ['v0.7', 6, 'blocked']);
  assert.deepEqual([revised.patchVersion, revised.diffCount, revised.status], ['v0.8', 12, 'revised']);
  assert.deepEqual([simulation.passedPathways, simulation.passedAssertions], [24, 96]);
  assert.ok([candidate, revised, simulation].every((item) => item.finalCommitAllowed === false));
});

test('audit preserves clinical-informatics dissent until visual proof exists', async () => {
  const response = await fetch(`${baseUrl}/api/demo/audit`, { method: 'POST', body: '{}' });
  const value = await response.json() as Record<string, any>;
  assert.equal(value.reviewCount, 4);
  assert.deepEqual(value.preservedDissentIds, ['LEGACY-01']);
  assert.equal(value.approvalControlEnabled, false);
  assert.ok(value.blockers.includes('DISSENT_OPEN:LEGACY-01'));
  assert.ok(value.blockers.includes('LEGACY_VISUAL_PROOF_MISSING'));
  assert.equal(value.finalCommitAllowed, false);
});

test('CORS rejects external origins and bad fixture identities', async () => {
  const forbidden = await fetch(`${baseUrl}/api/health`, { headers: { origin: 'https://attacker.example' } });
  assert.equal(forbidden.status, 403);
  const unknown = await fetch(`${baseUrl}/api/demo/compile`, {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ fixtureId: 'REAL-HOSPITAL' }),
  });
  assert.equal(unknown.status, 400);
  assert.deepEqual(await unknown.json(), { error: 'unknown_fixture' });
});
