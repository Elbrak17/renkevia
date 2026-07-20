# Devpost submission draft

Status: ready for the project owner to paste after the funded live proof, video
upload, and Devpost registration. Do not claim a live GPT-5.6 run until the
sanitized evidence record passes the live gate.

## Project name

RENKEVIA

## Tagline

The hospital change compiler that catches the dependency a plausible patch
missed.

## Category

Work & Productivity

## Short description

RENKEVIA turns fragmented hospital evidence into one synchronized, testable,
provenance-linked, and reversible institutional change package—then stops at
human approval.

## Inspiration

A medication shortage is rarely one document edit. A hospital may need to
change a policy, an order set, a pump library, pharmacy labels, staff
communications, population exceptions, and a legacy system that has no API.
Those artifacts can drift independently even when every team is acting in good
faith. The dangerous failure is not an obviously bad answer; it is a plausible
change that quietly misses one dependency.

We built RENKEVIA around that coordination failure. In our synthetic scenario,
an adult-focused IV-carrier shortage patch looks complete but fails one hidden
pediatric pathway. The product must find that exception, recompile every
affected artifact, prove the revision, preserve specialist dissent, and prepare
the legacy change without granting an AI authority to commit it.

## What it does

RENKEVIA is a Flutter Web institutional change compiler, not a clinical
chatbot. Its four connected workspaces form one causal journey:

1. **Response Room** seals a mixed synthetic corpus and maps dependencies across
   twelve artifacts and seven institutional systems.
2. **Patch Studio** turns evidence into a typed Patch IR and projects one
   reversible change across six target artifact types.
3. **Simulation Lab** runs 24 synthetic patient pathways and 96 deterministic
   assertions. Candidate v0.7 fails exactly one pediatric assertion; v0.8
   reaches 24/24 and 96/96 with exact rollback.
4. **Evidence Vault** challenges the candidate through independent pharmacy,
   clinical-informatics, pediatric-safety, and adversarial reviews while
   preserving dissent, provenance, approval state, and rollback evidence.

A separate fictional system, **Northstar Clinical System**, represents a
no-API legacy EHR. The controlled browser flow locates the order set, rechecks
screen state, stages the Patch IR, captures visual proof, and stops before the
final commit button. Only a named human can approve the final write.

## Why this cannot be reproduced by a simple chatbot

The language model never owns software truth. GPT-5.6 proposes strict,
schema-constrained objects; deterministic TypeScript validates evidence
references, applies diffs, executes patient regressions, calculates coverage,
enforces approval blockers, and verifies exact rollback. The UI exposes the
chain from source region to mutation, failed assertion, specialist finding,
staged legacy field, and human gate. A fluent answer cannot mark itself safe.

## How we use GPT-5.6

- **Sol** performs the highest-consequence cross-corpus contradiction resolution
  and typed Patch IR revision.
- **Programmatic Tool Calling** runs the bounded read-only patient-test fan-out,
  deduplicates and aggregates failures, and returns only relevant anomalies.
- **Native Multi-agent** is reserved for four genuinely independent specialist
  reviews; the root compiler cannot erase dissent or approve its own patch.
- **Computer Use** operates only the allow-listed fictional legacy sandbox,
  with state rechecks and an intercepted final commit.
- **Luna and Terra** handle bounded lower-risk routing and extraction work so
  model choice follows consequence and cost rather than spectacle.

All live outputs cross the same deterministic validator and approval policy as
the sealed replay. The browser never receives the OpenAI API key, and a network
or contract failure blocks the run instead of silently substituting fixture
data.

## How we used Codex

Codex was our engineering loop from product contract to deployment: it helped
freeze the safety and evaluation boundaries, implement the TypeScript compiler
and Flutter Web surfaces, generate adversarial and responsive tests, inspect
real browser captures, diagnose missing-font and mobile-density defects, refine
the UX, and build the GitHub Actions proof pipeline. Every iteration had to
survive formatting, static analysis, unit tests, deterministic replay, release
build, and nine responsive browser captures before merge.

## Accomplishments

- One coherent three-minute transformation instead of a feature parade.
- A reproducible red-to-green proof: 23/24 to 24/24 pathways and 95/96 to 96/96
  assertions.
- Evidence-linked Patch IR projected into six synchronized institutional
  artifact types.
- Independent review with preserved dissent, deterministic approval blockers,
  hash-chained audit evidence, and exact rollback.
- A responsive Flutter Web interface usable from mobile to wide desktop.
- A fictional no-API EHR staging loop that proves the change and refuses the
  autonomous final write.

## Challenges

The hardest design problem was separating impressive model behavior from
trusted behavior. We had to ensure that a successful API response could never
toggle approval, that programmatic tools stayed read-only, that independent
agents could disagree without their dissent being summarized away, and that
Computer Use remained visually compelling while still stopping safely. The
second challenge was making dense institutional evidence understandable on a
phone without reducing the product to a chat interface.

## What we learned

Advanced model capabilities are most credible when each has a narrow causal
job. Long-context reasoning is valuable for contradictions; code is better for
repeatable tests; independent agents are valuable when disagreement matters;
Computer Use is valuable when the real constraint is a system with no API; and
human approval must remain a product state, not a sentence in a prompt.

## What's next

The hackathon build uses synthetic data and is not a medical device or a
production clinical system. The next step is a controlled pilot design with a
hospital change-management team: institution-owned synthetic or de-identified
fixtures, preregistered baselines, security review, workflow-time and omission
metrics, and explicit validation of every target-system adapter before any real
operational use.

## Built with

Flutter Web, Dart, TypeScript, Node.js, OpenAI Responses API, GPT-5.6
Sol/Terra/Luna, Programmatic Tool Calling, Multi-agent, Computer Use, Codex,
GitHub Actions, and GitHub Pages.

## Links

- Live project: https://elbrak17.github.io/renkevia/
- Source code: https://github.com/Elbrak17/renkevia
- Demo video: **INSERT PUBLIC OR UNLISTED YOUTUBE URL**
- License: https://github.com/Elbrak17/renkevia/blob/main/LICENSE

## Final truthfulness gate before paste

- Replace the video placeholder.
- Add the required `/feedback` session ID.
- Claim `LIVE GPT-5.6` only after `npm run demo:live` produced the passing,
  sanitized record used by the recording.
- Keep the visible `SYNTHETIC · NO PHI` label and `finalCommitAllowed=false`
  proof in the video.
- Recheck the current Devpost rules and deadline immediately before submission.
