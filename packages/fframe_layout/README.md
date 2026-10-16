# fframe_layout

Design-system-agnostic desktop layout primitives for Flutter. This package depends on Flutter widgets, foundation, and rendering APIs only.

```dart
import 'package:fframe_layout/fframe_layout.dart';

FGrid(
  columns: const [FTrack.fixed(240), FTrack.flex(), FTrack.fixed(300)],
  children: [
    FGridItem(row: 0, column: 0, child: Navigation()),
    FGridItem(row: 0, column: 1, child: Editor()),
    FGridItem(row: 0, column: 2, child: Inspector()),
  ],
)
```

See the repository documentation for constraints, workspaces, split panes, and overlay placement.
