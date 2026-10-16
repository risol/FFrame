# Contributing

FFrame is a layered desktop-first Flutter UI framework. Keep desktop layout primitives in `fframe_layout`, visual contracts in `fframe_design`, the application-facing FFrame API and shared controls in `fframe`, and concrete tokens/resolvers in a design-system package.

## Local setup

- Flutter 3.22+ and Dart 3.4+
- Layout and design-contract packages have no third-party runtime dependencies

```sh
dart pub global activate melos 6.3.3
melos bootstrap
melos run format
melos run analyze
melos run test
```

## Pull requests

- Explain the layout behavior and the constraints it expects.
- Add focused unit or widget coverage for behavior changes.
- Keep the layout package independent from design systems, Material, and app state management.
- Keep shared control behavior independent from concrete design-system packages.
- Document public API and user-visible sizing tradeoffs.
- For API changes, include a short RFC under `docs/rfcs/` when the change affects sizing, pane collapse, adaptive selection, workspaces, or adapters.

## Bug reports

Include Flutter/Dart versions, parent constraints, a minimal widget tree, and the actual versus expected layout. Window dimensions are more useful than platform labels for adaptive issues.
