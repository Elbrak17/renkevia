# RENKEVIA

RENKEVIA is a hospital change compiler for medication shortages. It turns a messy institutional evidence set into one synchronized, provenance-linked patch, tests that patch against synthetic patient pathways, and holds the result for human approval.

This repository is being built for the OpenAI Build Week hackathon. It is currently in phase 0: the product, demonstration, architecture, safety, design, and evaluation contracts are frozen before implementation begins.

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
- **Patch Studio** — Patch IR, synchronized diffs, conflicts, and specialist reviews.
- **Simulation Lab** — synthetic patient pathways, red-to-green regression matrix, and counterexamples.
- **Evidence Vault** — provenance, approvals, rollback, and audit export.
- **Legacy EHR sandbox** — a separate fictional no-API website used only for staged Computer Use.

## Current verification

```bash
npm run verify:phase0
```

## Core documents

- [Product contract](docs/PRODUCT_CONTRACT.md)
- [Demo contract](docs/DEMO_CONTRACT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Hackathon criteria matrix](docs/HACKATHON_MATRIX.md)
- [Evaluation plan](docs/EVALS.md)
- [Safety and security](docs/SAFETY.md)
- [Design system](docs/DESIGN_SYSTEM.md)
- [Risk register](docs/RISK_REGISTER.md)

## Status language

Repository documents distinguish planned and implemented behavior. A capability is not described as working until a reproducible check exists.
