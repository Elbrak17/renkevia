# Product contract

Status: frozen for the first vertical slice. Changes require a recorded product decision.

## Problem

A medication shortage is not one document edit. It can force coupled changes across protocols, order sets, pump configurations, pediatric exceptions, labels, pharmacy operations, communications, and a legacy EHR. Today, specialists often discover those dependencies through meetings, memory, spreadsheets, and manual cross-checking. A locally correct edit can therefore create an institution-wide inconsistency.

The core problem is **safe institutional change compilation under incomplete, heterogeneous evidence**.

## User and job

Primary user: the incident lead or clinical-informatics pharmacist coordinating a shortage response in a large hospital.

Their job:

> Given an urgent shortage and a disorderly institutional corpus, construct one reviewable and reversible change package, expose every affected dependency, prove it against representative patient pathways, and obtain accountable approval without silently changing a live system.

Supporting reviewers are pharmacy, clinical informatics, pediatric safety, and governance/quality.

## Product promise

RENKEVIA compiles institutional evidence into a typed **Patch IR**; generates synchronized candidate diffs; tests them against deterministic synthetic patient pathways; invites independent specialist challenge; preserves provenance; and stops at a human approval gate.

It compresses coordination, not clinical accountability.

## Demo-scale input

- One synthetic shortage notice.
- A deliberately inconsistent fictional hospital corpus containing policies, tables, scans, screenshots, labels, order-set exports, pump-library fragments, change history, and communications.
- A set of synthetic adult and pediatric patient pathways.
- One fictional legacy EHR with no API.

## Demo-scale output

- A dependency graph with evidence-backed edges and unresolved uncertainty.
- A typed Patch IR with preconditions, mutations, exceptions, tests, approvals, and rollback.
- Synchronized candidate diffs for the policy, order set, pump-library fragment, label, communication, and legacy EHR staging record.
- A regression report that changes from unsafe to acceptable after a hidden dependency is resolved.
- Parallel specialist reviews with agreement and dissent preserved.
- A provenance bundle and exact rollback package.
- A staged visual change in the legacy sandbox, paused before final commit.

## The single dramatic proof

An apparently valid adult-facing substitution fails a hidden pediatric pathway. RENKEVIA traces that failure to a dependency buried in an old table/image, recompiles the entire patch, and turns the affected regression cells from red to green without hiding the dissent or bypassing approval.

## Non-goals

- Diagnosing, prescribing, dosing, or recommending real treatment.
- Replacing a pharmacist, physician, safety committee, or change-control board.
- Connecting to a real EHR, pump, pharmacy system, or patient record.
- Proving clinical efficacy or production compliance.
- Acting as a generic document Q&A assistant.
- Maximizing the number of GPT features shown on screen.

## Acceptance criteria for the first vertical slice

1. One click starts the synthetic shortage compilation from a known fixture.
2. Every proposed mutation links to at least one source span or visual region.
3. The Patch IR is schema-valid and deterministic code—not the model—applies its diffs.
4. The first candidate visibly fails at least one hidden synthetic patient pathway.
5. The system explains the failure with evidence and produces a revised candidate.
6. All artifact diffs update coherently from the revised Patch IR.
7. Four independent review roles can agree, dissent, or block; the root compiler cannot erase dissent.
8. The approval control remains disabled while blocking tests, unresolved evidence, or required dissent exist.
9. Computer Use stages the matching change in the fictional legacy EHR, captures proof, and stops before the final write.
10. Rollback exactly restores the pre-patch fixture in automated tests.
11. The critical journey is demonstrable in under three minutes without hidden manual repair.

## Novelty statement

Working, deliberately cautious claim:

> We found no public system that transforms a medication shortage into a synchronized, provenance-linked hospital patch and validates it against synthetic patient pathways before human approval.

This is a research finding, not an absolute claim that no adjacent product exists. Before submission, it must be accompanied by a dated competitive scan and precise distinctions.

## Success measure

The winning proof is not “the model generated six files.” It is that a reviewer can watch one unsafe institutional change become a coherent, evidence-backed, regression-tested, reversible change package—and understand why a normal chatbot cannot own that loop.

