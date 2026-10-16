# FFrame

**A desktop-first UI framework for Flutter.**

FFrame provides adaptive desktop layouts, resizable workspaces, shared control behavior, and design-system contracts. Use `fframe_layout` for structural layouts, or build an application with the `fframe` API and a visual system.

## Packages

| Package | Responsibility |
| --- | --- |
| [`fframe`](packages/fframe) | Application-facing FFrame API: composition primitives, shared controls, app host, and public exports |
| [`fframe_layout`](packages/fframe_layout) | Design-system-agnostic grid, panes, adaptive layout, workspace, shell, and overlay placement |
| [`fframe_design`](packages/fframe_design) | Tokens, state model, style resolver contracts, and inherited theme scope |
| [`fframe_wpf`](packages/fframe_wpf) | WPF-inspired Windows desktop visual system |

The packages target Flutter 3.22+ and Dart 3.4+. The layout package has no third-party runtime dependencies.

## Use FFrame layouts

```dart
import 'package:fframe/fframe.dart';

FWorkspace(
  navigation: FWorkspacePane(child: const FText('Navigation')),
  content: const FText('Editor'),
  inspector: FWorkspacePane(child: const FText('Inspector')),
)
```

## Use the WPF visual system and shared controls

```dart
import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';

void main() => runFFrameApp(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FPanel(
          child: FButton(
            variant: FButtonVariant.primary,
            onPressed: () {},
            child: const FText('Save'),
          ),
        ),
      ),
    );
```

Applications compose their visible UI with FFrame's `F`-prefixed API from `package:fframe/fframe.dart`. Integration packages may adapt Riverpod, Markdown, FFlow, or platform widgets at the `FWidget` boundary; Material controls are not part of the shared control surface. `fframe_wpf` supplies the only first-party visual system.

## Core capabilities

- Fixed, intrinsic, and flex tracks in `FGrid`, with spans and gaps
- Resizable horizontal and vertical panes with pointer and keyboard splitters
- Constraint-driven adaptive builders and responsive workspaces
- Desktop shell regions, navigation layout, command layout, and dock layouts
- Overlay placement with preferred/fallback positions, flip, shift, and viewport padding
- Shared buttons, text inputs, search, select, checkbox, switch, sidebar, tabs, menu, tooltip, and dialog surface
- Lazy lists, virtualized data grids and trees, form validation, segmented choices, and toast feedback
- Rich text, Markdown renderer bridge, floating panels, and optional native desktop windows
- Runtime theme switching by replacing `FThemeData` or the `FFrameApp` design system

See [`examples/showcase`](examples/showcase) for the integrated FFrame layout and controls showcase, and [`docs`](docs) for guides and architecture notes. The framework is licensed under MIT; contributor expectations are in [CONTRIBUTING.md](CONTRIBUTING.md).

Start with the [API index](docs/api/README.md), [integration guide](docs/guides/integrations.md), or [development status](docs/roadmap-status.md).

## Monorepo development

Activate the pinned Melos version, then bootstrap and run the repository scripts:

```sh
dart pub global activate melos 6.3.3
melos bootstrap
melos run analyze
melos run test
```
