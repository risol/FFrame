# Public API reference

The public barrel is [`fframe.dart`](../../packages/fframe/lib/fframe.dart). It exports FFrame-owned composition primitives, layouts, design contracts, controls, and app/window hosts. Public FFrame APIs use the `F` prefix; implementation types imported from Flutter remain under the FFrame aliases or behind controls.

Reference pages: [composition primitives](primitives.md), [layout](layouts.md), [design-system contracts](design-system.md), and [controls](controls.md).

## Application and composition

`FFrameApp`, `runFFrameApp`, `FNavigator`, `FNavigationController`, `FTheme`, `FWidget`, `FBuildContext`, `FStatelessWidget`, `FStatefulWidget`, `FState`, `FRow`, `FColumn`, `FStack`, `FContainer`, `FText`, `FRichText`, `FInlineSpan`, `FWidgetSpan`, `FListView`, `FTable`, and the other `F*` composition primitives.

## Shared controls

Actions: `FButton`, `FIconButton`. Inputs: `FTextField`, `FSearchBox`, `FSelect`, `FForm`, `FFormController`. State: `FCheckbox`, `FSwitch`. Navigation: `FSidebar`, `FSidebarItem`, `FTabs`, `FTab`, `FSegmentedControl`, `FSegmentedItem`. Data: `FDataGrid`, `FDataGridColumn`, `FTreeView`, `FTreeNode`. Overlays and feedback: `FMenu`, `FPopover`, `FTooltip`, `FDialog`, `showFDialog`, `FToast`, `showFToast`. Surfaces: `FPanel`, `FDivider`, `FScrollArea`.

See [controls](../controls/README.md) for interaction contracts and examples.

## Integrations and windows

`FWidgetAdapter` is the leaf interop wrapper. `FMarkdown` accepts an `FMarkdownRenderer`. `FWindowManager`, `FWindowAdapter`, `FWindowSpec`, `FWindowFrame`, `FWindowTitleBar`, `FFloatingDock`, and `FFloatingPanel` form the app/platform boundary. The optional `fframe_window` package exports `FDesktopWindowBootstrap` and its native adapter; its platform setup is documented in the [package guide](../../packages/fframe_window/README.md). `FInputFormatters` contains common input formatter helpers. See [integration boundaries](../guides/integrations.md) and [windowing](../controls/windowing.md).

## Design-system APIs

`FDesignSystem`, token interfaces, `FComponentStyles`, visual resolvers, `FControlState`, `FControlSize`, `FThemeData`, and `FTheme` live in `fframe_design`. `FWpfDesignSystem` is provided by `fframe_wpf`. See [design-system contracts](../design-system/README.md), [theme resolution](../architecture/theme-resolution.md), and [icon vocabulary](../design-system/icons.md).
