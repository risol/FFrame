# Layout API reference

All layout types are exported through `fframe` from `fframe_layout`. They do not depend on a visual design system.

| Area | Public APIs | Guide |
| --- | --- | --- |
| Track grid | `FGrid`, `FGridItem`, `FGridAlignment`, `FOverflowBehavior`, `FTrack`, `FFixedTrack`, `FAutoTrack`, `FFlexTrack`, `FTrackLayout` | [Grid](../widgets/grid.md), [tracks](../concepts/tracks.md) |
| Panes | `FPane`, `FSplitView`, `FSplitter`, `FSplitterBuilder`, `FPaneController`, `FPaneState`, `FPaneSnapshot` | [Split view](../widgets/split-view.md), [panes](../concepts/panes.md) |
| Workspace | `FWorkspace`, `FWorkspacePane`, `FWorkspaceController`, `FWorkspacePolicy`, `FPanePolicy`, `FPaneCollapseBehavior` | [Workspace](../concepts/workspace.md) |
| Adaptive layout | `FAdaptiveValue<T>`, `FLayoutCondition`, `FLayoutState`, `FLayoutStateData`, `FLayoutScope`, `FAdaptiveBuilder`, `FAdaptiveVisibility`, `FAdaptiveWidgetBuilder`, `FWindowClass` | [Adaptive layout](../concepts/adaptive-layout.md) |
| Shell and navigation | `FDesktopShell`, `FTitleBarLayout`, `FStatusArea`, `FNavigationLayout`, `FAdaptiveNavigationLayout`, `FNavigationPolicy`, `FNavigationMode` | [Desktop shell](../widgets/desktop-shell.md) |
| Dock and command | `FDockLayout`, `FCommandArea`, `FCommandItem`, `FCommandOverflowBuilder` | [Dock layout](../widgets/dock-layout.md) |
| Overlays | `FPlacement`, `FPlacementPolicy`, `FPlacementResult`, `FPlacementResolver`, `FAnchoredLayout` | [Placement concepts](../concepts/constraints.md) |
| Diagnostics | `FFrameDebugOverlay`, `FLayoutVisualizer` | `fframe_layout` API docs |

`FDataGrid`, `FTreeView`, and floating panels live in the higher-level `fframe` package because they consume app controls and theme tokens.
