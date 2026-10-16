# Design-system API reference

`fframe_design` defines semantic contracts and does not ship a color palette. Applications select a concrete system, such as `FWpfDesignSystem`, and pass it through `FFrameApp` or `FTheme`.

## Theme

`FThemeData` contains `designSystem`, `brightness`, and an optional density override. `FTheme.of(context)` requires a scope; `FTheme.maybeOf(context)` supports reusable widgets without one. `FThemeBuildContext.fTheme` is an extension getter.

## Tokens

Implement `FDesignTokens` with `FColorTokens`, `FTypographyTokens`, `FSpacingTokens`, `FRadiusTokens`, `FBorderTokens`, `FElevationTokens`, `FDensityTokens`, and `FMotionTokens`. `FStandardDensityTokens` supplies compact and normal desktop metrics.

## Component resolvers

`FComponentStyles` groups the `FButtonStyleResolver`, `FInputStyleResolver`, `FSelectStyleResolver`, `FPanelStyleResolver`, and `FMenuStyleResolver`. Each resolver returns a visual-style value (`FButtonVisualStyle`, `FFieldVisualStyle`, `FPanelVisualStyle`, or `FMenuVisualStyle`). Controls own interaction and semantics; resolvers only return dimensions, colors, borders, typography, and focus-ring values.

`FControlState` contains normal, hovered, focused, pressed, selected, and disabled states. `FControlSize` identifies compact, medium, and large controls. `FEmphasis` is available to app-level style decisions.
