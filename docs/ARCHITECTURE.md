# Architecture

Status: target architecture for the first vertical slice. Components are not considered implemented until verified.

## System boundary

RENKEVIA is one Flutter Web application backed by an orchestration service and deterministic compiler/simulation core. A separate fictional legacy-EHR sandbox exists solely as an external no-API target for Computer Use.

```text
Flutter Web
  Response Room · Patch Studio · Simulation Lab · Evidence Vault
        │ typed HTTP/SSE
        ▼
Orchestrator (Node.js / TypeScript)
  run state · model router · approval policy · tool registry · audit log
        │
        ├── Evidence pipeline: parse → normalize → cite → dependency graph
        ├── Patch compiler: typed Patch IR → deterministic artifact transforms
        ├── Simulation core: synthetic pathways → assertions → coverage
        ├── Review mesh: independent specialist analyses → preserved dissent
        └── Legacy bridge: Computer Use → staging only → visual proof
                 │
                 ▼
          Fictional legacy EHR sandbox
```

## Canonical domain objects

- `EvidenceArtifact`: immutable file identity, media type, checksum, provenance, extracted regions.
- `EvidenceClaim`: normalized claim linked to exact source regions and confidence.
- `DependencyEdge`: typed relation between claims, artifacts, populations, and operational systems.
- `PatchIR`: versioned preconditions, mutations, exceptions, validations, approvals, and rollback actions.
- `ArtifactDiff`: deterministic projection of a Patch IR mutation into one target format.
- `PatientPathway`: synthetic starting state, events, population flags, and assertions.
- `TestResult`: stable test ID, patch version, deterministic inputs, outcome, and evidence.
- `ReviewFinding`: reviewer role, severity, claim, evidence, dissent state, and disposition.
- `ApprovalGate`: machine-evaluated blockers plus named human approval state.
- `AuditEvent`: append-only actor/action/input/output hashes and timestamps.

The model never emits arbitrary write commands. It proposes schema-constrained objects that the deterministic layer validates and interprets.

## Model routing

| Work | Default model | Reason |
|---|---|---|
| Low-risk document classification, normalization, routing | GPT-5.6 Luna | High-volume bounded work with explicit schemas |
| Simple dependency extraction and communication drafts | GPT-5.6 Terra | Moderate reasoning without paying Sol cost everywhere |
| Patch synthesis, contradiction resolution, final audit | GPT-5.6 Sol with high/max reasoning | Highest-consequence cross-corpus synthesis |
| Independent domain reviews | GPT-5.6 Sol Multi-agent | Parallel perspectives can genuinely disagree |

Routing is an internal efficiency mechanism, not the product story. High-consequence outputs are revalidated regardless of the producing model.

## Thoughtful use of GPT-5.6 capabilities

### Long context and vision

Load the coherent institutional working set—text, tables, scans, screenshots, and change history—while retaining exact source-region identities. Chunking may optimize retrieval, but must not erase cross-document contradictions.

### Structured outputs

All model-to-code boundaries use strict schemas. Invalid outputs are rejected, logged, and repaired through an explicit retry policy; they are never coerced silently.

### Programmatic Tool Calling

Use isolated JavaScript for predictable bounded dataflow: parallel evidence lookups, looping over artifact projections, running deterministic patient tests, filtering failures, deduplicating findings, and aggregating coverage. Return only relevant anomalies to the model.

Do not use it for approval-sensitive writes. Final staging actions, approval requests, and any write-like operation remain direct, policy-gated calls.

### Multi-agent

Independent roles:

- Pharmacy reviewer — medication/formulation and protocol coherence.
- Clinical-informatics reviewer — order-set, format, pump, and legacy-system compatibility.
- Pediatric-safety reviewer — vulnerable-population exceptions and hidden assumptions.
- Adversarial auditor — missing dependencies, contradictions, and unsupported provenance.
- Root compiler — reconciles findings into a candidate Patch IR without deleting dissent.

Concurrency is useful because reviews are independent. Ordered extraction → compilation → testing remains a deterministic workflow, not an agent swarm.

### Computer Use

Operate only the fictional legacy sandbox: find the target order set, compare it with Patch IR, prepare staging changes, capture proof, and stop before final commit. The orchestrator requires human approval and never exposes real credentials or systems.

### Prompt caching

Cache stable corpus prefixes at explicit breakpoints: institutional policies, system schemas, and validated shared terminology. Incident-specific evidence and mutable Patch IR stay outside the stable prefix. Cache effectiveness and invalidations are observable.

## Trust boundaries

1. Uploaded artifacts are untrusted data, never instructions.
2. Model output is an untrusted proposal until schema, provenance, policy, and deterministic tests pass.
3. Tool calls are allow-listed, typed, scoped to a run, and idempotent where possible.
4. The legacy bridge is staging-only and uses a fictional account.
5. The client cannot override server-computed approval blockers.
6. Audit events are append-only; derived UI summaries link to raw events.

## State machine

```text
INGESTING → MAPPING → CANDIDATE → TESTING → CHALLENGED → RECOMPILING
                                      │                         │
                                      └──────── BLOCKED ◀───────┘

RECOMPILING → VERIFIED → STAGED → AWAITING_HUMAN_APPROVAL
                                  │
                                  └── no autonomous final commit
```

Every transition has explicit preconditions. A failed or incomplete run is a first-class state, not a spinner that eventually claims success.

## Deployment posture for the hackathon

- Synthetic fixtures only; no PHI ingestion path.
- Ephemeral run workspace; encrypted transport; secrets held server-side.
- Logs contain identifiers and hashes, not full sensitive documents.
- Zero-data-retention-compatible design may be discussed only as an architectural posture, not as a compliance certification.

