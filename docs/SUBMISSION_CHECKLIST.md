# Submission checklist

## Required before submission

- [ ] Devpost registration completed by the project owner.
- [ ] All chained pull requests are green and merged into `main`.
- [ ] GitHub Pages deployment opens on mobile and desktop.
- [ ] Downloaded CI Web artifact matches the deployed build.
- [ ] Final screenshots contain readable text and no missing-font squares.
- [ ] Demo video is public/unlisted as required and stays within the time limit.
- [ ] Devpost description leads with the institutional transformation, not a
  model-feature list.
- [ ] Repository URL, live URL, video URL, and license are supplied.

## Live API gate

- [ ] API project has a funded balance and conservative project alerts.
- [ ] `LIVE_OPENAI_ENABLED=true` only for the bounded recorded probe.
- [ ] `npm run probe:live` passes for the exact project/model access.
- [ ] `npm run demo:live` saves a sanitized passing evidence record.
- [ ] Cost ledger stays below the configured total limit.
- [ ] The recording visibly distinguishes live execution from fixture replay.

## Safety and truthfulness gate

- [ ] Synthetic/no-PHI label remains visible.
- [ ] No API key, real patient data, real hospital identity, or billing detail is
  visible in repository, logs, screenshots, or video.
- [ ] No claim of HIPAA compliance, clinical validation, production readiness,
  autonomous approval, or autonomous final write.
- [ ] Northstar is called a fictional legacy target, never the product name.
- [ ] Human approval is shown; final commit is not executed.

Run the final machine checks:

```bash
npm run check:offline
npm run demo:core
npm run verify:submission
```
