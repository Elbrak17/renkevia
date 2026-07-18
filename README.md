# RENKEVIA

RENKEVIA is a hospital change compiler for medication shortages. It turns a messy institutional evidence set into one synchronized, provenance-linked patch, tests that patch against synthetic patient pathways, and holds the result for human approval.

This repository is being built for the OpenAI Build Week hackathon. Phases 0–1 froze the product, safety, evaluation, and demonstration contracts. The Flutter Web demo implements the complete connected journey: the Response Room exposes a hidden pediatric dependency; the Patch Studio presents one typed Patch IR across six synchronized institutional artifacts; the Simulation Lab shows the sealed 24-pathway fixture; the Evidence Vault preserves review dissent, provenance, and rollback; and a separate fictional no-API EHR sandbox stages the visual change and stops before final commit.

The TypeScript deterministic core now makes that visual story executable. Candidate `v0.7` compiles six evidence-backed projections and reproducibly fails only `PATH-PED-07-04/A1` (23/24 pathways, 95/96 assertions). Revised `v0.8` recompiles twelve field projections and reaches 24/24 pathways, 96/96 assertions, 100% provenance coverage, and exact complete or partial-stage rollback. The server-owned approval policy can expose a human approval control only after every blocker clears; it can never authorize a final legacy-system commit. GPT-5.6 capability probes remain separate and require real API access.

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

- **Response Room** — evidence ingestion, incident scope, and dependency map.
- **Patch Studio** — Patch IR, synchronized diffs, and cross-artifact conflicts.
- **Simulation Lab** — synthetic patient pathways, red-to-green regression matrix, and counterexamples.
- **Evidence Vault** — independent specialist reviews, preserved dissent, provenance, approvals, rollback, and audit export.
- **Northstar Clinical System** — the fictional legacy EHR sandbox at `?surface=legacy-ehr`, used only for staged Computer Use, screen-state rechecks, and visual proof. Northstar is a target system, not the product name.

RENKEVIA is usable from mobile through wide desktop. Below 920 px, the four workspaces become vertically composed and use persistent bottom navigation. Northstar preserves a readable status-and-safety companion below 900 px, while its deliberately dense Computer Use operator console remains desktop-only.

## Current verification

```bash
npm install
npm run check:offline
npm run demo:core
npm run verify:phase0
npm run probe:preflight
cd app
flutter analyze
flutter test
flutter build web --release
```

The custom Flutter bootstrap serves CanvasKit from the build itself, so the demo does not depend on a renderer CDN at judging time.

Live probes require `OPENAI_API_KEY` in the environment. Never paste a key into source, a fixture, an issue, or chat.

## Core documents

- [Product contract](docs/PRODUCT_CONTRACT.md)
- [Demo contract](docs/DEMO_CONTRACT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [GPT-5.6 capability matrix](docs/CAPABILITY_MATRIX.md)
- [Hackathon criteria matrix](docs/HACKATHON_MATRIX.md)
- [Evaluation plan](docs/EVALS.md)
- [Safety and security](docs/SAFETY.md)
- [Design system](docs/DESIGN_SYSTEM.md)
- [Risk register](docs/RISK_REGISTER.md)
- [API budget and truthfulness contract](docs/API_BUDGET.md)
- [Deterministic core](server/README.md)

## Status language

Repository documents distinguish **planned**, **scaffolded**, **probe-verified**, and **demo-verified** behavior. A capability is not described as working until a reproducible check exists.

## License

RENKEVIA is released under the [MIT License](LICENSE).
