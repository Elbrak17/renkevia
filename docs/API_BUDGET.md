# OpenAI API budget and truthfulness contract

Status: operational constraint frozen on 2026-07-17.

The OpenAI Build Week resources distinguished **Codex credits** from **API
credits**. The event page currently says the Codex allocation is exhausted and
participants may continue with the free tier. GPT-5.6 Sol, Terra, and Luna do
not expose an API free tier. A ChatGPT subscription also does not fund API
usage.

RENKEVIA therefore uses two explicit execution modes:

- `fixture_replay`: deterministic synthetic artifacts and recorded outputs,
  always labeled in the UI. This mode builds and demonstrates the complete
  non-model pipeline without API spend.
- `live_probe`: server-side GPT-5.6 calls for capability verification and the
  final judged run. A replay must never be presented as a fresh model call.

## Minimum-spend plan

OpenAI prepaid billing currently accepts a minimum initial purchase of USD 5.
Use a dedicated API project and a project-scoped key. Never place the key in
Flutter, source control, fixtures, screenshots, issues, or chat.

As of 2026-07-17, standard token prices are:

| Model | Input / 1M tokens | Cached input / 1M | Output / 1M | RENKEVIA role |
| --- | ---: | ---: | ---: | --- |
| GPT-5.6 Luna | $1.00 | $0.10 | $6.00 | classification and routing |
| GPT-5.6 Terra | $2.50 | $0.25 | $15.00 | structured extraction and communications |
| GPT-5.6 Sol | $5.00 | $0.50 | $30.00 | Patch IR, contradiction resolution, final audit |

Cost estimate per call:

```text
(uncached_input_tokens × input_rate
 + cached_input_tokens × cached_rate
 + output_tokens × output_rate) / 1,000,000
```

The initial $5 budget is reserved as follows:

- $0.75 — schema, auth, and one-document smoke probes;
- $1.25 — Luna/Terra routing and extraction probes;
- $2.00 — tightly bounded Sol compilation and adversarial audit runs;
- $0.75 — final recorded demonstration run;
- $0.25 — retry reserve.

Multi-agent and Computer Use live runs stay disabled until their individual
probes pass and a per-run estimate fits the remaining balance.

## Hard guards owned by our backend

OpenAI project budgets are alert thresholds, not hard caps. The orchestration
service must therefore reject a live run unless all of these checks pass:

1. `OPENAI_API_KEY` exists only in the server environment.
2. `LIVE_OPENAI_ENABLED=true` was explicitly selected.
3. the request carries a maximum input, output, tool-call, and agent count;
4. the estimated worst-case charge fits `OPENAI_RUN_BUDGET_USD`;
5. the local append-only cost ledger has room below `OPENAI_TOTAL_BUDGET_USD`;
6. no retry occurs automatically after an unknown-billing failure.

Set project usage alerts around $1, $3, and $4.50, but treat the local ledger as
the actual stop mechanism. Store sanitized successful outputs as provenance-
linked replay fixtures so UI and deterministic tests never consume tokens.

## Primary references

- [Build Week resources](https://openai.devpost.com/)
- [GPT-5.6 Sol](https://developers.openai.com/api/docs/models/gpt-5.6-sol)
- [GPT-5.6 Terra](https://developers.openai.com/api/docs/models/gpt-5.6-terra)
- [GPT-5.6 Luna](https://developers.openai.com/api/docs/models/gpt-5.6-luna)
- [ChatGPT and API billing are separate](https://help.openai.com/en/articles/8156019)
- [Prepaid API billing](https://help.openai.com/en/articles/8264644-how-can-i-set-up-prepaid-billing%2523.docx)
- [API projects and soft budget alerts](https://help.openai.com/en/articles/9186755-managing-projects-in-the-api-platform%3Flatest%3D)
