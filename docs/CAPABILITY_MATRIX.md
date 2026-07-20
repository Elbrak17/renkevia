# GPT-5.6 capability matrix

Last documentation review: 2026-07-18. “Documented” means confirmed in current official OpenAI documentation. It does not mean this project/account has passed the live probe.

| Capability | RENKEVIA use | Official status | Local probe | Account status |
|---|---|---|---|---|
| GPT-5.6 Sol | Patch synthesis, contradictions, final audit | Documented; guarded adapter implemented | `npm run probe:models` | Awaiting funded live probe |
| GPT-5.6 Terra | Bounded extraction and communications | Documented; route implemented | `npm run probe:models` | Awaiting funded live probe |
| GPT-5.6 Luna | Classification and normalization | Documented; route implemented | `npm run probe:models` | Awaiting funded live probe |
| Structured Outputs | Patch/evidence/review schemas | Documented; Patch IR boundary implemented and tested | `npm run probe:structured` | Awaiting funded live probe |
| Programmatic Tool Calling | Parallel deterministic tests, joins, filtering, aggregation | Hosted V8 program + program-only patient tools implemented and tested | `npm run probe:programmatic` | Awaiting funded live probe |
| Responses Multi-agent | Independent specialist challenge | Four-role beta request and dissent-preserving validator implemented and tested | `npm run probe:multi-agent` | Awaiting funded live probe |
| Computer Use | Staging in fictional no-API EHR | Screenshot-first, origin/action allow-list, final-commit interception implemented and tested | `npm run probe:computer` | Awaiting browser-backed live probe |
| Explicit prompt-cache breakpoints | Stable institutional corpus prefixes | Stable corpus cache identity implemented | `npm run probe:cache` | Awaiting funded live probe |
| Long context | Cross-document contradictions and dependency mapping | 1.05M context documented for family models | Planned staged-size probe after cost budget approval | Not tested |
| Vision input | Scans, tables, screenshots, old forms | Image input documented | Planned synthetic image fixture | Not tested |
| Streaming | Visible run progress | Documented | Planned after orchestrator contract | Not tested |

## Interpretation rules

- A successful probe proves API access and the minimal contract only; it does not prove product quality.
- A feature becomes **vertical-slice verified** only after it works against the versioned RENKEVIA fixture with assertions.
- A beta feature needs a deterministic fallback and must never be the sole owner of an approval gate.
- Model routing remains a hypothesis until the evaluation suite shows acceptable quality/cost/latency tradeoffs.
- Live probe output must be sanitized before it is saved or committed.

## Official references

- Models: https://developers.openai.com/api/docs/models
- GPT-5.6 Sol: https://developers.openai.com/api/docs/models/gpt-5.6-sol
- Structured Outputs: https://developers.openai.com/api/docs/guides/structured-outputs
- Programmatic Tool Calling: https://developers.openai.com/api/docs/guides/tools-programmatic-tool-calling
- Multi-agent: https://developers.openai.com/api/docs/guides/responses-multi-agent
- Computer Use: https://developers.openai.com/api/docs/guides/tools-computer-use
- Prompt caching: https://developers.openai.com/api/docs/guides/prompt-caching
