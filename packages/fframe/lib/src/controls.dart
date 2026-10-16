// Keep compatibility with the declared Flutter 3.22 floor.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fframe_layout/fframe_layout.dart';
import 'package:fframe_design/fframe_design.dart';

import 'primitives.dart';

/// A behavior-sharing button whose appearance comes from [FTheme].
class FButton extends StatefulWidget {
  const FButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = FButtonVariant.secondary,
    this.size = FControlSize.medium,
    this.autofocus = false,
    this.focusNode,
    this.tooltip,
  });

  final FVoidCallback? onPressed;
  final FWidget child;
  final FButtonVariant variant;
  final FControlSize size;
  final bool autofocus;
  final FFocusNode? focusNode;
  final String? tooltip;

  @override
  State<FButton> createState() => _FButtonState();
}

class _FButtonState extends State<FButton> {
  late FFocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FFocusNode();
  }

  @override
  void didUpdateWidget(FButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FFocusNode();
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  FWidget build(FBuildContext context) {
    final enabled = widget.onPressed != null;
    final states = <FControlState>{
      if (_hovered) FControlState.hovered,
      if (_focused) FControlState.focused,
      if (_pressed) FControlState.pressed,
      if (!enabled) FControlState.disabled,
    };
    final theme = FTheme.of(context);
    final style = theme.designSystem.components.button
        .resolve(widget.variant, widget.size, states);
    final height = _controlHeight(theme, widget.size, style.height);
    final button = FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: enabled,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (enabled) widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                _focusNode.requestFocus();
                widget.onPressed?.call();
              }
            : null,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: _FControlSurface(
          duration: theme.tokens.motion.fast,
          curve: theme.tokens.motion.standard,
          height: height,
          padding: style.padding,
          background: style.background,
          radius: style.radius,
          borderColor: style.border,
          borderWidth: style.borderWidth,
          boxShadow: style.focusRing == null
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: style.focusRing!.withOpacity(0.28),
                    blurRadius: 0,
                    spreadRadius: 2,
                  ),
                ],
          alignment: Alignment.center,
          child: DefaultTextStyle.merge(
            style: style.textStyle.copyWith(color: style.foreground),
            child: IconTheme(
              data: IconThemeData(
                  color: style.foreground,
                  size: theme.effectiveDensity.iconSize),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      focusable: enabled,
      label: widget.tooltip,
      child: widget.tooltip == null
          ? button
          : FTooltip(message: widget.tooltip!, child: button),
    );
  }
}

/// Shared surface for styled controls.
///
/// The border is painted as a foreground decoration, so state changes to its
/// width never add insets or change the control's measured size.
class _FControlSurface extends StatelessWidget {
  const _FControlSurface({
    required this.background,
    required this.radius,
    required this.borderColor,
    required this.borderWidth,
    required this.child,
    this.duration = Duration.zero,
    this.curve = Curves.linear,
    this.height,
    this.constraints,
    this.padding = EdgeInsets.zero,
    this.boxShadow,
    this.alignment,
  });

  final FColor background;
  final BorderRadius radius;
  final FColor borderColor;
  final double borderWidth;
  final FWidget child;
  final Duration duration;
  final Curve curve;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;

  @override
  FWidget build(FBuildContext context) => AnimatedContainer(
        duration: duration,
        curve: curve,
        height: height,
        constraints: constraints,
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          boxShadow: boxShadow,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        alignment: alignment,
        child: child,
      );
}

/// Compact icon-only button with the same keyboard and focus behavior as [FButton].
class FIconButton extends StatelessWidget {
  const FIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = FControlSize.medium,
  });

  final FWidget icon;
  final FVoidCallback? onPressed;
  final String tooltip;
  final FControlSize size;

  @override
  FWidget build(FBuildContext context) => FButton(
        onPressed: onPressed,
        variant: FButtonVariant.subtle,
        size: size,
        tooltip: tooltip,
        child: icon,
      );
}

/// A themed bordered surface.
class FPanel extends StatelessWidget {
  const FPanel({
    super.key,
    required this.child,
    this.padding,
    this.raised = false,
  });

  final FWidget child;
  final FEdgeInsetsGeometry? padding;
  final bool raised;

  @override
  FWidget build(FBuildContext context) {
    final style = FTheme.of(context)
        .designSystem
        .components
        .panel
        .resolve(raised: raised);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: style.radius,
        border: Border.all(color: style.border, width: style.borderWidth),
      ),
      child: Padding(padding: padding ?? style.padding, child: child),
    );
  }
}

/// A semantic divider that uses the current system's border token.
class FDivider extends StatelessWidget {
  const FDivider({
    super.key,
    this.axis = FLayoutAxis.horizontal,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = 1,
  });

  final FLayoutAxis axis;
  final double indent;
  final double endIndent;
  final double thickness;

  @override
  FWidget build(FBuildContext context) {
    final color = FTheme.of(context).tokens.colors.border;
    final child = axis == FLayoutAxis.horizontal
        ? Padding(
            padding: EdgeInsetsDirectional.only(
              start: indent,
              end: endIndent,
            ),
            child: Container(height: thickness, color: color),
          )
        : Padding(
            padding: EdgeInsetsDirectional.only(
              top: indent,
              bottom: endIndent,
            ),
            child: Container(width: thickness, color: color),
          );
    return Semantics(container: true, child: child);
  }
}

/// A themed single-axis scroll area with a visible desktop scrollbar.
class FScrollArea extends StatefulWidget {
  const FScrollArea({
    super.key,
    required this.child,
    this.controller,
    this.scrollDirection = FLayoutAxis.vertical,
    this.padding,
    this.thumbVisibility = true,
    this.physics,
  });

  final FWidget child;
  final FScrollController? controller;
  final FLayoutAxis scrollDirection;
  final FEdgeInsetsGeometry? padding;
  final bool thumbVisibility;
  final FScrollPhysics? physics;

  @override
  State<FScrollArea> createState() => _FScrollAreaState();
}

class _FScrollAreaState extends State<FScrollArea> {
  late FScrollController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? FScrollController();
  }

  @override
  void didUpdateWidget(FScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? FScrollController();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  FWidget build(FBuildContext context) => RawScrollbar(
        controller: _controller,
        thumbVisibility: widget.thumbVisibility,
        interactive: true,
        child: SingleChildScrollView(
          controller: _controller,
          primary: false,
          scrollDirection: widget.scrollDirection == FLayoutAxis.horizontal
              ? Axis.horizontal
              : Axis.vertical,
          padding: widget.padding,
          physics: widget.physics,
          child: widget.child,
        ),
      );
}

/// A Material-independent text input backed by Flutter's EditableText.
class FTextField extends StatefulWidget {
  const FTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.size = FControlSize.medium,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.textStyle,
    this.cursorColor,
    this.backgroundCursorColor,
    this.selectionColor,
  });

  final FTextEditingController? controller;
  final FFocusNode? focusNode;
  final String? label;
  final String? placeholder;
  final FWidget? leading;
  final FWidget? trailing;
  final FValueChanged<String>? onChanged;
  final FValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FControlSize size;
  final FTextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final FTextStyle? textStyle;
  final FColor? cursorColor;
  final FColor? backgroundCursorColor;
  final FColor? selectionColor;

  @override
  State<FTextField> createState() => _FTextFieldState();
}

class _FTextFieldState extends State<FTextField> {
  late FTextEditingController _controller;
  late FFocusNode _focusNode;
  bool _hovered = false;
  late bool _ownsController;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? FTextEditingController();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FFocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(FTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FFocusNode();
      _focusNode.addListener(_onFocusChange);
    }
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onControllerChanged);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? FTextEditingController();
      _controller.addListener(_onControllerChanged);
    }
  }

  void _onFocusChange() => setState(() {});
  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onControllerChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final states = <FControlState>{
      if (_hovered) FControlState.hovered,
      if (_focusNode.hasFocus) FControlState.focused,
      if (!widget.enabled) FControlState.disabled,
    };
    final style =
        theme.designSystem.components.input.resolve(widget.size, states);
    final height = _controlHeight(theme, widget.size, style.height);
    final singleLine = widget.maxLines == 1 && !widget.expands;
    final field = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: _FControlSurface(
        duration: theme.tokens.motion.fast,
        height: singleLine ? height : null,
        constraints: singleLine ? null : BoxConstraints(minHeight: height),
        padding: style.padding,
        background: style.background,
        radius: style.radius,
        borderColor: style.border,
        borderWidth: style.borderWidth,
        boxShadow: style.focusRing == null
            ? null
            : <BoxShadow>[
                BoxShadow(
                    color: style.focusRing!, blurRadius: 0, spreadRadius: 2),
              ],
        child: Row(
          children: <FWidget>[
            if (widget.leading != null) ...<FWidget>[
              widget.leading!,
              const SizedBox(width: 8)
            ],
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <FWidget>[
                  if (widget.placeholder != null && _controller.text.isEmpty)
                    IgnorePointer(
                      child: Text(widget.placeholder!,
                          style: style.textStyle.copyWith(color: style.hint)),
                    ),
                  ExcludeFocus(
                    excluding: !widget.enabled,
                    child: EditableText(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: (widget.textStyle ?? style.textStyle).copyWith(
                          color: widget.textStyle?.color ?? style.foreground),
                      cursorColor:
                          widget.cursorColor ?? theme.tokens.colors.accent,
                      backgroundCursorColor:
                          widget.backgroundCursorColor ?? style.foreground,
                      selectionColor: widget.selectionColor ??
                          theme.tokens.colors.selection,
                      readOnly: widget.readOnly || !widget.enabled,
                      autofocus: widget.autofocus,
                      textInputAction: widget.textInputAction,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      expands: widget.expands,
                      textDirection: Directionality.of(context),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.trailing != null) ...<FWidget>[
              const SizedBox(width: 8),
              widget.trailing!
            ],
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <FWidget>[
        if (widget.label != null) ...<FWidget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(widget.label!,
                style: theme.tokens.typography.label
                    .copyWith(color: theme.tokens.colors.textSecondary)),
          ),
        ],
        Semantics(
            textField: true,
            focusable: widget.enabled,
            enabled: widget.enabled,
            label: widget.label ?? widget.placeholder,
            child: field),
      ],
    );
  }
}

/// Search field with a built-in search glyph and clear action.
class FSearchBox extends StatefulWidget {
  const FSearchBox({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.size = FControlSize.medium,
  });

  final FTextEditingController? controller;
  final FFocusNode? focusNode;
  final String placeholder;
  final FValueChanged<String>? onChanged;
  final FValueChanged<String>? onSubmitted;
  final bool enabled;
  final FControlSize size;

  @override
  State<FSearchBox> createState() => _FSearchBoxState();
}

class _FSearchBoxState extends State<FSearchBox> {
  late FTextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? FTextEditingController();
  }

  @override
  void didUpdateWidget(FSearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? FTextEditingController();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  FWidget build(FBuildContext context) {
    final colors = FTheme.of(context).tokens.colors;
    return FTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      placeholder: widget.placeholder,
      enabled: widget.enabled,
      size: widget.size,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      leading: CustomPaint(
        size: const Size(16, 16),
        painter: _SearchGlyphPainter(colors.textSecondary),
      ),
      trailing: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox.shrink()
            : FIconButton(
                icon: Text('×',
                    style:
                        FTextStyle(color: colors.textSecondary, fontSize: 18)),
                onPressed: widget.enabled ? _controller.clear : null,
                tooltip: 'Clear search',
                size: FControlSize.compact,
              ),
      ),
    );
  }
}

class _SearchGlyphPainter extends CustomPainter {
  const _SearchGlyphPainter(this.color);
  final FColor color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(
        FOffset(size.width * .43, size.height * .43), size.width * .27, paint);
    canvas.drawLine(FOffset(size.width * .63, size.height * .63),
        FOffset(size.width * .9, size.height * .9), paint);
  }

  @override
  bool shouldRepaint(_SearchGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// An accessible, keyboard-operable checkbox.
class FCheckbox extends StatefulWidget {
  const FCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.focusNode,
    this.autofocus = false,
  });
  final bool? value;
  final FValueChanged<bool?>? onChanged;
  final FWidget? label;
  final FFocusNode? focusNode;
  final bool autofocus;

  @override
  State<FCheckbox> createState() => _FCheckboxState();
}

class _FCheckboxState extends State<FCheckbox> {
  late FFocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FFocusNode();
  }

  @override
  void didUpdateWidget(FCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FFocusNode();
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onChanged == null) return;
    _focusNode.requestFocus();
    widget.onChanged!(widget.value == true ? false : true);
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    final enabled = widget.onChanged != null;
    final selected = widget.value == true;
    final control = Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: selected
            ? colors.accent
            : enabled
                ? colors.surface
                : colors.surfaceSubtle,
        border: Border.all(
          color: _focused
              ? colors.focusRing
              : selected
                  ? colors.accent
                  : enabled
                      ? colors.borderStrong
                      : colors.border,
        ),
        borderRadius: theme.tokens.radius.control,
        boxShadow: _focused
            ? <BoxShadow>[
                BoxShadow(
                    color: colors.focusRing.withOpacity(.2), spreadRadius: 2),
              ]
            : null,
      ),
      child: selected
          ? CustomPaint(painter: _CheckPainter(colors.accentForeground))
          : null,
    );
    return Semantics(
      checked: selected,
      mixed: widget.value == null,
      enabled: enabled,
      focusable: enabled,
      label: widget.label is Text ? (widget.label as Text).data : null,
      onTap: enabled ? _toggle : null,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: enabled,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _toggle();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: theme.effectiveDensity.hitTargetMin,
              minHeight: theme.effectiveDensity.hitTargetMin,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
              child: Row(mainAxisSize: MainAxisSize.min, children: <FWidget>[
                control,
                if (widget.label != null) ...<FWidget>[
                  const SizedBox(width: 8),
                  widget.label!,
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.color);
  final FColor color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
        Path()
          ..moveTo(size.width * .22, size.height * .52)
          ..lineTo(size.width * .43, size.height * .72)
          ..lineTo(size.width * .8, size.height * .3),
        paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.color != color;
}

/// A compact desktop switch with a minimum semantic hit target.
class FSwitch extends StatefulWidget {
  const FSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.focusNode,
    this.autofocus = false,
  });
  final bool value;
  final FValueChanged<bool>? onChanged;
  final FWidget? label;
  final FFocusNode? focusNode;
  final bool autofocus;

  @override
  State<FSwitch> createState() => _FSwitchState();
}

class _FSwitchState extends State<FSwitch> {
  late FFocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FFocusNode();
  }

  @override
  void didUpdateWidget(FSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FFocusNode();
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onChanged == null) return;
    _focusNode.requestFocus();
    widget.onChanged!(!widget.value);
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    final enabled = widget.onChanged != null;
    return Semantics(
      toggled: widget.value,
      enabled: enabled,
      focusable: enabled,
      label: widget.label is Text ? (widget.label as Text).data : null,
      onTap: enabled ? _toggle : null,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: enabled,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _toggle();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: theme.effectiveDensity.hitTargetMin,
              minHeight: theme.effectiveDensity.hitTargetMin,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
              child: Row(mainAxisSize: MainAxisSize.min, children: <FWidget>[
                AnimatedContainer(
                  duration: theme.tokens.motion.fast,
                  width: 34,
                  height: 20,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: !enabled
                        ? colors.border
                        : widget.value
                            ? colors.accent
                            : colors.borderStrong,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _focused
                        ? <BoxShadow>[
                            BoxShadow(
                                color: colors.focusRing.withOpacity(.2),
                                spreadRadius: 2),
                          ]
                        : null,
                  ),
                  child: AnimatedAlign(
                    duration: theme.tokens.motion.fast,
                    curve: theme.tokens.motion.standard,
                    alignment: widget.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: enabled ? colors.surface : colors.surfaceSubtle,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (widget.label != null) ...<FWidget>[
                  const SizedBox(width: 8),
                  widget.label!,
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A menu surface whose item layout and interaction are shared by all systems.
class FMenu extends StatelessWidget {
  const FMenu({super.key, required this.items, this.width});
  final List<FMenuItem> items;
  final double? width;

  @override
  FWidget build(FBuildContext context) {
    final style = FTheme.of(context).designSystem.components.menu.resolve();
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        width: width,
        padding: style.padding,
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: style.radius,
          border: Border.all(color: style.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: const FColor(0x33000000),
                blurRadius: 14,
                offset: const FOffset(0, 4))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <FWidget>[
            for (final item in items)
              if (item.separator)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(height: 1, color: style.border))
              else
                _FMenuRow(item: item, style: style),
          ],
        ),
      ),
    );
  }
}

class FMenuItem {
  const FMenuItem(
      {required this.label,
      required this.onSelected,
      this.leading,
      this.shortcut,
      this.enabled = true,
      this.selected = false,
      this.highlighted = false})
      : separator = false;
  const FMenuItem.separator()
      : label = '',
        onSelected = null,
        leading = null,
        shortcut = null,
        enabled = false,
        selected = false,
        highlighted = false,
        separator = true;
  final String label;
  final FVoidCallback? onSelected;
  final FWidget? leading;
  final String? shortcut;
  final bool enabled;
  final bool selected;
  final bool highlighted;
  final bool separator;
}

class _FMenuRow extends StatefulWidget {
  const _FMenuRow({required this.item, required this.style});
  final FMenuItem item;
  final FMenuVisualStyle style;
  @override
  State<_FMenuRow> createState() => _FMenuRowState();
}

class _FMenuRowState extends State<_FMenuRow> {
  bool _hovered = false;
  bool _focused = false;
  final _focusNode = FFocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FFocusNode node, KeyEvent event) {
    if (!widget.item.enabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.item.onSelected?.call();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      node.nextFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      node.previousFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  FWidget build(FBuildContext context) => Semantics(
        button: true,
        enabled: widget.item.enabled,
        selected: widget.item.selected,
        label: widget.item.label,
        child: Focus(
          focusNode: _focusNode,
          canRequestFocus: widget.item.enabled,
          onKeyEvent: _onKey,
          onFocusChange: (value) => setState(() => _focused = value),
          child: MouseRegion(
            cursor: widget.item.enabled
                ? SystemMouseCursors.click
                : MouseCursor.defer,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.item.enabled
                  ? () {
                      _focusNode.requestFocus();
                      widget.item.onSelected?.call();
                    }
                  : null,
              child: Container(
                height: FTheme.of(context).effectiveDensity.rowHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _hovered || _focused || widget.item.highlighted
                      ? widget.style.hover
                      : widget.item.selected
                          ? FTheme.of(context).tokens.colors.selection
                          : const FColor(0x00000000),
                  borderRadius: widget.style.radius,
                ),
                child: Row(children: <FWidget>[
                  if (widget.item.leading != null) ...<FWidget>[
                    widget.item.leading!,
                    const SizedBox(width: 8)
                  ],
                  Expanded(
                      child: Text(widget.item.label,
                          style: widget.style.textStyle.copyWith(
                              color: widget.item.enabled
                                  ? widget.style.foreground
                                  : FTheme.of(context)
                                      .tokens
                                      .colors
                                      .textDisabled))),
                  if (widget.item.shortcut != null)
                    Text(widget.item.shortcut!,
                        style: widget.style.textStyle.copyWith(
                            color: FTheme.of(context)
                                .tokens
                                .colors
                                .textSecondary)),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// Desktop select control using a Flutter overlay portal for its popup.
class FSelect<T> extends StatefulWidget {
  const FSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Select…',
    this.enabled = true,
    this.size = FControlSize.medium,
  });
  final List<FSelectItem<T>> items;
  final T? value;
  final FValueChanged<T?>? onChanged;
  final String placeholder;
  final bool enabled;
  final FControlSize size;
  @override
  State<FSelect<T>> createState() => _FSelectState<T>();
}

class FSelectItem<T> {
  const FSelectItem(
      {required this.value, required this.label, this.enabled = true});
  final T value;
  final String label;
  final bool enabled;
}

class _FSelectState<T> extends State<FSelect<T>> {
  final _portal = OverlayPortalController();
  final _targetKey = GlobalKey();
  final _focusNode = FFocusNode();
  bool _open = false;
  bool _hovered = false;
  int _highlighted = 0;
  bool get _enabled => widget.enabled && widget.onChanged != null;
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _setOpen(bool value) {
    if ((value && !_enabled) || _open == value) return;
    setState(() => _open = value);
    if (value) {
      _portal.show();
      _focusNode.requestFocus();
      final index = widget.items.indexWhere(
        (item) => item.value == widget.value && item.enabled,
      );
      final firstEnabled = widget.items.indexWhere((item) => item.enabled);
      _highlighted = index < 0 ? (firstEnabled < 0 ? 0 : firstEnabled) : index;
    } else {
      _portal.hide();
    }
  }

  void _select(FSelectItem<T> item) {
    if (!item.enabled) return;
    _setOpen(false);
    widget.onChanged?.call(item.value);
  }

  void _moveHighlight(int delta) {
    if (widget.items.isEmpty) return;
    var index = _highlighted;
    for (var attempts = 0; attempts < widget.items.length; attempts++) {
      index = (index + delta + widget.items.length) % widget.items.length;
      if (widget.items[index].enabled) {
        setState(() => _highlighted = index);
        return;
      }
    }
  }

  KeyEventResult _onKey(FFocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape && _open) {
      _setOpen(false);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (!_open) {
        _setOpen(true);
        return KeyEventResult.handled;
      }
      if (_highlighted >= 0 &&
          _highlighted < widget.items.length &&
          widget.items[_highlighted].enabled) {
        _select(widget.items[_highlighted]);
      }
      return KeyEventResult.handled;
    }
    if (_open &&
        (event.logicalKey == LogicalKeyboardKey.arrowDown ||
            event.logicalKey == LogicalKeyboardKey.arrowUp) &&
        widget.items.isNotEmpty) {
      _moveHighlight(
        event.logicalKey == LogicalKeyboardKey.arrowDown ? 1 : -1,
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    final style = theme.designSystem.components.select
        .resolve(widget.size, <FControlState>{
      if (_open || _focusNode.hasFocus) FControlState.focused,
      if (_hovered) FControlState.hovered,
      if (!_enabled) FControlState.disabled
    });
    final height = _controlHeight(theme, widget.size, style.height);
    final selected =
        widget.items.where((item) => item.value == widget.value).firstOrNull;
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => Stack(
        children: <FWidget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _setOpen(false),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: FAnchoredLayout(
              anchor: _overlayAnchorRect(context, _targetKey),
              policy: FPlacementPolicy(
                preferred: FPlacement.bottomStart,
                fallback: const <FPlacement>[FPlacement.topStart],
                mainAxisOffset: 4,
              ),
              child: FMenu(
                width: _overlayAnchorWidth(_targetKey, fallback: 180),
                items: <FMenuItem>[
                  for (var index = 0; index < widget.items.length; index++)
                    FMenuItem(
                      label: widget.items[index].label,
                      enabled: widget.items[index].enabled,
                      selected: widget.items[index].value == widget.value,
                      highlighted: index == _highlighted,
                      leading: widget.items[index].value == widget.value
                          ? Text('✓', style: FTextStyle(color: colors.accent))
                          : const SizedBox(width: 10),
                      onSelected: () => _select(widget.items[index]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: KeyedSubtree(
        key: _targetKey,
        child: Semantics(
          button: true,
          focusable: _enabled,
          enabled: _enabled,
          expanded: _open,
          label: selected?.label ?? widget.placeholder,
          onTap: _enabled
              ? () {
                  _focusNode.requestFocus();
                  _setOpen(!_open);
                }
              : null,
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: _enabled,
            onKeyEvent: _onKey,
            onFocusChange: (_) => setState(() {}),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _enabled
                    ? () {
                        _focusNode.requestFocus();
                        _setOpen(!_open);
                      }
                    : null,
                child: _FControlSurface(
                  duration: theme.tokens.motion.fast,
                  constraints: BoxConstraints(minHeight: height, minWidth: 180),
                  padding: style.padding,
                  background: style.background,
                  radius: style.radius,
                  borderColor: style.border,
                  borderWidth: style.borderWidth,
                  boxShadow: style.focusRing == null
                      ? null
                      : <BoxShadow>[
                          BoxShadow(
                            color: style.focusRing!,
                            blurRadius: 0,
                            spreadRadius: 2,
                          ),
                        ],
                  child: Row(children: <FWidget>[
                    Expanded(
                        child: Text(selected?.label ?? widget.placeholder,
                            style: style.textStyle.copyWith(
                                color: selected == null
                                    ? style.hint
                                    : style.foreground))),
                    Text(_open ? '⌃' : '⌄',
                        style: FTextStyle(
                            color: colors.textSecondary, fontSize: 16)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

Rect _overlayAnchorRect(FBuildContext overlayContext, GlobalKey targetKey) {
  final targetRender = targetKey.currentContext?.findRenderObject();
  final overlayRender = Overlay.of(overlayContext).context.findRenderObject();
  if (targetRender is! RenderBox || overlayRender is! RenderBox) {
    return Rect.zero;
  }
  final topLeft = targetRender.localToGlobal(
    FOffset.zero,
    ancestor: overlayRender,
  );
  return topLeft & targetRender.size;
}

double _overlayAnchorWidth(
  GlobalKey targetKey, {
  required double fallback,
}) {
  final targetRender = targetKey.currentContext?.findRenderObject();
  if (targetRender is RenderBox) return targetRender.size.width;
  return fallback;
}

double _controlHeight(FThemeData theme, FControlSize size, double fallback) {
  if (theme.density == null) return fallback;
  return switch (size) {
    FControlSize.compact => theme.effectiveDensity.compactControlHeight,
    FControlSize.medium => theme.effectiveDensity.controlHeight,
    FControlSize.large => fallback,
  };
}

/// A dismissible anchored popup built from Flutter overlay primitives.
class FPopover extends StatefulWidget {
  const FPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.offset = const FOffset(0, 4),
    this.placement = FPlacement.bottomStart,
    this.fallbackPlacements = const <FPlacement>[FPlacement.topStart],
    this.barrierDismissible = true,
  });

  final FWidget trigger;
  final FWidget content;
  final FOffset offset;
  final FPlacement placement;
  final List<FPlacement> fallbackPlacements;
  final bool barrierDismissible;

  @override
  State<FPopover> createState() => _FPopoverState();
}

class _FPopoverState extends State<FPopover> {
  final _portal = OverlayPortalController();
  final _targetKey = GlobalKey();
  final _focusNode = FFocusNode();
  bool _open = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _setOpen(bool value) {
    if (_open == value) return;
    setState(() => _open = value);
    if (value) {
      _portal.show();
    } else {
      _portal.hide();
    }
  }

  KeyEventResult _onKey(FFocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape && _open) {
        _setOpen(false);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _setOpen(!_open);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  FWidget build(FBuildContext context) => OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Stack(
          children: <FWidget>[
            if (widget.barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _setOpen(false),
                  child: const SizedBox.expand(),
                ),
              ),
            Positioned.fill(
              child: FAnchoredLayout(
                anchor: _overlayAnchorRect(context, _targetKey),
                policy: FPlacementPolicy(
                  preferred: widget.placement,
                  fallback: widget.fallbackPlacements,
                  mainAxisOffset: widget.offset.dy.abs(),
                  crossAxisOffset: widget.offset.dx,
                ),
                child: widget.content,
              ),
            ),
          ],
        ),
        child: KeyedSubtree(
          key: _targetKey,
          child: Semantics(
            button: true,
            focusable: true,
            expanded: _open,
            onTap: () => _setOpen(!_open),
            child: Focus(
              focusNode: _focusNode,
              onKeyEvent: _onKey,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) {
                    _focusNode.requestFocus();
                    _setOpen(!_open);
                  },
                  child: widget.trigger,
                ),
              ),
            ),
          ),
        ),
      );
}

/// A themed tooltip with delayed pointer and focus activation.
class FTooltip extends StatefulWidget {
  const FTooltip(
      {super.key,
      required this.message,
      required this.child,
      this.waitDuration = const Duration(milliseconds: 500)});
  final String message;
  final FWidget child;
  final Duration waitDuration;
  @override
  State<FTooltip> createState() => _FTooltipState();
}

class _FTooltipState extends State<FTooltip> {
  final _portal = OverlayPortalController();
  final _targetKey = GlobalKey();
  Timer? _timer;
  void _showLater() {
    _timer?.cancel();
    _timer = Timer(widget.waitDuration, _portal.show);
  }

  void _hide() {
    _timer?.cancel();
    _portal.hide();
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  FWidget build(FBuildContext context) {
    final style = FTheme.of(context).designSystem.components.menu.resolve();
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => Stack(
        children: <FWidget>[
          Positioned.fill(
            child: FAnchoredLayout(
              anchor: _overlayAnchorRect(context, _targetKey),
              policy: FPlacementPolicy(
                preferred: FPlacement.top,
                fallback: const <FPlacement>[FPlacement.bottom],
                mainAxisOffset: 6,
              ),
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: style.background,
                    border: Border.all(color: style.border),
                    borderRadius: style.radius,
                  ),
                  child: Text(
                    widget.message,
                    style: style.textStyle.copyWith(color: style.foreground),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: KeyedSubtree(
        key: _targetKey,
        child: FocusableActionDetector(
          onShowFocusHighlight: (focused) {
            if (focused) {
              _showLater();
            } else {
              _hide();
            }
          },
          child: MouseRegion(
              onEnter: (_) => _showLater(),
              onExit: (_) => _hide(),
              child: Semantics(tooltip: widget.message, child: widget.child)),
        ),
      ),
    );
  }
}

/// Semantic dialog content surface; place it in an app-owned modal route.
class FDialog extends StatelessWidget {
  const FDialog(
      {super.key,
      this.title,
      required this.content,
      this.actions = const <FWidget>[],
      this.width = 480});
  final FWidget? title;
  final FWidget content;
  final List<FWidget> actions;
  final double width;
  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.designSystem.components.panel.resolve(raised: true);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: width, maxHeight: MediaQuery.sizeOf(context).height * .9),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: theme.tokens.colors.surfaceOverlay,
              borderRadius: theme.tokens.radius.dialog,
              border: Border.all(color: style.border),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                    color: FColor(0x33000000),
                    blurRadius: 28,
                    offset: FOffset(0, 12))
              ]),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <FWidget>[
                if (title != null) ...<FWidget>[
                  DefaultTextStyle.merge(
                      style: theme.tokens.typography.title
                          .copyWith(color: theme.tokens.colors.textPrimary),
                      child: title!),
                  const SizedBox(height: 16)
                ],
                Flexible(child: content),
                if (actions.isNotEmpty) ...<FWidget>[
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions)
                ],
              ]),
        ),
      ),
    );
  }
}

/// Pushes a modal FFrame dialog route and returns the value passed to pop.
Future<T?> showFDialog<T>({
  required FBuildContext context,
  required FWidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) =>
    Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
      _FDialogRoute<T>(
        builder: builder,
        barrierDismissible: barrierDismissible,
      ),
    );

class _FDialogRoute<T> extends PopupRoute<T> {
  _FDialogRoute({required this.builder, required this.barrierDismissible});

  final FWidgetBuilder builder;
  @override
  final bool barrierDismissible;

  @override
  FColor get barrierColor => const FColor(0x66000000);

  @override
  String? get barrierLabel => 'Dismiss dialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 140);

  @override
  FWidget buildPage(
    FBuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      FocusTraversalGroup(
        child: FocusScope(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (barrierDismissible &&
                event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).maybePop();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: builder(context)),
            ),
          ),
        ),
      );

  @override
  FWidget buildTransitions(
    FBuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    FWidget child,
  ) =>
      FadeTransition(opacity: animation, child: child);
}

/// Sidebar surface used by desktop navigation layouts.
class FSidebar extends StatelessWidget {
  const FSidebar(
      {super.key,
      required this.children,
      this.header,
      this.footer,
      this.width = 232,
      this.collapsed = false});
  final List<FWidget> children;
  final FWidget? header;
  final FWidget? footer;
  final double width;
  final bool collapsed;
  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return Container(
      width: collapsed ? 56 : width,
      color: theme.tokens.colors.surfaceSubtle,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <FWidget>[
            if (header != null)
              Padding(padding: const EdgeInsets.all(12), child: header!),
            Expanded(
                child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    children: children)),
            if (footer != null)
              Padding(padding: const EdgeInsets.all(12), child: footer!),
          ]),
    );
  }
}

/// A selectable sidebar destination.
class FSidebarItem extends StatefulWidget {
  const FSidebarItem(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.selected = false,
      this.trailing,
      this.collapsed = false});
  final String label;
  final FVoidCallback? onPressed;
  final FWidget? icon;
  final bool selected;
  final FWidget? trailing;
  final bool collapsed;
  @override
  State<FSidebarItem> createState() => _FSidebarItemState();
}

class _FSidebarItemState extends State<FSidebarItem> {
  bool _hovered = false;
  bool _focused = false;
  final _focusNode = FFocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FFocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.onPressed == null) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onPressed!();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      node.nextFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      node.previousFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      enabled: widget.onPressed != null,
      label: widget.label,
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: widget.onPressed != null,
        onKeyEvent: _onKey,
        onFocusChange: (value) => setState(() => _focused = value),
        child: MouseRegion(
          cursor: widget.onPressed == null
              ? MouseCursor.defer
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed == null
                ? null
                : () {
                    _focusNode.requestFocus();
                    widget.onPressed!();
                  },
            child: Container(
              height: theme.effectiveDensity.navigationItemHeight,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                  color: selected
                      ? theme.tokens.colors.selection
                      : _hovered
                          ? theme.tokens.colors.hover
                          : const FColor(0x00000000),
                  borderRadius: theme.tokens.radius.control,
                  boxShadow: _focused
                      ? <BoxShadow>[
                          BoxShadow(
                            color:
                                theme.tokens.colors.focusRing.withOpacity(.2),
                            spreadRadius: 2,
                          ),
                        ]
                      : null),
              child: Row(children: <FWidget>[
                if (widget.icon != null) ...<FWidget>[
                  IconTheme(
                      data: IconThemeData(
                          color: selected
                              ? theme.tokens.colors.accent
                              : theme.tokens.colors.textSecondary,
                          size: theme.effectiveDensity.iconSize),
                      child: widget.icon!),
                  if (!widget.collapsed) const SizedBox(width: 9)
                ],
                if (!widget.collapsed)
                  Expanded(
                      child: Text(widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.tokens.typography.body.copyWith(
                              color: theme.tokens.colors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal))),
                if (widget.trailing != null && !widget.collapsed)
                  widget.trailing!,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tabs and their selected content.
class FTabs extends StatelessWidget {
  const FTabs(
      {super.key,
      required this.tabs,
      required this.selectedIndex,
      required this.onChanged,
      this.contentPadding = EdgeInsets.zero})
      : assert(tabs.length > 0),
        assert(selectedIndex >= 0 && selectedIndex < tabs.length);
  final List<FTab> tabs;
  final int selectedIndex;
  final FValueChanged<int> onChanged;
  final FEdgeInsetsGeometry contentPadding;
  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <FWidget>[
          Row(children: <FWidget>[
            for (var i = 0; i < tabs.length; i++)
              _FTabButton(
                  tab: tabs[i],
                  selected: i == selectedIndex,
                  onPressed: () => onChanged(i)),
          ]),
          Container(height: 1, color: theme.tokens.colors.border),
          Expanded(
              child: Padding(
                  padding: contentPadding, child: tabs[selectedIndex].child)),
        ]);
  }
}

class FTab {
  const FTab({required this.label, required this.child, this.icon});
  final String label;
  final FWidget child;
  final FWidget? icon;
}

class _FTabButton extends StatefulWidget {
  const _FTabButton(
      {required this.tab, required this.selected, required this.onPressed});
  final FTab tab;
  final bool selected;
  final FVoidCallback onPressed;
  @override
  State<_FTabButton> createState() => _FTabButtonState();
}

class _FTabButtonState extends State<_FTabButton> {
  bool _hovered = false;
  bool _focused = false;
  final _focusNode = FFocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FFocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onPressed();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onPressed();
      node.focusInDirection(TraversalDirection.right);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.onPressed();
      node.focusInDirection(TraversalDirection.left);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.tab.label,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        onFocusChange: (value) => setState(() => _focused = value),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _focusNode.requestFocus();
              widget.onPressed();
            },
            child: Container(
              constraints: BoxConstraints(
                  minHeight: theme.effectiveDensity.toolbarHeight),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                  color: _hovered
                      ? theme.tokens.colors.hover
                      : const FColor(0x00000000),
                  border: Border(
                      bottom: BorderSide(
                          color: widget.selected
                              ? theme.tokens.colors.accent
                              : const FColor(0x00000000),
                          width: 2)),
                  boxShadow: _focused
                      ? <BoxShadow>[
                          BoxShadow(
                            color:
                                theme.tokens.colors.focusRing.withOpacity(.2),
                            spreadRadius: 1,
                          ),
                        ]
                      : null),
              child: Row(mainAxisSize: MainAxisSize.min, children: <FWidget>[
                if (widget.tab.icon != null) ...<FWidget>[
                  widget.tab.icon!,
                  const SizedBox(width: 7)
                ],
                Text(widget.tab.label,
                    style: theme.tokens.typography.label.copyWith(
                        color: widget.selected
                            ? theme.tokens.colors.textPrimary
                            : theme.tokens.colors.textSecondary)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
