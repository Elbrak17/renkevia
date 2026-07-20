# RENKEVIA demo script — 2:55 target

The recording must show the product, not presentation slides. Every patient,
hospital, policy, label, scan, and incident is synthetic.

## 0:00–0:20 — The institutional failure

Open **Response Room** on the sealed incident. Say: “A medication shortage is
not one document change. It is a synchronized hospital change across policy,
order set, pump library, label, communication, and a legacy system.” Show the
mixed corpus and dependency graph. Trigger compilation.

## 0:20–0:45 — The credible blocker

The v0.7 candidate reaches 23/24 pathways and 95/96 assertions. Open the sole
failure `PATH-PED-07-04/A1` and its scanned `SRC-006` pediatric evidence. Say:
“RENKEVIA refuses the plausible adult-only patch because one hidden population
exception would drift.” Approval remains locked.

## 0:45–1:15 — GPT-5.6 as a constrained compiler

Open **Patch Studio**. Recompile v0.8. Show one typed Patch IR projected into
six evidence-linked institutional artifacts and the reversible diff. Explain
briefly: Sol resolves the cross-corpus contradiction; deterministic code owns
schema validation, mutation application, provenance, and rollback.

## 1:15–1:40 — Programmatic proof

Open **Simulation Lab** and run the candidate. Show 24/24 pathways, 96/96
assertions, the red-to-green pediatric case, and exact rollback. Say:
“A hosted JavaScript program calls each read-only patient test once, aggregates
the failures, and is cross-checked against our software simulation engine.”

## 1:40–2:10 — Independent challenge, not agent theatre

Open **Evidence Vault**. Run the four specialist reviews: pharmacy, clinical
informatics, pediatric safety, and adversarial audit. Show the preserved
clinical-informatics dissent. Say: “Native Multi-agent is used only where the
reviews are independent. The root cannot delete dissent or approve its own
patch.”

## 2:10–2:40 — Documents to a no-API legacy system

Open **Northstar Clinical System**, visibly labeled fictional. Show Computer Use
finding the order set, comparing v0.8, staging the fields, and capturing visual
proof. Stop on the final commit control. Say: “The browser harness allow-lists
this isolated origin. It stages and proves; it never commits.”

## 2:40–2:55 — Transformation and close

Return the proof to Evidence Vault. Show approval unlocked for a named human
while `finalCommitAllowed` remains false. Close with: “RENKEVIA turns fragmented
institutional evidence into one testable, reviewable, reversible change package
— a workflow a chatbot cannot reproduce.”

## Recording truthfulness

- Show the header mode: `FIXTURE REPLAY` for deterministic rehearsal,
  `CONNECTED CORE` for the server-computed fixture, or `LIVE GPT-5.6` only when
  the funded reasoning endpoint produced the proof held by the UI.
- Do not label replay as a fresh GPT call.
- A live GPT-5.6 run may be shown only after `npm run demo:live` saves a passing
  sanitized evidence record.
- Never show a secret, billing page, real hospital data, or final commit.
