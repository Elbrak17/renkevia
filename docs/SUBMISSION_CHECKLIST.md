# Submission checklist

## Required before submission

- [ ] Devpost registration completed by the project owner.
- [x] Consolidated pull request #11 is green and merged into `main`.
- [x] GitHub Pages deployment opens over HTTPS and the release build has passed
  desktop, tablet, and mobile browser capture.
- [x] CI visual proof and the Pages deployment were produced from the same
  product commit; the later submission-copy update does not alter the app.
- [x] Final browser screenshots contain readable text and no missing-font
  squares.
- [ ] Demo video is public/unlisted as required and stays within the time limit.
- [x] Devpost description leads with the institutional transformation, not a
  model-feature list; see `DEVPOST_SUBMISSION.md`.
- [x] Repository URL, live URL, and license are supplied in the submission
  draft.
- [ ] Final video URL is inserted into the submission draft and Devpost form.

## Live API gate

- [ ] API project has a funded balance and conservative project alerts.
- [ ] `LIVE_OPENAI_ENABLED=true` only for the bounded recorded probe.
- [ ] `npm run probe:live` passes for the exact project/model access.
- [ ] `npm run demo:live` saves a sanitized passing evidence record.
- [ ] Cost ledger stays below the configured total limit.
- [ ] The recording visibly distinguishes live execution from fixture replay.

## Safety and truthfulness gate

- [x] Synthetic/no-PHI label remains visible.
- [x] No API key, real patient data, real hospital identity, or billing detail is
  visible in the repository, logs, or final screenshots.
- [ ] No API key, real patient data, real hospital identity, or billing detail is
  visible in the final video.
- [x] No claim of HIPAA compliance, clinical validation, production readiness,
  autonomous approval, or autonomous final write.
- [x] Northstar is called a fictional legacy target, never the product name.
- [x] Human approval is shown; final commit is not executed.

Run the final machine checks:

```bash
npm run check:offline
npm run demo:core
npm run verify:submission
```
