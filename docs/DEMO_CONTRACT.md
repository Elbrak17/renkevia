# Demonstration contract

The final video must remain below three minutes and use a fully deterministic synthetic fixture. Product behavior and narration must be understandable without reading the submission text.

## Scenario

Fictional institution: **Northstar University Hospital**. Fictional vendor names only.

Incident: a synthetic high-volume infusion-supply shortage arrives while the hospital corpus contains inconsistent naming, an outdated protocol image, a legacy order set, a pump-library fragment, a pediatric exception table, and a prior change record.

No real dose, treatment recommendation, or patient data appears. Values are clearly marked synthetic and are chosen to demonstrate software behavior rather than clinical practice.

## Required beats

| Time | Visual proof | Narration purpose |
|---|---|---|
| 0:00–0:18 | Shortage notice lands; affected surface count expands into a dependency graph | Establish the credible problem and institutional blast radius |
| 0:18–0:45 | RENKEVIA reads mixed artifacts and constructs evidence-linked graph edges | Show multimodal/long-context comprehension, not chat |
| 0:45–1:12 | Patch IR compiles synchronized diffs across six artifact types | Show one source of truth and structured transformation |
| 1:12–1:38 | Synthetic regression matrix turns red on a hidden pediatric pathway | Create the decisive safety failure |
| 1:38–2:03 | Specialist audits challenge the patch; source region opens; root recompiles | Show independent reasoning and preserved dissent |
| 2:03–2:28 | Matrix turns green; provenance and rollback become complete | Demonstrate measurable transformation and reversibility |
| 2:28–2:46 | Computer Use stages the patch in the fictional legacy EHR and stops before final commit | Complete the document-to-legacy loop with human control |
| 2:46–2:58 | Judge view: before/after metrics and explicit approval gate | Land impact, design, and responsible deployment |

## On-screen proof obligations

- The source and affected graph node are visible together at least once.
- A real structured diff is shown; avoid animated fake text.
- The failing test has a stable ID and can be reproduced from the fixture.
- The revised patch visibly changes the relevant artifact and test result.
- Specialist dissent remains inspectable after synthesis.
- The legacy sandbox shows a cursor/action trace and a visible “awaiting human approval” stop.
- A small “synthetic demonstration” label remains visible throughout clinical surfaces.
- Codex contribution is explained with actual repository artifacts, tests, and visual QA—not a claim alone.

## Demo reliability

- Pre-seed the fixture and cache expensive invariant analysis.
- Record a clean deterministic run, but keep a live runnable path for judges.
- Provide a reset control that restores the entire fixture.
- Do not depend on external hospital sites or unpredictable third-party pages.
- Gracefully surface model/tool failure and offer fixture-backed replay clearly labeled as a replay.
- Keep a no-audio-dependent visual story while still meeting the required narrated-video rule.

## What the demo must never imply

- That RENKEVIA made a clinical recommendation.
- That the synthetic patch is valid for a real hospital.
- That an AI clicked the final production commit.
- That all specialist agents independently verified a fact when they reused the same unsupported assertion.
- That cached or fixture-backed output was generated live if it was not.
