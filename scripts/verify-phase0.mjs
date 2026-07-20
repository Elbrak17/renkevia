import { readFile, stat } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

const root = resolve(fileURLToPath(new URL('..', import.meta.url)));
const requiredFiles = [
  'AGENTS.md',
  'README.md',
  'docs/ARCHITECTURE.md',
  'docs/CAPABILITY_MATRIX.md',
  'docs/EVALS.md',
  'docs/SAFETY.md',
  'docs/DESIGN_SYSTEM.md',
  'docs/CODEX_BUILD_LOG.md',
  'docs/IMPACT_MODEL.md',
  'docs/DIFFERENTIATION.md',
  'docs/PROOF_MANIFEST.md',
  'docs/TOOLCHAIN.md',
];

const requiredPhrases = new Map([
  ['docs/ARCHITECTURE.md', ['Programmatic Tool Calling', 'Multi-agent', 'Computer Use']],
  ['docs/CAPABILITY_MATRIX.md', ['GPT-5.6', 'Programmatic Tool Calling', 'Computer Use']],
  ['docs/EVALS.md', ['Static checklist', 'Naive model', 'Approval integrity']],
  ['docs/SAFETY.md', ['Synthetic demonstration', 'final legacy commit', 'HIPAA']],
  ['docs/PROOF_MANIFEST.md', ['24/24', 'human approval', 'Computer Use']],
]);

const secretPatterns = [
  /sk-[A-Za-z0-9_-]{16,}/g,
  /OPENAI_API_KEY\s*=\s*[^\s#]+/g,
  /authorization:\s*bearer\s+[A-Za-z0-9._-]+/gi,
];

const failures = [];
for (const file of requiredFiles) {
  const path = resolve(root, file);
  try {
    const metadata = await stat(path);
    if (!metadata.isFile() || metadata.size === 0) failures.push(`${file}: missing or empty`);
  } catch {
    failures.push(`${file}: missing`);
  }
}

const webManifest = JSON.parse(
  await readFile(resolve(root, 'app/web/manifest.json'), 'utf8').catch(() => '{}'),
);
if (webManifest.orientation === 'landscape' || webManifest.orientation === 'landscape-primary') {
  failures.push('app/web/manifest.json: installed PWA must not force landscape orientation');
}

for (const [file, phrases] of requiredPhrases) {
  const text = await readFile(resolve(root, file), 'utf8').catch(() => '');
  for (const phrase of phrases) {
    if (!text.toLowerCase().includes(phrase.toLowerCase())) {
      failures.push(`${file}: required phrase not found: ${phrase}`);
    }
  }
}

for (const file of requiredFiles) {
  const text = await readFile(resolve(root, file), 'utf8').catch(() => '');
  for (const pattern of secretPatterns) {
    pattern.lastIndex = 0;
    if (pattern.test(text)) failures.push(`${file}: possible secret detected (${pattern})`);
  }
}

if (failures.length > 0) {
  console.error(JSON.stringify({ status: 'failed', failures }, null, 2));
  process.exitCode = 1;
} else {
  console.log(JSON.stringify({ status: 'passed', filesChecked: requiredFiles.length }, null, 2));
}
