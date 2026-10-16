# Contributing

FFrame is a layout framework. Changes should stay focused on sizing, placement, adaptive behavior, accessibility, or integration with application layout regions. New visual controls and theme systems belong in UI libraries or app code.

## Local setup

- Flutter 3.22+ and Dart 3.4+
- No third-party runtime dependencies

```sh
flutter pub get
dart format lib test example/lib example/test
flutter analyze
flutter test
cd example && flutter pub get && flutter test
```

## Pull requests

- Explain the layout behavior and the constraints it expects.
- Add focused unit or widget coverage for behavior changes.
- Keep the core independent from Material, platform APIs, and app state management.
- Document public API and user-visible sizing tradeoffs.
- For API changes, include a short RFC under `docs/rfcs/` when the change affects sizing, pane collapse, adaptive selection, workspaces, or adapters.

## Bug reports

Include Flutter/Dart versions, parent constraints, a minimal widget tree, and the actual versus expected layout. Window dimensions are more useful than platform labels for adaptive issues.
