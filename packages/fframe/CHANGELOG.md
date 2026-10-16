# Changelog

## Unreleased

- Add FFrame-owned composition primitives and migrate app examples to FFrame-only imports.
- Remove Flutter Widgets/Material convenience barrels; application code uses FFrame APIs only.
- Bundle the FFrame icon vocabulary and add FFrame frame-timing and logging APIs for diagnostics.

## 0.2.0

- Split the framework into core, design contracts, shared controls, and an optional WPF-inspired visual package.
- Added semantic tokens, shared control states, style resolvers, and `FTheme` runtime scope.
- Added shared desktop controls and a `WidgetsApp`-based `FFrameApp` host.
- Keep the main `fframe.dart` barrel scoped to FFrame-owned, `F`-prefixed APIs.
- Add optional Flutter Widgets and Material convenience entrypoints.
- Moved the Database Studio into `examples/showcase` and updated CI for the monorepo.

## 0.1.0

- Add track-based `FGrid` with fixed, auto, flex, spans, gaps, alignment, and overflow behavior.
- Add resizable panes, accessible splitters, pane controller snapshots, and collapse behavior.
- Add adaptive values, layout conditions, responsive workspaces, navigation layout, and desktop shell regions.
- Add dock layout, responsive command area, anchored placement utilities, and debug overlays.
- Add optional Material navigation and command-area adapters.
- Add a database-client example, API documentation, tests, and CI workflows.
