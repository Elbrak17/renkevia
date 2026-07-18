# Design system contract

The interface should feel like a purpose-built institutional operations instrument: calm under pressure, evidence-dense, and unmistakably accountable. It must not resemble a generic AI chat app or a template analytics dashboard.

## Visual character

- **Canvas:** warm ivory rather than pure white.
- **Structure:** deep graphite panels and ink typography.
- **Interactive accent:** restrained cool cyan/teal.
- **Semantics:** amber for unresolved, vermilion for blocked/failed, green for verified.
- **Shape:** compact radii, precise separators, minimal shadows, visible alignment grid.
- **Motion:** state transitions explain causal change; no ambient decorative animation.

Final color tokens must meet WCAG AA for their actual text and background combinations. Semantic states always include an icon, label, pattern, or shape in addition to color.

## Information architecture

Primary navigation is the run’s lifecycle:

1. **Response Room** — incident, corpus, graph, scope.
2. **Patch Studio** — Patch IR, diffs, conflicts, reviews.
3. **Simulation Lab** — pathways, failures, coverage, rerun.
4. **Evidence Vault** — sources, audit, approvals, rollback.

A persistent run rail shows version, state, unresolved blockers, synthetic-data status, and next legal action.

## Signature views

### Response Room

Split workspace: evidence strip, central dependency graph, and contextual evidence inspector. Graph edges show relationship type, confidence, and source count. Uncertainty is rendered explicitly; dense nodes can be filtered without hiding blockers.

### Patch Studio

Three synchronized panes: Patch IR outline, artifact diff, and specialist review rail. Selecting any mutation highlights its affected artifacts, tests, sources, and dissent. Diff meaning is conveyed with words and line markers, not red/green alone.

### Simulation Lab

Patient-pathway matrix is the emotional center of the demo. Rows are stable synthetic pathway IDs; columns are patch assertions/artifact targets. A failure expands into input state, exact assertion, implicated mutation, and source. Recompile animates only the cells that causally changed.

### Evidence Vault

Append-only event timeline, source-region viewer, approval checklist, and exact rollback comparison. Export is secondary; audit comprehension is primary.

## Interaction rules

- No message composer on the default route.
- Every model-running action states scope, expected cost class, and cancelability.
- Loading shows named pipeline stages and preserves completed results.
- Empty states teach the next valid action without implying data exists.
- Partial/failure states remain inspectable and never collapse into a generic toast.
- Disabled approval always explains every blocker.
- Destructive reset requires confirmation and describes what synthetic run state is removed.
- Keyboard focus is visible; graph and matrix have list/table alternatives for assistive technology.

## Responsive targets

- Primary judged viewport: 1440×900.
- Desktop workspace: 920 px and above, with a persistent lifecycle rail.
- Tablet workspace: 600–919 px, with persistent bottom navigation and vertically composed inspectors.
- Mobile workspace: 320–599 px, with the same four reachable lifecycle surfaces, stacked metrics, vertical traces, and scroll-safe data regions.
- Northstar legacy target: the complete Computer Use operator console requires 900 px; smaller viewports show a readable status-and-safety companion rather than a broken miniature.

## Codex visual QA loop

For each signature view:

1. Implement from tokens and documented states.
2. Render at 1440×900, 1280×720, 768×1024, and 390×844.
3. Inspect screenshots for hierarchy, overflow, alignment, contrast, density, and misleading state.
4. Compare deterministic golden images for regressions.
5. Run keyboard and semantics checks.
6. Record the issue and exact correction when the review changes the design.

The final submission should show this loop as evidence of design quality achieved with Codex.

## Anti-patterns

- purple/blue gradient hero and glowing AI orb;
- grid of interchangeable rounded cards;
- fake terminal streams or fake agent thoughts;
- chat bubbles as the principal artifact;
- tiny gray text used to fit more content;
- permanently animated graph;
- unexplained confidence percentages;
- “all systems operational” before verification completes.
