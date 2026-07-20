import { readFile } from 'node:fs/promises';

const requiredFiles = [
  'README.md',
  'docs/DEMO_SCRIPT.md',
  'docs/PROOF_MANIFEST.md',
  'docs/SUBMISSION_CHECKLIST.md',
  'server/src/openai/live-reasoning-pipeline.ts',
  'server/src/openai/programmatic-simulation.ts',
  'server/src/openai/multi-agent-audit.ts',
  'server/src/openai/computer-use-staging.ts',
  'server/src/http/demo-api.ts',
  'app/lib/src/data/demo_run_gateway_web.dart',
  '.github/workflows/verify.yml',
  '.github/workflows/pages.yml',
];

const sources = await Promise.all(requiredFiles.map(async (path) => [path, await readFile(path, 'utf8')]));
const joined = sources.map(([, source]) => source).join('\n');
const checks = [
  ['RENKEVIA identity', /RENKEVIA/],
  ['synthetic-data disclosure', /SYNTHETIC|synthetic/],
  ['deterministic pathway proof', /24[ /]24|24-pathway|24 synthetic/],
  ['assertion proof', /96[ /]96|96 deterministic|96 assertions/],
  ['human approval boundary', /human approval|approbation humaine/i],
  ['final commit prohibition', /finalCommitAllowed: false|finalCommitAllowed.*false|final commit.*false/i],
  ['Programmatic Tool Calling', /Programmatic Tool Calling|programmatic_tool_calling/],
  ['Multi-agent', /Multi-agent|multi_agent/],
  ['Computer Use', /Computer Use|computer-use/],
  ['Flutter Web', /Flutter Web/],
];

const failures = checks.filter(([, pattern]) => !pattern.test(joined)).map(([label]) => label);
if (/sk-[A-Za-z0-9_-]{20,}/.test(joined)) failures.push('possible API key committed');
if (failures.length) {
  throw new Error(`Submission contract failed: ${failures.join(', ')}`);
}
process.stdout.write(`${JSON.stringify({ status: 'passed', filesChecked: requiredFiles.length, claimsChecked: checks.length })}\n`);
