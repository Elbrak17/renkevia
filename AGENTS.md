# RENKEVIA working agreement

## Mission

Build a judge-ready Flutter Web prototype that proves one coherent transformation:

> A medication-shortage notice becomes a synchronized, provenance-linked hospital change package that is regression-tested on synthetic patient pathways and held for human approval.

The product is a change compiler and safety workbench, not a chatbot and not a clinical decision-maker.

## Product invariants

- Flutter Web is the only user-facing RENKEVIA client. Do not create an APK.
- The fictional legacy EHR is a separate browser sandbox used to demonstrate Computer Use; it is not a second product.
- All hospital data, patients, vendors, policies, labels, screenshots, and incidents are synthetic.
- Never present output as medical advice, a prescription, or an autonomous clinical decision.
- Deterministic code applies diffs, runs tests, calculates coverage, and enforces approval gates.
- GPT-5.6 may propose and critique changes, but it never performs the final sensitive write.
- A human must approve the final patch. The demo must stop before any final legacy-EHR commit.
- Every material change must be traceable to source evidence, an actor, a model/tool invocation, and a reversible diff.
- Do not claim HIPAA compliance, clinical validation, production readiness, or benchmark wins without evidence.
- Do not add features that do not strengthen the shortage-to-validated-patch story.

## Technical direction

- Client: Flutter Web, responsive from 1280x720 upward, keyboard accessible.
- Backend/orchestrator: TypeScript on Node.js unless a documented constraint proves a better choice.
- API: OpenAI Responses API with GPT-5.6 family models.
- Model routing: Luna for low-risk normalization; Terra for bounded extraction/drafting; Sol for patch synthesis, contradiction resolution, and final audit.
- Use Programmatic Tool Calling only for bounded orchestration and aggregation.
- Use Multi-agent only for genuinely independent specialist reviews.
- Use structured outputs at every model-to-code boundary.
- Keep clinical-policy reasoning separate from deterministic artifact transforms and simulation.
- No secret may enter source control, logs, screenshots, fixtures, or demo recordings.

## Design direction

- High-trust clinical operations aesthetic: graphite, warm ivory, restrained cyan, semantic amber/red/green.
- The dependency graph, synchronized diff, provenance trail, and patient regression matrix are primary UI objects.
- Chat is never the hero or the main navigation metaphor.
- Prefer information density with clear hierarchy over decorative gradients and generic cards.
- Every critical color state must have a non-color cue.

## Definition of done for each slice

1. The change is tied to a documented demo beat or evaluation.
2. Behavior has an automated test where feasible.
3. Loading, empty, success, partial, and failure states are intentional.
4. UI changes are rendered at target viewport sizes and visually inspected.
5. Safety, provenance, and approval invariants still hold.
6. Documentation reflects actual behavior, not planned behavior.
7. The commit is scoped, named clearly, and leaves the repository runnable.

## Verification commands

Use the commands that exist for the current phase; never report a check as passed if it was skipped.

```bash
npm run verify:phase0
npm run probe:preflight
```

When Flutter and the backend are added, extend this section with the canonical format, lint, test, golden-test, and build commands.
