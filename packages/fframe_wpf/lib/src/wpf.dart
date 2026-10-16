// Keep compatibility with the declared Flutter 3.22 floor.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:fframe_design/fframe_design.dart';

/// WPF-inspired desktop visuals built on FFrame's shared controls.
///
/// The palette and metrics evoke conventional WPF desktop applications while
/// remaining a Flutter design system rather than a WPF runtime or control port.
class FWpfDesignSystem implements FDesignSystem {
  FWpfDesignSystem({Brightness brightness = Brightness.light})
      : tokens = _WpfTokens(brightness),
        components = _WpfComponents(brightness);

  factory FWpfDesignSystem.light() => FWpfDesignSystem();

  factory FWpfDesignSystem.dark() =>
      FWpfDesignSystem(brightness: Brightness.dark);

  @override
  String get id => 'wpf';

  @override
  String get name => 'WPF-inspired';

  @override
  final FDesignTokens tokens;

  @override
  final FComponentStyles components;
}

class _WpfTokens implements FDesignTokens {
  _WpfTokens(Brightness brightness)
      : colors = _WpfColors(brightness),
        typography = const _WpfTypography(),
        spacing = const _WpfSpacing(),
        radius = const _WpfRadius(),
        borders = const _WpfBorders(),
        elevation = const _WpfElevation(),
        density = const _WpfDensity(),
        motion = const _WpfMotion();

  @override
  final FColorTokens colors;
  @override
  final FTypographyTokens typography;
  @override
  final FSpacingTokens spacing;
  @override
  final FRadiusTokens radius;
  @override
  final FBorderTokens borders;
  @override
  final FElevationTokens elevation;
  @override
  final FDensityTokens density;
  @override
  final FMotionTokens motion;
}

class _WpfColors implements FColorTokens {
  _WpfColors(Brightness brightness) : _dark = brightness == Brightness.dark;

  final bool _dark;

  @override
  Color get canvas => _dark ? const Color(0xff202020) : const Color(0xfff0f0f0);
  @override
  Color get surface =>
      _dark ? const Color(0xff2d2d30) : const Color(0xffffffff);
  @override
  Color get surfaceSubtle =>
      _dark ? const Color(0xff252526) : const Color(0xfff0f0f0);
  @override
  Color get surfaceRaised =>
      _dark ? const Color(0xff333337) : const Color(0xfffafafa);
  @override
  Color get surfaceOverlay =>
      _dark ? const Color(0xff3f3f46) : const Color(0xffffffff);
  @override
  Color get textPrimary =>
      _dark ? const Color(0xfff1f1f1) : const Color(0xff1f1f1f);
  @override
  Color get textSecondary =>
      _dark ? const Color(0xffc5c5c5) : const Color(0xff5c5c5c);
  @override
  Color get textDisabled =>
      _dark ? const Color(0xff858585) : const Color(0xff858585);
  @override
  Color get border => _dark ? const Color(0xff454545) : const Color(0xffd1d1d1);
  @override
  Color get borderStrong =>
      _dark ? const Color(0xff686868) : const Color(0xffa0a0a0);
  @override
  Color get focusRing =>
      _dark ? const Color(0xff60cdff) : const Color(0xff0078d4);
  @override
  Color get accent => focusRing;
  @override
  Color get accentHover =>
      _dark ? const Color(0xff3aa6d8) : const Color(0xff0067b8);
  @override
  Color get accentPressed =>
      _dark ? const Color(0xff1683b3) : const Color(0xff005a9e);
  @override
  Color get accentForeground => const Color(0xffffffff);
  @override
  Color get selection =>
      _dark ? const Color(0xff264f78) : const Color(0xffcce8ff);
  @override
  Color get hover => _dark ? const Color(0xff3a3a3d) : const Color(0xffe5f1fb);
  @override
  Color get danger => _dark ? const Color(0xffe74856) : const Color(0xffc42b1c);
  @override
  Color get warning => const Color(0xff9d6700);
  @override
  Color get success => const Color(0xff107c10);
}

class _WpfTypography implements FTypographyTokens {
  const _WpfTypography();

  TextStyle _style(double size, [FontWeight weight = FontWeight.normal]) =>
      TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: size,
        height: 1.25,
        fontWeight: weight,
      );

  @override
  TextStyle get windowTitle => _style(13, FontWeight.w600);
  @override
  TextStyle get title => _style(18, FontWeight.w600);
  @override
  TextStyle get sectionTitle => _style(13, FontWeight.w600);
  @override
  TextStyle get body => _style(13);
  @override
  TextStyle get bodyStrong => _style(13, FontWeight.w600);
  @override
  TextStyle get caption => _style(11);
  @override
  TextStyle get label => _style(12);
  @override
  TextStyle get command => _style(12);
  @override
  TextStyle get monospace => _style(12).copyWith(fontFamily: 'Consolas');
}

class _WpfSpacing implements FSpacingTokens {
  const _WpfSpacing();
  @override
  double get xxs => 2;
  @override
  double get xs => 4;
  @override
  double get sm => 8;
  @override
  double get md => 12;
  @override
  double get lg => 16;
  @override
  double get xl => 24;
  @override
  double get xxl => 32;
}

class _WpfRadius implements FRadiusTokens {
  const _WpfRadius();
  @override
  BorderRadius get control => BorderRadius.circular(2);
  @override
  BorderRadius get panel => BorderRadius.circular(2);
  @override
  BorderRadius get popup => BorderRadius.circular(2);
  @override
  BorderRadius get dialog => BorderRadius.circular(3);
}

class _WpfBorders implements FBorderTokens {
  const _WpfBorders();
  @override
  double get subtle => .5;
  @override
  double get normal => 1;
  @override
  double get strong => 1;
  @override
  double get focusWidth => 1.5;
}

class _WpfElevation implements FElevationTokens {
  const _WpfElevation();
  @override
  double get raised => 1;
  @override
  double get popup => 6;
  @override
  double get dialog => 12;
}

class _WpfDensity implements FDensityTokens {
  const _WpfDensity();
  @override
  double get controlHeight => 30;
  @override
  double get compactControlHeight => 25;
  @override
  double get navigationItemHeight => 30;
  @override
  double get toolbarHeight => 34;
  @override
  double get rowHeight => 28;
  @override
  double get iconSize => 16;
  @override
  double get hitTargetMin => 28;
}

class _WpfMotion implements FMotionTokens {
  const _WpfMotion();
  @override
  Duration get fast => const Duration(milliseconds: 80);
  @override
  Duration get normal => const Duration(milliseconds: 120);
  @override
  Duration get slow => const Duration(milliseconds: 180);
  @override
  Curve get standard => Curves.easeOut;
  @override
  Curve get emphasized => Curves.easeInOut;
}

class _WpfComponents implements FComponentStyles {
  _WpfComponents(Brightness brightness) : _tokens = _WpfTokens(brightness) {
    button = _WpfButtons(_tokens);
    input = _WpfFields(_tokens);
    select = _WpfFields(_tokens);
    panel = _WpfPanels(_tokens);
    menu = _WpfMenus(_tokens);
  }

  final _WpfTokens _tokens;
  @override
  late final FButtonStyleResolver button;
  @override
  late final FInputStyleResolver input;
  @override
  late final FSelectStyleResolver select;
  @override
  late final FPanelStyleResolver panel;
  @override
  late final FMenuStyleResolver menu;
}

class _WpfButtons implements FButtonStyleResolver {
  _WpfButtons(this.tokens);
  final _WpfTokens tokens;

  @override
  FButtonVisualStyle resolve(
    FButtonVariant variant,
    FControlSize size,
    Set<FControlState> states,
  ) {
    final colors = tokens.colors;
    final disabled = states.contains(FControlState.disabled);
    final hovered = states.contains(FControlState.hovered);
    final pressed = states.contains(FControlState.pressed);
    final primary = variant == FButtonVariant.primary;
    final danger = variant == FButtonVariant.danger;
    final background = disabled
        ? colors.surfaceSubtle
        : primary
            ? pressed
                ? colors.accentPressed
                : hovered
                    ? colors.accentHover
                    : colors.accent
            : danger
                ? pressed
                    ? colors.accentPressed
                    : colors.danger
                : variant == FButtonVariant.secondary
                    ? pressed
                        ? colors.selection
                        : hovered
                            ? colors.hover
                            : colors.surfaceSubtle
                    : hovered
                        ? colors.hover
                        : const Color(0x00000000);
    final foreground = disabled
        ? colors.textDisabled
        : primary || danger
            ? colors.accentForeground
            : colors.textPrimary;
    return FButtonVisualStyle(
      background: background,
      foreground: foreground,
      border: colors.borderStrong,
      borderWidth: variant == FButtonVariant.subtle ? 0 : 1,
      radius: tokens.radius.control,
      padding: EdgeInsets.symmetric(
        horizontal: size == FControlSize.compact ? 8 : 12,
      ),
      textStyle: tokens.typography.command,
      height: switch (size) {
        FControlSize.compact => tokens.density.compactControlHeight,
        FControlSize.medium => tokens.density.controlHeight,
        FControlSize.large => 36,
      },
      focusRing:
          states.contains(FControlState.focused) ? colors.focusRing : null,
    );
  }
}

class _WpfFields implements FInputStyleResolver, FSelectStyleResolver {
  _WpfFields(this.tokens);
  final _WpfTokens tokens;

  @override
  FFieldVisualStyle resolve(FControlSize size, Set<FControlState> states) {
    final colors = tokens.colors;
    final disabled = states.contains(FControlState.disabled);
    final focused = states.contains(FControlState.focused);
    return FFieldVisualStyle(
      background: disabled ? colors.surfaceSubtle : colors.surface,
      foreground: disabled ? colors.textDisabled : colors.textPrimary,
      hint: colors.textSecondary,
      border: focused ? colors.focusRing : colors.borderStrong,
      borderWidth: focused ? 2 : 1,
      radius: tokens.radius.control,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      textStyle: tokens.typography.body,
      height: switch (size) {
        FControlSize.compact => tokens.density.compactControlHeight,
        FControlSize.medium => tokens.density.controlHeight,
        FControlSize.large => 38,
      },
      focusRing: focused ? colors.focusRing.withOpacity(.12) : null,
    );
  }
}

class _WpfPanels implements FPanelStyleResolver {
  _WpfPanels(this.tokens);
  final _WpfTokens tokens;

  @override
  FPanelVisualStyle resolve({bool raised = false}) => FPanelVisualStyle(
        background:
            raised ? tokens.colors.surfaceRaised : tokens.colors.surface,
        border: tokens.colors.border,
        borderWidth: 1,
        radius: tokens.radius.panel,
        padding: const EdgeInsets.all(12),
      );
}

class _WpfMenus implements FMenuStyleResolver {
  _WpfMenus(this.tokens);
  final _WpfTokens tokens;

  @override
  FMenuVisualStyle resolve() => FMenuVisualStyle(
        background: tokens.colors.surfaceOverlay,
        foreground: tokens.colors.textPrimary,
        hover: tokens.colors.hover,
        border: tokens.colors.borderStrong,
        radius: tokens.radius.popup,
        padding: const EdgeInsets.all(3),
        textStyle: tokens.typography.body,
      );
}
