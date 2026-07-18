# RENKEVIA deterministic core

This package is the trusted software boundary between model proposals and the
Flutter client. It contains no OpenAI client and performs no network calls.

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

The future GPT-5.6 adapter must emit `PatchIR` through a strict structured-output
contract and pass it to `validatePatchIR`. Model output never bypasses this core.
