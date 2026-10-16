import 'package:flutter/widgets.dart';

import 'state.dart';

/// The visual variant for a button.
enum FButtonVariant { primary, secondary, subtle, danger }

/// Visual values for an FButton, resolved for its semantic state.
@immutable
class FButtonVisualStyle {
  const FButtonVisualStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.textStyle,
    required this.height,
    this.focusRing,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final double borderWidth;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final double height;
  final Color? focusRing;
}

abstract interface class FButtonStyleResolver {
  FButtonVisualStyle resolve(
    FButtonVariant variant,
    FControlSize size,
    Set<FControlState> states,
  );
}

/// Shared field surface style for text input and select controls.
@immutable
class FFieldVisualStyle {
  const FFieldVisualStyle({
    required this.background,
    required this.foreground,
    required this.hint,
    required this.border,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.textStyle,
    required this.height,
    this.focusRing,
  });

  final Color background;
  final Color foreground;
  final Color hint;
  final Color border;
  final double borderWidth;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final double height;
  final Color? focusRing;
}

abstract interface class FInputStyleResolver {
  FFieldVisualStyle resolve(
    FControlSize size,
    Set<FControlState> states,
  );
}

abstract interface class FSelectStyleResolver {
  FFieldVisualStyle resolve(
    FControlSize size,
    Set<FControlState> states,
  );
}

@immutable
class FPanelVisualStyle {
  const FPanelVisualStyle({
    required this.background,
    required this.border,
    required this.borderWidth,
    required this.radius,
    this.padding = EdgeInsets.zero,
  });

  final Color background;
  final Color border;
  final double borderWidth;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
}

abstract interface class FPanelStyleResolver {
  FPanelVisualStyle resolve({bool raised = false});
}

@immutable
class FMenuVisualStyle {
  const FMenuVisualStyle({
    required this.background,
    required this.foreground,
    required this.hover,
    required this.border,
    required this.radius,
    required this.padding,
    required this.textStyle,
  });

  final Color background;
  final Color foreground;
  final Color hover;
  final Color border;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
}

abstract interface class FMenuStyleResolver {
  FMenuVisualStyle resolve();
}

/// Group of component visual resolvers.
abstract interface class FComponentStyles {
  FButtonStyleResolver get button;
  FInputStyleResolver get input;
  FSelectStyleResolver get select;
  FPanelStyleResolver get panel;
  FMenuStyleResolver get menu;
}
