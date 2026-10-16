import 'package:flutter/widgets.dart';

/// A four-sided dock layout. Nested [FDockLayout]s can be used for additional
/// dock regions.
class FDockLayout extends StatelessWidget {
  /// Creates a dock layout using logical start/end placement.
  const FDockLayout({
    super.key,
    this.top,
    this.bottom,
    this.start,
    this.end,
    required this.body,
    this.topSize,
    this.bottomSize,
    this.startSize = 240,
    this.endSize = 320,
    this.gap = 0,
  }) : assert(gap >= 0);

  /// Region docked to the top.
  final Widget? top;

  /// Region docked to the bottom.
  final Widget? bottom;

  /// Region docked to the text direction's start edge.
  final Widget? start;

  /// Region docked to the text direction's end edge.
  final Widget? end;

  /// Remaining central region.
  final Widget body;

  /// Optional fixed top extent. Defaults to the child's natural height.
  final double? topSize;

  /// Optional fixed bottom extent. Defaults to the child's natural height.
  final double? bottomSize;

  /// Start region width.
  final double startSize;

  /// End region width.
  final double endSize;

  /// Spacing between adjacent regions.
  final double gap;

  @override
  Widget build(BuildContext context) {
    Widget middle = Row(
      textDirection: Directionality.of(context),
      children: <Widget>[
        if (start != null) SizedBox(width: startSize, child: start),
        if (start != null) SizedBox(width: gap),
        Expanded(child: body),
        if (end != null) SizedBox(width: gap),
        if (end != null) SizedBox(width: endSize, child: end),
      ],
    );
    if (top != null) {
      middle = Column(
        children: <Widget>[
          SizedBox(height: topSize, child: top),
          SizedBox(height: gap),
          Expanded(child: middle),
        ],
      );
    }
    if (bottom != null) {
      middle = Column(
        children: <Widget>[
          Expanded(child: middle),
          SizedBox(height: gap),
          SizedBox(height: bottomSize, child: bottom),
        ],
      );
    }
    return middle;
  }
}
