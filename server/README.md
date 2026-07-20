# RENKEVIA deterministic core

This package contains both the trusted deterministic boundary and a separate,
untrusted OpenAI orchestration adapter. Only the adapter can perform network
calls; every proposal must cross back through the deterministic boundary.

Implemented in this slice:

- strict structural and semantic validation for `renkevia.patch-ir/v1`;
- deterministic compilation into six synthetic institutional projections;
- evidence-linked diffs and measurable provenance coverage;
- 24 synthetic patient pathways with 96 deterministic assertions;
- complete and partial-stage rollback with exact state-hash verification;
- a hash-chained append-only audit ledger that stores hashes rather than corpus content;
- a server-owned approval gate that preserves dissent and never authorizes a
  final legacy-system commit.

The fixtures use opaque synthetic tokens. They are software truth for the demo,
not clinical instructions or medical claims.

## Commands

From the repository root:

```bash
npm run typecheck:core
npm run test:core
npm run demo:core
npm run check:offline
```

The GPT-5.6 adapter emits `PatchIR` through a strict structured-output contract
and passes it to `validatePatchIR`, provenance resolution, compilation, and
simulation. Programmatic tools are read-only, Multi-agent dissent is preserved,
and Computer Use stops before the fictional final-commit control.
