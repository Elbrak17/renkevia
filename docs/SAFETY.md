# Safety, privacy, and security

RENKEVIA is a synthetic demonstration of change-control infrastructure. It is not a medical device, clinical decision-support system, prescribing tool, or production hospital integration.

## Data policy

- Accept only bundled synthetic fixtures during the hackathon demo.
- Do not create a “paste patient data” or unrestricted upload path.
- Use fictional institution, vendor, clinician, drug/product, patient, and identifier data.
- Visibly label clinical surfaces **Synthetic demonstration — not for patient care**.
- Reject fixture files containing known secret patterns or unapproved personal identifiers.
- Store content hashes and minimum necessary metadata in audit logs; do not duplicate entire artifacts into logs.

## Model and prompt-injection policy

- Treat document text, image text, metadata, and legacy-screen content as untrusted data.
- System/tool policy always outranks artifact content.
- Artifacts cannot add tools, change approval policy, request secrets, or redefine the Patch IR schema.
- Model outputs remain proposals until strict schema validation, source verification, deterministic tests, and policy checks pass.
- Unsupported claims become explicit uncertainty/blockers rather than plausible completions.

## Tool policy

- Allow-list tools and validate every argument server-side.
- Separate read, compute, stage, approve, and commit capabilities.
- Programmatic Tool Calling may invoke only read/compute/test tools.
- Computer Use receives a fictional account scoped to the legacy sandbox and staging environment.
- The final legacy commit control is outside the model’s capability set.
- Tool calls carry run IDs and idempotency keys; retries cannot duplicate mutations.

## Approval policy

Approval is disabled if any of the following is true:

- a deterministic critical test fails;
- a required artifact projection is missing;
- a material mutation lacks provenance;
- a required specialist review is absent;
- a blocking dissent is unresolved;
- the observed legacy-screen state differs from the inspected state;
- rollback has not been generated and verified;
- the run is partial, stale, or replayed without disclosure.

Only a named human action can transition from `AWAITING_HUMAN_APPROVAL`. The demo stops there.

## Secrets

- Keys exist only in environment variables or a deployment secret store.
- The Flutter bundle must never contain an OpenAI key.
- Logs and client errors redact authorization headers, cookies, tokens, and raw provider responses that may expose account metadata.
- `.env*`, probe outputs, screenshots, and recordings are reviewed before commit or upload.
- A leaked key is rotated, not merely deleted from the latest commit.

## Claims policy

Allowed with evidence:

- synthetic-suite measurements;
- exact implemented architecture;
- published third-party shortage statistics with attribution;
- human-in-the-loop and rollback mechanics demonstrated in the sandbox.

Forbidden without external validation:

- HIPAA compliant, FDA approved, clinically validated, production safe;
- prevents deaths or medication errors;
- autonomous clinical reasoning;
- guaranteed completeness or novelty;
- zero data retention unless the actual API/project configuration and provider terms support the statement.

## Threats to test

- instruction injection in documents and legacy screens;
- path traversal and malicious file types;
- oversized document denial of service;
- schema smuggling and unexpected enum/value expansion;
- provenance spoofing or stale citations;
- replayed tool results attributed to the wrong patch version;
- approval-state manipulation from the client;
- race between legacy inspection and staged change;
- cache leakage across institutions or runs;
- sensitive content in analytics, screenshots, and crash reports.

## Incident behavior

Fail closed on uncertainty in the demo-critical path. Preserve the partial audit trail, mark the run blocked, expose a recoverable retry or reset, and never fabricate a successful result.

