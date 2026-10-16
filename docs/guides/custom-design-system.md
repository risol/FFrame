# Build a custom FFrame design system

Create a package that depends on `fframe_design`, then implement four pieces:

1. `FDesignTokens`: semantic colors, typography, spacing, radii, borders, elevation, density, and motion.
2. `FComponentStyles`: button, input, select, panel, and menu resolver implementations.
3. `FDesignSystem`: stable `id` and display `name` with the tokens and resolvers.
4. A small app or widget test that places shared controls under `FTheme` and checks light/dark and enabled/focused/disabled states.

Keep token names semantic (`surfaceRaised`, `textSecondary`, `focusRing`) rather than palette-specific. Resolve every combined state and keep hit targets and contrast usable. Do not fork `fframe_layout` or duplicate shared control behavior.

```dart
class CompanyDesignSystem implements FDesignSystem {
  @override
  String get id => 'company';

  @override
  String get name => 'Company';

  @override
  FDesignTokens get tokens => companyTokens;

  @override
  FComponentStyles get components => companyStyles;
}
```

Application use is the same as an official system:

```dart
FTheme(
  data: FThemeData(designSystem: CompanyDesignSystem()),
  child: const ProductWorkspace(),
)
```

Package names should use `fframe_<system>` when the package is published independently. A future compliance helper can build on the same resolver contract.
