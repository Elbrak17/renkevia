# Evaluation plan

Status: preregistered plan plus an implemented network-free robustness suite. Targets are go/no-go thresholds for the hackathon prototype, not clinical-performance claims.

The versioned twelve-scenario **deterministic robustness suite** is implemented and currently passes 12/12 without network access. It covers the hidden population exception, a safe recompilation, evidence checksum drift, target-state drift, a missing system projection, ambiguous evidence, partial-stage rollback, uploaded prompt-injection text, duplicated evidence, incomplete specialist review, open legacy dissent/missing proof, and out-of-band staging drift. Reproduce the raw JSON with `npm run eval:deterministic`; the same suite is asserted in `server/test/deterministic-eval.test.ts`.

The comparative GPT baseline experiment has not been run because the project has no funded live evidence record. That limitation is explicit: 12/12 proves deterministic guard behavior, not model quality or superiority. Candidate `v0.7` produces one seeded failure at `PATH-PED-07-04/A1` (23/24 pathways and 95/96 assertions); revised `v0.8` produces 24/24 pathways and 96/96 assertions, with exact full and partial-stage rollback. Reproduce the vertical fixture with `npm run test:core` and `npm run demo:core`.

## Evaluation question

Does RENKEVIA produce a more complete, coherent, traceable, and reversible institutional patch than simpler approaches on synthetic medication-shortage scenarios—without bypassing human approval?

## Controlled baselines

All approaches receive the same corpus, token budget, artifact schemas, and time limit where applicable.

1. **Static checklist** — a hand-authored dependency checklist with keyword search.
2. **Naive model** — one GPT-5.6 Sol request over the corpus, asked to recommend changes in prose.
3. **Single-agent tools** — GPT-5.6 Sol with direct tools and schemas, but no Patch IR compiler, deterministic regression loop, or independent review.
4. **RENKEVIA** — routed models, typed Patch IR, deterministic projections/tests, independent review, provenance, and approval gates.

The purpose is not to prove one model better than another. It is to isolate the value of the system design.

## Synthetic scenario set

The implemented robustness suite spans:

- adult-only apparent scope with a hidden pediatric exception;
- alias mismatch across policy and order-set exports;
- contradiction between a scanned table and a newer change record;
- missing pump-library projection;
- ambiguous source with insufficient evidence;
- rollback after partial staging;
- prompt-injection text embedded in an uploaded artifact;
- duplicated evidence that must not inflate confidence;
- visually encoded table dependency through the seeded pediatric source identity;
- partial specialist-review failure;
- evidence/cache identity invalidation after a source update;
- legacy state drift between inspection and staging.

Hidden holdout scenarios remain a requirement for a real pilot. The hackathon robustness cases are public synthetic software tests and must not be described as blinded clinical evaluation.

## Ground truth

Each scenario has a machine-readable answer key containing:

- required dependency nodes and edges;
- required/forbidden Patch IR mutations;
- source-region identifiers for every supported claim;
- expected patient-test outcomes;
- required blockers and approval state;
- exact pre- and post-rollback hashes.

Ground truth is synthetic software truth, not clinical truth. A qualified clinical reviewer would be required before any real-world study.

## Metrics

| Metric | Definition | Direction |
|---|---|---|
| Critical dependency recall | Required critical graph edges found / all required critical edges | Higher |
| Unsupported mutation rate | Mutations without valid supporting source region / all mutations | Lower |
| Unsafe-exception miss rate | Required population exceptions not represented or tested | Lower |
| Artifact synchronization | Required targets whose deterministic projection matches the answer key | Higher |
| Provenance coverage | Material claims and mutations with valid source links | Higher |
| Regression sensitivity | Seeded unsafe variants correctly blocked | Higher |
| Regression specificity | Safe answer-key variants not incorrectly blocked | Higher |
| Rollback exactness | Rollbacks restoring the complete pre-patch hash set | Must be 100% |
| Approval integrity | Runs that never enable approval while a blocker exists | Must be 100% |
| Time to reviewable candidate | Wall-clock time to a complete candidate and test report | Lower |
| Human correction count | Manual corrections required before answer-key equivalence | Lower |

## Preregistered prototype gates

The vertical slice is not demo-ready unless it achieves all of the following on the synthetic suite:

- 100% approval integrity.
- 100% exact rollback on completed and partially staged runs.
- 100% detection of seeded critical hidden-population failures.
- 100% provenance coverage for material mutations shown in the demo.
- No secret or real patient datum in fixtures, logs, or recordings.
- RENKEVIA exceeds both naive baselines on critical dependency recall and artifact synchronization.

Targets may expose failure; they may not be rewritten after results merely to make the system pass. Any threshold change must be dated with a reason.

## Ablations

Run the RENKEVIA pipeline with each component removed in turn:

- no independent pediatric review;
- no adversarial auditor;
- no deterministic patient regression;
- no Patch IR, generating artifacts independently;
- no visual evidence ingestion;
- no prompt-cache breakpoint policy.

This demonstrates which GPT-5.6 features are causally useful rather than decorative.

## Reproducibility

- Version every fixture, schema, prompt, model ID, reasoning level, and tool definition.
- Persist request IDs, latency, token usage, cache indicators, and sanitized error classes.
- Pin deterministic seeds where the API permits; otherwise run multiple trials and report variance.
- Store raw machine-readable results before creating charts.
- Label replays, cached responses, and live generations distinctly.
- Never cherry-pick only successful runs for the submission.

## Current machine-readable result

As of 2026-07-20:

| Suite | Result | Scope |
|---|---:|---|
| Vertical pathway fixture | v0.7: 23/24; v0.8: 24/24 | One dramatic before/after scenario |
| Assertions | v0.7: 95/96; v0.8: 96/96 | Deterministic software checks |
| Robustness scenarios | 12/12 | Guard and failure-mode behavior |
| Comparative live GPT baselines | Not run | Requires a funded, version-pinned live run |

## Human evaluation

If time permits, conduct a structured walkthrough with at least three participants familiar with complex operational software. Measure time to answer:

1. What changed?
2. Why did it change?
3. Which patient pathway failed?
4. What remains disputed?
5. Can the patch be approved now?
6. How would it be rolled back?

This is a usability study, not clinical validation.
