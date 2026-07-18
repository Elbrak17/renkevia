# RENKEVIA

RENKEVIA is a hospital change compiler for medication shortages. It turns a messy institutional evidence set into one synchronized, provenance-linked patch, tests that patch against synthetic patient pathways, and holds the result for human approval.

This repository is being built for the OpenAI Build Week hackathon. Phases 0–1 froze the product, safety, evaluation, and demonstration contracts. The Flutter Web demo now implements the complete connected journey: the Response Room exposes a hidden pediatric dependency; the Patch Studio recompiles one typed Patch IR into six synchronized institutional artifacts; the Simulation Lab replays a sealed 24-pathway fixture until the candidate moves from one reproducible failure to 24/24 verified outcomes; the Evidence Vault seals four independent reviews, complete provenance, and exact rollback without erasing dissent; and a separate fictional no-API EHR sandbox stages the visual change, rechecks screen state, returns proof, and stops before final commit. The human approval gate remains explicit and locked. GPT-5.6 capability probes remain independently verifiable.

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
- **Legacy EHR sandbox** — a separate Flutter Web surface at `?surface=legacy-ehr`, used only for staged Computer Use, screen-state rechecks, and visual proof.

## Current verification

```bash
npm run verify:phase0
npm run probe:preflight
cd app
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```

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

## Status language

Repository documents distinguish **planned**, **scaffolded**, **probe-verified**, and **demo-verified** behavior. A capability is not described as working until a reproducible check exists.
