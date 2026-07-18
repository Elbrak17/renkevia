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

The UI never sends an OpenAI key from the browser. Live model calls will be made
by a separate server-side orchestration layer. Every current result is visibly
labeled `FIXTURE REPLAY` and uses synthetic, non-clinical data.
