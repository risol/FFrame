# Shared controls

The `fframe` package contains behavior and layout for the shared controls. Each control resolves its visuals through the nearest `FTheme`:

- **Actions:** `FButton`, `FIconButton`
- **Inputs:** `FTextField`, `FSearchBox`, `FSelect`, `FForm`
- **State:** `FCheckbox`, `FSwitch`
- **Surfaces:** `FPanel`, `FDivider`, `FScrollArea`
- **Navigation:** `FSidebar`, `FSidebarItem`, `FTabs`, `FTab`, `FSegmentedControl`
- **Data:** `FListView`, `FDataGrid`, `FTreeView`
- **Overlays:** `FMenu`, `FPopover`, `FTooltip`, `FDialog`, `showFDialog`
- **Feedback:** `FToast`, `showFToast`
- **Windowing:** `FWindowFrame`, `FWindowTitleBar`, `FFloatingDock`, `FFloatingPanel`
- **Content:** `FRichText`, `FMarkdown`

See [the input contract](input-contract.md), [data views](data-views.md), [application combinations](combined-controls.md), [windowing](windowing.md), and [accessibility review](../accessibility/controls-review.md) for behavior and usage details.

The [Database Studio showcase](../../examples/showcase) demonstrates shared controls and can switch visual systems without changing workspace composition.
