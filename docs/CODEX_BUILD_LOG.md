# How Codex shaped RENKEVIA

This is an evidence map, not a claim that Codex autonomously invented or approved the product. The project owner set the ambition, selected Flutter Web, rejected weak concepts and console-like UI, required a custom identity, and retained all product and safety decisions. Codex converted those decisions into repository artifacts, tests, visual inspections, and deployable changes.

## Human decisions and Codex execution

| Decision owned by the project owner | Work performed with Codex | Repository proof |
|---|---|---|
| Begin with a credible problem, not a model-feature parade | Converted the hospital change problem into product, demo, safety, and architecture contracts | `PRODUCT_CONTRACT.md`, `DEMO_CONTRACT.md`, `ARCHITECTURE.md` |
| Flutter Web only | Built a four-surface responsive Flutter Web application and GitHub Pages pipeline | `app/`, `pages.yml` |
| GPT-5.6 must do causal work a chatbot cannot | Implemented strict Patch IR, model routing, programmatic pathway fan-out, independent Multi-agent review, and Computer Use staging boundary | `server/src/openai/`, orchestration tests |
| A model cannot own clinical or software truth | Implemented deterministic compilation, provenance validation, 96 assertions, rollback, audit chain, and approval policy | `server/src/core/`, deterministic tests |
| Northstar is a fictional target, not the product | Separated the legacy EHR route and preserved a no-final-commit state | `legacy_ehr_sandbox_page.dart`, Computer Use tests |
| The first UI looked like a debugging console | Audited the rendered captures, fused six design references, rebuilt hierarchy around a user decision, and created a custom R dependency mark | `DESIGN_RESEARCH.md`, `decision_surface.dart`, `renkevia_brand.dart` |
| Typed GitHub Pages URL must load reliably | Diagnosed historical Flutter service-worker cache behavior and added a one-release cleanup shim plus branded boot/recovery UI | `index.html`, `flutter_bootstrap.js`, `write-service-worker-cleanup.mjs` |

## Verifiable iteration trail

The Git history preserves small corrective steps rather than one unexplained code dump. Examples include the deterministic compiler (`1c462d9`), guarded orchestration (`8b52bcb`), connected Flutter core (`ea918b2`), browser-proof CI (`0eb88db`), mobile density and label fixes (`cc668c5`, `90be5ff`, `d5b8f7d`), and judge-ready submission copy (`499924f`).

The current premium pass adds a user-oriented decision surface, custom identity, historical service-worker retirement, a twelve-scenario robustness suite, and explicit impact/differentiation evidence. Its exact commit and browser screenshots are filled by GitHub when the branch passes review.

## Quality loop

1. Freeze an explicit acceptance contract.
2. Implement the smallest causal vertical slice.
3. Add deterministic and adversarial tests before claiming the behavior.
4. Build the actual Flutter Web release.
5. Capture desktop, tablet, and mobile browser PNGs from that release.
6. Inspect hierarchy, text rendering, overflow, trust signals, and state truthfulness.
7. Correct the implementation and rerun the complete pipeline.

The loop has already caught missing-font squares, mobile metric truncation, hidden navigation labels, stale service-worker loading, overly technical page hierarchy, and a generic logo. Those defects were treated as product correctness failures, not cosmetic comments.

## Truthfulness boundary

Codex helped implement and test the guarded GPT-5.6 path, but no funded live API result is claimed until `npm run demo:live` produces a sanitized passing record. Fixture replay, deterministic core execution, connected core execution, and live GPT-5.6 execution are labeled as different modes in the UI and documentation.
