# Pinned application toolchain

- Surface: Flutter Web only (no Android or APK target)
- Flutter: `3.44.6` stable, revision `ee80f08bbf`
- Dart: `3.12.2`
- DevTools: `2.57.0`
- Application package: `app/`

The repository intentionally contains only the `web` platform scaffold. The SDK
itself is never vendored or committed. CI and contributors must run `flutter
analyze`, `flutter test`, and `flutter build web` before publishing a checkpoint.
