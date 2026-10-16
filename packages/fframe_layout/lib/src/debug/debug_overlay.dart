import 'package:flutter/widgets.dart';

/// Displays local layout constraints above an application subtree in debug
/// sessions.
class FFrameDebugOverlay extends StatelessWidget {
  /// Creates a debug overlay.
  const FFrameDebugOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.alignment = AlignmentDirectional.topEnd,
    this.labelBuilder,
  });

  /// Content being inspected.
  final Widget child;

  /// Whether the overlay is displayed.
  final bool enabled;

  /// Overlay alignment.
  final AlignmentGeometry alignment;

  /// Optional custom label builder.
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      labelBuilder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (!enabled) return child;
          final label = labelBuilder?.call(context, constraints) ??
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xDD202124),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: DefaultTextStyle(
                    style:
                        const TextStyle(color: Color(0xFFFFFFFF), fontSize: 11),
                    child: Text(
                      '${constraints.maxWidth.toStringAsFixed(0)} × '
                      '${constraints.maxHeight.toStringAsFixed(0)}',
                    ),
                  ),
                ),
              );
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              child,
              Align(alignment: alignment, child: label),
            ],
          );
        },
      );
}

/// Highlights the bounds of its child during layout debugging.
class FLayoutVisualizer extends StatelessWidget {
  /// Creates a visualized region.
  const FLayoutVisualizer({
    super.key,
    required this.child,
    this.color = const Color(0xAAE53935),
    this.label,
  });

  /// Region to outline.
  final Widget child;

  /// Outline color.
  final Color color;

  /// Optional label displayed at the upper start edge.
  final String? label;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: 1),
                  ),
                ),
              ),
            ),
            if (label != null)
              PositionedDirectional(
                start: 0,
                top: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(label!, style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
