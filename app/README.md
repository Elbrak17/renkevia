# RENKEVIA Flutter Web

This directory contains the web-only institutional workspace. Its deterministic
synthetic replay spans five connected surfaces:

- **Response Room** exposes a hidden pediatric dependency and locks approval.
- **Patch Studio** recompiles the pediatric exception through one typed Patch IR,
  synchronizes six inspectable projections, retains specialist dissent, and
  routes the revised candidate to patient-pathway simulation.
- **Simulation Lab** runs the sealed synthetic patient-pathway regression suite.
- **Evidence Vault** preserves independent reviews, dissent, provenance, and
  exact rollback before approval.
- **Northstar Clinical System** is the separate fictional no-API EHR target for
  visual staging and safe-stop proof. It is not the RENKEVIA product name.

RENKEVIA uses a side rail at 920 px and above and persistent bottom navigation
below it. Every workspace becomes a vertical, scrollable composition on mobile.
Northstar exposes a compact safety companion below 900 px; its Computer Use
operator console remains intentionally desktop-only.

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

`web/flutter_bootstrap.js` pins CanvasKit to the local web bundle so a restricted
venue network cannot leave the application on an empty loading surface.

The UI never sends an OpenAI key from the browser. Live model calls are made by
the separate server-side orchestration layer.

## Execution modes

The default build uses `FIXTURE REPLAY`. To connect the same Flutter Web
surface to the sealed TypeScript core, start the API from the repository root
and build or run Flutter with a compile-time base URL:

```bash
npm run serve:api
cd app
flutter run -d chrome \
  --dart-define=RENKEVIA_API_BASE_URL=http://127.0.0.1:8787
```

Connected mode is labeled `CONNECTED CORE` on every viewport. Network or
contract failures become blocking UI errors; the client never silently falls
back to fixture replay. Both modes use synthetic, non-clinical data.
