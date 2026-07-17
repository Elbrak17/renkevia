# GPT-5.6 capability probes

These are small, zero-dependency Responses API probes. They answer one question at a time and print a sanitized JSON report. They are not product mocks and do not mark an untested capability as working.

## Safe offline checks

```bash
npm run check
```

`probe:preflight` reports `blocked`—with exit code zero—when no key is configured, so contributors can still verify the repository safely.

## Live checks

Live checks make billable API requests. Export the key in your own secure environment; do not put it in `.env` unless that local file is protected and never commit it.

```bash
export OPENAI_API_KEY='...'
npm run probe:models
npm run probe:structured
npm run probe:programmatic
npm run probe:multi-agent
npm run probe:computer
npm run probe:cache
```

`npm run probe:live` runs all of them. A live probe exits with code 2 if the key is missing and code 1 for an API or assertion failure.

## Probe boundaries

- `model-access` asks Sol, Terra, and Luna for a tiny deterministic response.
- `structured-output` verifies a strict JSON schema round-trip.
- `programmatic-tool-calling` runs two read-only local functions through the hosted V8 orchestration loop and verifies a program—not merely direct calls—was used.
- `multi-agent` requests two independent synthetic code reviewers and checks for hosted agent activity. It uses the required beta header.
- `computer-use` verifies only the initial screenshot-first `computer_call`. It executes no browser action and performs no write.
- `prompt-cache` sends a stable synthetic prefix twice with an explicit breakpoint and compares cache-write/read telemetry.

The full Computer Use loop belongs to the isolated fictional legacy-EHR harness. It must enforce a domain allow-list, action allow-list, state recheck, maximum step count, and mandatory stop before commit.

## Results

Do not commit raw provider responses. If a result is needed as evidence, reduce it to model, request ID, timestamp, status, usage counters, asserted contract, and sanitized error class. The `probes/results` directory is ignored except for its placeholder.

