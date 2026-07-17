import { environmentStatus, MODELS } from './probe-kit.mjs';

const environment = environmentStatus();
const blockers = [];
if (!environment.nodeSupported) blockers.push('Node.js 20 or newer is required.');
if (!environment.apiKeyConfigured) blockers.push('OPENAI_API_KEY is not configured; live probes were not attempted.');

console.log(JSON.stringify({
  name: 'preflight',
  status: blockers.length === 0 ? 'ready' : 'blocked',
  environment,
  models: MODELS,
  blockers,
  note: 'A configured key is never printed, fingerprinted, or written to disk.',
}, null, 2));

if (!environment.nodeSupported) process.exitCode = 1;

