import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// Accessible drag and keyboard handle used between split panes.
class FSplitter extends StatefulWidget {
  /// Creates a splitter. [direction] is the axis along which panes are laid out.
  const FSplitter({
    super.key,
    required this.direction,
    required this.onResize,
    this.onReset,
    this.onEnd,
    this.onToggleCollapse,
    this.thickness = 6,
    this.hitTestExtent = 10,
    this.value = 0,
    this.min = 0,
    this.max = 1000,
    this.semanticLabel = 'Resize pane',
  })  : assert(thickness > 0),
        assert(hitTestExtent >= thickness),
        assert(min <= max);

  /// Main axis of the split view.
  final Axis direction;

  /// Applies a size delta in logical pixels.
  final ValueChanged<double> onResize;

  /// Resets adjacent panes to preferred sizes on double click or Home.
  final VoidCallback? onReset;

  /// Expands the first adjacent pane to its maximum extent.
  final VoidCallback? onEnd;

  /// Toggles the adjacent pane's collapse state on Enter or Space.
  final VoidCallback? onToggleCollapse;

  /// Visible divider thickness.
  final double thickness;

  /// Pointer hit target extent.
  final double hitTestExtent;

  /// Current pane value reported to accessibility services.
  final double value;

  /// Minimum value reported to accessibility services.
  final double min;

  /// Maximum value reported to accessibility services.
  final double max;

  /// Accessibility label.
  final String semanticLabel;

  @override
  State<FSplitter> createState() => _FSplitterState();
}

class _FSplitterState extends State<FSplitter> {
  final FocusNode _focusNode = FocusNode();
  bool _hovered = false;
  bool _focused = false;
  Offset? _dragStart;
  double _lastDragDistance = 0;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final horizontal = widget.direction == Axis.horizontal;
    final key = event.logicalKey;
    var delta = key == LogicalKeyboardKey.arrowLeft && horizontal ||
            key == LogicalKeyboardKey.arrowUp && !horizontal
        ? -10.0
        : key == LogicalKeyboardKey.arrowRight && horizontal ||
                key == LogicalKeyboardKey.arrowDown && !horizontal
            ? 10.0
            : 0.0;
    if (horizontal && Directionality.of(context) == TextDirection.rtl) {
      delta = -delta;
    }
    if (delta != 0) {
      widget.onResize(delta);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      widget.onReset?.call();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      widget.onEnd?.call();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      widget.onToggleCollapse?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = widget.direction == Axis.horizontal;
    final color = _hovered || _focused
        ? const Color(0xFF777777)
        : const Color(0x33777777);
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: widget.value.round().toString(),
      increasedValue: (widget.value + 10).round().toString(),
      decreasedValue: (widget.value - 10).round().toString(),
      onIncrease: () => widget.onResize(10),
      onDecrease: () => widget.onResize(-10),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        onFocusChange: (value) => setState(() => _focused = value),
        child: MouseRegion(
          cursor: horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _focusNode.requestFocus,
            onPanDown: (details) {
              _dragStart = details.globalPosition;
              _lastDragDistance = 0;
              _focusNode.requestFocus();
            },
            onPanUpdate: (details) {
              final origin = _dragStart;
              if (origin == null) return;
              var distance = horizontal
                  ? details.globalPosition.dx - origin.dx
                  : details.globalPosition.dy - origin.dy;
              if (horizontal &&
                  Directionality.of(context) == TextDirection.rtl) {
                distance = -distance;
              }
              final delta = distance - _lastDragDistance;
              _lastDragDistance = distance;
              widget.onResize(delta);
            },
            onPanEnd: (_) {
              _dragStart = null;
              _lastDragDistance = 0;
            },
            onDoubleTap: widget.onReset,
            child: SizedBox(
              width: horizontal ? widget.hitTestExtent : double.infinity,
              height: horizontal ? double.infinity : widget.hitTestExtent,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: SizedBox(
                    width: horizontal ? widget.thickness : double.infinity,
                    height: horizontal ? double.infinity : widget.thickness,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
