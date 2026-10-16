import 'package:flutter/widgets.dart';

/// Semantic colors used by a design system.
abstract interface class FColorTokens {
  Color get canvas;
  Color get surface;
  Color get surfaceSubtle;
  Color get surfaceRaised;
  Color get surfaceOverlay;
  Color get textPrimary;
  Color get textSecondary;
  Color get textDisabled;
  Color get border;
  Color get borderStrong;
  Color get focusRing;
  Color get accent;
  Color get accentHover;
  Color get accentPressed;
  Color get accentForeground;
  Color get selection;
  Color get hover;
  Color get danger;
  Color get warning;
  Color get success;
}

/// Typography roles, independent of a specific component library.
abstract interface class FTypographyTokens {
  TextStyle get windowTitle;
  TextStyle get title;
  TextStyle get sectionTitle;
  TextStyle get body;
  TextStyle get bodyStrong;
  TextStyle get caption;
  TextStyle get label;
  TextStyle get command;
  TextStyle get monospace;
}

/// Spacing scale for layout and controls.
abstract interface class FSpacingTokens {
  double get xxs;
  double get xs;
  double get sm;
  double get md;
  double get lg;
  double get xl;
  double get xxl;
}

/// Border radii for common surfaces.
abstract interface class FRadiusTokens {
  BorderRadius get control;
  BorderRadius get panel;
  BorderRadius get popup;
  BorderRadius get dialog;
}

/// Border widths and focus-ring treatment.
abstract interface class FBorderTokens {
  double get subtle;
  double get normal;
  double get strong;
  double get focusWidth;
}

/// Elevation levels without tying the API to Material elevation.
abstract interface class FElevationTokens {
  double get raised;
  double get popup;
  double get dialog;
}

/// App-wide density metrics.
abstract interface class FDensityTokens {
  double get controlHeight;
  double get compactControlHeight;
  double get navigationItemHeight;
  double get toolbarHeight;
  double get rowHeight;
  double get iconSize;
  double get hitTargetMin;
}

/// Standard desktop density presets for apps that want a ready-made override.
///
/// Compact density reduces visual spacing. The [hitTargetMin] metric remains
/// 40 logical pixels so target-aware controls can preserve pointer targets.
@immutable
class FStandardDensityTokens implements FDensityTokens {
  const FStandardDensityTokens({this.compact = false});

  final bool compact;

  @override
  double get controlHeight => compact ? 28 : 32;
  @override
  double get compactControlHeight => compact ? 24 : 28;
  @override
  double get navigationItemHeight => compact ? 32 : 36;
  @override
  double get toolbarHeight => compact ? 36 : 40;
  @override
  double get rowHeight => compact ? 28 : 32;
  @override
  double get iconSize => compact ? 16 : 18;
  @override
  double get hitTargetMin => 40;
}

/// Motion durations and curves for desktop interactions.
abstract interface class FMotionTokens {
  Duration get fast;
  Duration get normal;
  Duration get slow;
  Curve get standard;
  Curve get emphasized;
}

/// A complete semantic token set provided by a design system.
abstract interface class FDesignTokens {
  FColorTokens get colors;
  FTypographyTokens get typography;
  FSpacingTokens get spacing;
  FRadiusTokens get radius;
  FBorderTokens get borders;
  FElevationTokens get elevation;
  FDensityTokens get density;
  FMotionTokens get motion;
}
