# RENKEVIA experience contract

Status: implemented direction for the judge-ready Flutter Web surface.

## The person, the pressure, the decision

The primary user is a medication-safety or clinical-informatics lead coordinating an urgent institutional change. They are not debugging an agent run. On every screen they must be able to answer, in this order:

1. What changes?
2. What prevents approval?
3. What decision is required from me now?

Technical identifiers, hashes, Patch IR fields, tool traces, and raw audit events remain available as proof, but they never own the first visual level.

## Product language

| Product surface | User-facing navigation | Primary job |
|---|---|---|
| Response Room | **Impact review** | Understand the blast radius and hidden exceptions |
| Patch Studio | **Change plan** | Synchronize one reviewed rule across every target |
| Simulation Lab | **Safety checks** | Reproduce the failure and prove the revision against the same cases |
| Evidence Vault | **Approval record** | Review specialist conclusions, dissent, provenance, rollback, and the human gate |

Northstar Clinical System is the fictional no-API legacy target. It is never presented as another name for RENKEVIA.

## Progressive disclosure

Every signature page has three intentional levels:

- **Decision:** one strong outcome sentence, current state, decisive alert, four human-readable facts, and one next action.
- **Evidence:** the user’s workflow path plus the source, change, case, or review that explains the state.
- **Specialist proof:** Patch IR, stable IDs, exact diffs, source regions, hashes, and raw audit records for inspectors and judges.

This hierarchy prevents the previous console effect: operational proof is retained without forcing a user to decode it before understanding the decision.

## Visual direction: clinical decision room

The interface is derived from a real high-stakes change room rather than a generic AI dashboard:

- porcelain and brushed-steel work surfaces;
- dark instrument glass for persistent navigation;
- sterile teal for the connected dependency path;
- chart-paper amber for unresolved human work;
- restrained red and green for blocked and verified states.

The application deliberately avoids the common AI palette of purple gradients, glowing orbs, warm editorial beige, and interchangeable card grids. Depth is whisper-quiet and layered; borders are structural, not decorative.

### Core tokens

| Role | Token |
|---|---|
| Canvas | `#F2F5F2` |
| Raised surface | `#FFFFFF` |
| Instrument glass | `#10211F` |
| Primary ink | `#172522` |
| Secondary ink | `#43534F` |
| Dependency teal | `#28B8AA` / dark `#08736C` |
| Human attention | `#D99A2B` |
| Blocked | `#BF493F` |
| Verified | `#247B58` |

The main display face is a bundled sans family so screenshots remain readable without a network font. Display text is 46 px desktop / 30 px compact; normal product text is 13–15 px. Dense specialist proof may descend to 11 px only when an adjacent plain-language summary exists.

## Signature identity

The `R` is a custom vector path, not a glyph in a square. A single dependency line constructs its stem, bowl, and leg. Teal nodes show linked institutional targets; the amber terminal node represents the human approval boundary. The same connected-line grammar appears in the decision hero and journey trace, making synchronization—not “AI magic”—the recognizable brand asset.

## Interaction rules

- One primary action per screen; all primary controls are at least 48 px high.
- Navigation labels never disappear on mobile; touch targets are at least 48 px.
- States never rely on color alone: each includes a label and icon.
- Disabled approval explains every remaining blocker.
- Model or network failure is blocking and inspectable; it never silently becomes fixture success.
- Final legacy commit is never enabled by the prototype.
- Loading names the work being done and preserves already-completed proof.
- Motion is causal and brief; there is no ambient animation.
- Uploaded content is shown as untrusted evidence, never as instructions.

## Responsive contract

| Viewport | Composition |
|---|---|
| 1260 px and wider | Full 224 px lifecycle navigation, decision hero, three-pane specialist workspaces |
| 920–1259 px | Compact rail, readable hero, two-stage inspectors |
| 600–919 px | Persistent labeled bottom navigation and vertically composed evidence |
| 320–599 px | Single-column decision flow, two-column facts when space allows, full-width actions and scroll-safe data regions |

Northstar’s operator console requires 900 px because it intentionally simulates a legacy desktop. Smaller devices receive a readable status-and-safety companion instead of a broken miniature.

## Accessibility and trust

- Meaningful imagery and the bespoke mark expose semantics; decorative traces do not.
- Alerts use live regions and action labels describe consequences.
- Focus remains visible through Material interaction states.
- Text scaling is respected in primary decision surfaces.
- Synthetic/no-patient-data status persists across every workspace.
- Reduced-motion behavior is honored by the static boot experience; product motion remains nonessential.

## Codex visual QA loop

GitHub Actions builds the release and captures all four product surfaces at desktop and mobile, plus a tablet checkpoint. Codex inspects the real PNG artifacts for hierarchy, overflow, alignment, contrast, clipped labels, blank canvases, and misleading state. A correction is merged only after static analysis, widget tests, deterministic server tests, and the browser capture pipeline pass.

Widget goldens from the earlier console-style interface are intentionally not treated as the new baseline. The release-browser captures are the current visual-regression source until the premium Flutter rendering is reviewed and the golden set is regenerated deliberately.

## Rejected patterns

- developer-first run consoles and raw metrics above the decision;
- chat composer as the main interaction;
- fake agent thoughts, terminal streams, or unexplained confidence scores;
- tiny gray labels used to make density fit;
- decorative neumorphism, glassmorphism, gradients, or excessive pills;
- permanent graph animation;
- “all systems operational” before deterministic checks and human review finish.
