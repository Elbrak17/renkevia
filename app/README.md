# RENKEVIA Flutter Web

This directory contains the web-only institutional workspace. The first vertical
slice is the Response Room: a deterministic synthetic replay exposes a hidden
pediatric dependency and locks the human approval gate.

## Run

Use Flutter `3.44.6` / Dart `3.12.2`.

```bash
flutter pub get
flutter run -d chrome
```

## Verify

```bash
flutter analyze
flutter test
flutter build web
```

The UI never sends an OpenAI key from the browser. Live model calls will be made
by a separate server-side orchestration layer. Every current result is visibly
labeled `FIXTURE REPLAY` and uses synthetic, non-clinical data.
