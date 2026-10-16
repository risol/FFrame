# FFrame

**Desktop-first adaptive application layout for Flutter.**

FFrame fills the space between Flutter's low-level layout primitives and UI libraries such as Material, Forui, and Fluent. It provides grids, resizable panes, adaptive workspaces, and shell regions while leaving buttons, forms, themes, and navigation visuals to your app.

```dart
import 'package:fframe/fframe.dart';

FWorkspace(
  navigation: FWorkspacePane(child: MyNavigation()),
  content: MyEditor(),
  inspector: FWorkspacePane(child: MyInspector()),
)
```

## Features

- Fixed, auto, and flex tracks in `FGrid`, including cell spans and gaps
- Resizable horizontal and vertical `FSplitView` panes
- Pointer and keyboard splitter controls with semantics
- Constraint-based adaptive builders and visibility
- Responsive `FWorkspace`, `FDesktopShell`, and `FDockLayout`
- UI-library-agnostic core with an optional Material adapter
- Anchored overlay placement with flip and viewport clamping

## Install

```yaml
dependencies:
  fframe: ^0.1.0
```

Core requires Flutter 3.22 or later and has no third-party runtime dependencies. Material helpers are imported separately:

```dart
import 'package:fframe/fframe.dart';
import 'package:fframe/material.dart';
```

## Grid

```dart
FGrid(
  columns: const [FTrack.fixed(240), FTrack.flex(), FTrack.fixed(320)],
  rows: const [FTrack.fixed(48), FTrack.flex()],
  columnGap: 8,
  children: [
    FGridItem(row: 0, column: 0, columnSpan: 3, child: const Toolbar()),
    FGridItem(row: 1, column: 0, child: const Navigation()),
    FGridItem(row: 1, column: 1, child: const Editor()),
    FGridItem(row: 1, column: 2, child: const Inspector()),
  ],
)
```

`FTrack.auto()` measures child intrinsic size. Prefer flex tracks for complex or large subtrees.

## Resizable panes

```dart
final controller = FPaneController();

FSplitView.horizontal(
  controller: controller,
  children: const [
    FPane(id: 'navigation', preferredSize: 240, minSize: 180, child: Navigation()),
    FPane.flex(id: 'content', minSize: 480, child: Editor()),
    FPane(id: 'inspector', preferredSize: 320, minSize: 240, child: Inspector()),
  ],
)
```

Call `controller.collapse('inspector')`, `controller.setSize('navigation', 280)`, or save `controller.snapshot()` in app-owned storage.

## Adaptive workspace

```dart
FWorkspace(
  navigation: FWorkspacePane(child: const Navigation()),
  content: const Editor(),
  inspector: FWorkspacePane(child: const Inspector()),
)
```

The workspace uses its local width and configured minimum sizes to choose three panes, two panes, compact navigation, or content alone. It does not inspect the operating system or device type.

## Material example

See [`example/`](example) for a runnable database client. Run it with:

```sh
cd example
flutter run -d windows
```

For API guides and design decisions, see [`docs/`](docs). The package core imports `flutter/widgets.dart` and rendering APIs only; Material integration is isolated in `package:fframe/material.dart`.

## Development

```sh
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

FFrame is licensed under MIT. See [CONTRIBUTING.md](CONTRIBUTING.md) for local development and review expectations.
