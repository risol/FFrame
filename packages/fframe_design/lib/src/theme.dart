import 'package:flutter/widgets.dart';

import 'design_system.dart';
import 'tokens.dart';

/// Immutable theme configuration for an FFrame subtree.
@immutable
class FThemeData {
  const FThemeData({
    required this.designSystem,
    this.brightness = Brightness.light,
    this.density,
  });

  final FDesignSystem designSystem;
  final Brightness brightness;
  final FDensityTokens? density;

  FDesignTokens get tokens => designSystem.tokens;
  FDensityTokens get effectiveDensity => density ?? tokens.density;

  FThemeData copyWith({
    FDesignSystem? designSystem,
    Brightness? brightness,
    FDensityTokens? density,
  }) =>
      FThemeData(
        designSystem: designSystem ?? this.designSystem,
        brightness: brightness ?? this.brightness,
        density: density ?? this.density,
      );
}

/// Inherited design-system scope. Layout primitives never depend on it.
class FTheme extends InheritedWidget {
  const FTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final FThemeData data;

  static FThemeData of(BuildContext context) {
    final theme = maybeOf(context);
    assert(theme != null, 'No FTheme found in the widget tree.');
    return theme!;
  }

  static FThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FTheme>()?.data;

  @override
  bool updateShouldNotify(FTheme oldWidget) => data != oldWidget.data;
}

extension FThemeBuildContext on BuildContext {
  FThemeData get fTheme => FTheme.of(this);
}
