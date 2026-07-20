# RENKEVIA

RENKEVIA is a hospital change compiler for medication shortages. It turns a messy institutional evidence set into one synchronized, provenance-linked patch, tests that patch against synthetic patient pathways, and holds the result for human approval.

This repository is being built for the OpenAI Build Week hackathon. Phases 0–1 froze the product, safety, evaluation, and demonstration contracts. The Flutter Web demo implements the complete connected journey: the Response Room exposes a hidden pediatric dependency; the Patch Studio presents one typed Patch IR across six synchronized institutional artifacts; the Simulation Lab shows the sealed 24-pathway fixture; the Evidence Vault preserves review dissent, provenance, and rollback; and a separate fictional no-API EHR sandbox stages the visual change and stops before final commit.

The TypeScript core makes that visual story executable. Candidate `v0.7` compiles six evidence-backed projections and reproducibly fails only `PATH-PED-07-04/A1` (23/24 pathways, 95/96 assertions). Revised `v0.8` recompiles twelve field projections and reaches 24/24 pathways, 96/96 assertions, 100% provenance coverage, and exact complete or partial-stage rollback. A twelve-scenario robustness suite exercises additional failure modes without network access. A guarded GPT-5.6 adapter routes Luna/Terra/Sol, validates structured Patch IR, runs program-only patient tools, preserves four-way Multi-agent dissent, and intercepts the fictional final Computer Use commit. Live capability evidence still requires funded API access; deterministic replay is always labeled honestly.

## The transformation

```text
shortage notice + hospital corpus + synthetic cases
                    │
                    ▼
dependency graph → Patch IR → synchronized artifact diffs
                    │
                    ▼
deterministic regression suite → specialist audits → human approval
                    │
                    ▼
staged legacy-EHR change + visual proof + rollback package
```

The primary demo proves a hidden pediatric dependency is detected before a proposed institution-wide change can be approved. RENKEVIA is not a clinical chatbot: deterministic code owns diff application, regression tests, coverage, and approval gates.

## Product surfaces

- **Impact review** — evidence ingestion, institutional blast radius, and hidden dependencies.
- **Change plan** — one synchronized rule, exact diffs, and cross-artifact conflicts.
- **Safety checks** — synthetic patient pathways, red-to-green regression matrix, and counterexamples.
- **Approval record** — independent specialist reviews, preserved dissent, provenance, approvals, rollback, and audit export.
- **Northstar Clinical System** — the fictional legacy EHR sandbox at `?surface=legacy-ehr`, used only for staged Computer Use, screen-state rechecks, and visual proof. Northstar is a target system, not the product name.

RENKEVIA is usable from mobile through wide desktop. Below 920 px, the four workspaces become vertically composed and use persistent bottom navigation. Northstar preserves a readable status-and-safety companion below 900 px, while its deliberately dense Computer Use operator console remains desktop-only.

## Current verification

```bash
npm install
npm run check:offline
npm run demo:core
npm run eval:deterministic
npm run impact:scenario
npm run verify:phase0
npm run probe:preflight
cd app
flutter analyze
flutter test
flutter build web --release
```

## Run modes

The public Flutter Web build starts in honest, zero-cost `FIXTURE REPLAY` mode.
For the server-computed path, run the API and compile Flutter with its base URL:

```bash
npm run serve:api
cd app
flutter run -d chrome \
  --dart-define=RENKEVIA_API_BASE_URL=http://127.0.0.1:8787
```

The interface then displays `CONNECTED CORE` at every viewport. It treats a
network or contract failure as blocking and never silently substitutes replay
data. The OpenAI key remains exclusively on the server.

For the final funded proof, enable the guarded server live mode and add
`--dart-define=RENKEVIA_LIVE_REASONING=true` to the Flutter command. The v0.8
action then runs Patch IR synthesis, Programmatic Tool Calling, and native
Multi-agent audit through the real API. The header changes to `LIVE GPT-5.6`;
later screens reveal the exact proof returned by that run rather than issuing
duplicate paid calls.

The bounded paid-account proof is a separate command:

```bash
LIVE_OPENAI_ENABLED=true npm run demo:live
```

It reserves worst-case cost before network access, performs no automatic retry,
and saves only sanitized evidence. Do not enable it until the API project is
funded and the configured run/total limits have been reviewed.

The custom Flutter bootstrap serves CanvasKit from the build itself, so the demo does not depend on a renderer CDN at judging time. The deployment also retires historical Flutter service workers and shows a branded recovery surface while the engine starts; this fixes the stale-cache loop that could appear when the Pages URL was typed directly in an older browser session.

Live probes require `OPENAI_API_KEY` in the environment. Never paste a key into source, a fixture, an issue, or chat.

## Public verification documents

- [Architecture](docs/ARCHITECTURE.md)
- [GPT-5.6 capability matrix](docs/CAPABILITY_MATRIX.md)
- [Evaluation plan](docs/EVALS.md)
- [Safety and security](docs/SAFETY.md)
- [Design system](docs/DESIGN_SYSTEM.md)
- [Design research and skill provenance](docs/DESIGN_RESEARCH.md)
- [Codex build log](docs/CODEX_BUILD_LOG.md)
- [Impact model](docs/IMPACT_MODEL.md)
- [Dated differentiation scan](docs/DIFFERENTIATION.md)
- [Proof manifest](docs/PROOF_MANIFEST.md)
- [Pinned application toolchain](docs/TOOLCHAIN.md)
- [Deterministic core](server/README.md)

Internal product contracts, budget planning, risk tracking, demo narration and
submission working documents are deliberately maintained outside the public
repository. They are not required to run, inspect or reproduce the prototype.

## Status language

Repository documents distinguish **planned**, **scaffolded**, **probe-verified**, and **demo-verified** behavior. A capability is not described as working until a reproducible check exists.

## License

RENKEVIA is released under the [MIT License](LICENSE).
