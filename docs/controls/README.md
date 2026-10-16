# Shared controls

The `fframe` package contains behavior and layout for the shared controls. Each control resolves its visuals through the nearest `FTheme`:

- **Actions:** `FButton`, `FIconButton`
- **Inputs:** `FTextField`, `FSearchBox`, `FSelect`
- **State:** `FCheckbox`, `FSwitch`
- **Surfaces:** `FPanel`, `FDivider`, `FScrollArea`
- **Navigation:** `FSidebar`, `FSidebarItem`, `FTabs`, `FTab`
- **Overlays:** `FMenu`, `FPopover`, `FTooltip`, `FDialog`, `showFDialog`

The [Database Studio showcase](../../examples/showcase) demonstrates these controls and can switch visual systems without changing the workspace composition.
