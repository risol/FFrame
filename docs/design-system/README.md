# Design-system infrastructure

The `fframe_design` package defines a plugin contract; it does not ship a palette. `fframe_wpf` is FFrame's only first-party visual system. Applications can use its semantic tokens and component style resolvers through `FTheme`, or implement their own design system.

- [Theme resolution](../architecture/theme-resolution.md)
- [Shared control states](../architecture/control-state-model.md)
- [Custom design-system guide](../guides/custom-design-system.md)
- [FFrame controls](../guides/controls.md)

The supported FFrame visual package is `fframe_wpf`. It provides WPF-inspired styles for FFrame controls; it does not host native .NET WPF controls. Application code composes views with FFrame APIs only.
