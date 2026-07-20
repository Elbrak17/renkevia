# Impact model

Status: problem evidence is sourced; product impact is an explicit hypothesis pending a controlled pilot. Nothing here is a clinical-efficacy claim.

## Why the coordination problem is credible

- ASHP’s current fluid-shortage resource asks organizations to coordinate leadership, pharmacy, nursing, infection control, risk management, and clinical informatics; it also calls out EHR alerts, order sets, preference lists, barcode workflows, and pump-related training. That is the fragmented change surface RENKEVIA models.
- Vizient’s 2025 survey release estimates roughly 20 million U.S. hospital labor hours and nearly $900 million per year spent managing drug shortages. It reports medication-error and care-disruption responses, but these are attributed survey findings—not claims caused or solved by RENKEVIA.
- Japan’s Ministry of Health, Labour and Welfare states that antibiotic shortages occur globally and that Japan has experienced large-scale shortages, supporting the problem’s relevance beyond the United States.

Sources: [ASHP fluid-shortage guidance](https://www.ashp.org/drug-shortages/shortage-resources/publications/fluid-shortages-suggestions-for-management-and-conservation), [Vizient 2025 survey release](https://www.vizientinc.com/newsroom/news-releases/2025/new-vizient-survey-finds-drug-shortages-cost-hospitals-nearly-900m-annually-in-labor-expenses), [Japan MHLW antimicrobial-resistance action plan](https://www.mhlw.go.jp/content/10900000/001096228.pdf).

## What the prototype measures today

| Measure | Reproducible prototype result | Meaning |
|---|---:|---|
| Institutional targets synchronized | 6 | One typed rule projects into six fictional artifact types |
| Field projections | 12 | Two evidence-backed mutations across six targets |
| Hidden unsafe variant detected | 1/1 | The seeded pediatric omission blocks approval |
| Revised synthetic pathways | 24/24 | Same sealed cases pass after the exception is represented |
| Revised deterministic assertions | 96/96 | Software truth, not model prose |
| Material-diff provenance | 100% | Every shown diff points to a known source identity |
| Complete and partial rollback | Exact | Restored state hash equals the sealed baseline |
| Autonomous final writes | 0 | `finalCommitAllowed` is always false |

These are software-fixture results. They do not establish clinical safety, real-world time savings, or lower error rates.

## Transparent planning hypothesis

`npm run impact:scenario` computes one editable planning scenario. Its default assumptions compare a manual cross-check of 12 artifacts, 6 target systems, 24 representative cases, and 4 reviews with an assisted workflow that still requires human validation and all four reviews. The default output estimates 322 manual coordination minutes versus 103 assisted minutes, or 68% time released for higher-value review.

That percentage is **not measured** and must never appear as a product result. The script exists so a pilot team can challenge each assumption rather than accepting a black-box ROI claim.

## Preregistered pilot measures

For a controlled synthetic or de-identified workflow study, compare a checklist baseline and RENKEVIA on the same versioned scenarios:

1. time to a reviewable candidate;
2. critical dependency recall;
3. unsupported mutation rate;
4. artifact synchronization completeness;
5. human correction count;
6. time to locate the source behind a failed check;
7. approval-integrity and rollback exactness.

The pilot should record failures and variance, preserve the baseline outputs, and prohibit thresholds from being rewritten after results are known.
