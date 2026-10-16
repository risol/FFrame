import 'package:flutter/widgets.dart';

import 'placement.dart';

/// Positions one child relative to an anchor rectangle in the same local
/// coordinate space. Place it inside a bounded [Stack].
class FAnchoredLayout extends StatelessWidget {
  /// Creates an anchored layout.
  const FAnchoredLayout({
    super.key,
    required this.anchor,
    required this.policy,
    required this.child,
  });

  /// Anchor rectangle in the containing stack's local coordinates.
  final Rect anchor;

  /// Placement preferences.
  final FPlacementPolicy policy;

  /// Overlay content.
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => CustomSingleChildLayout(
          delegate: _FAnchoredLayoutDelegate(
            anchor: anchor,
            policy: policy,
            viewport: Size(constraints.maxWidth, constraints.maxHeight),
            textDirection: Directionality.of(context),
          ),
          child: child,
        ),
      );
}

class _FAnchoredLayoutDelegate extends SingleChildLayoutDelegate {
  const _FAnchoredLayoutDelegate({
    required this.anchor,
    required this.policy,
    required this.viewport,
    required this.textDirection,
  });

  final Rect anchor;
  final FPlacementPolicy policy;
  final Size viewport;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(viewport);

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      FPlacementResolver.resolve(
        anchor: anchor,
        overlaySize: childSize,
        viewport: Offset.zero & size,
        policy: policy,
        textDirection: textDirection,
      ).rect.topLeft;

  @override
  bool shouldRelayout(_FAnchoredLayoutDelegate oldDelegate) =>
      anchor != oldDelegate.anchor ||
      policy != oldDelegate.policy ||
      viewport != oldDelegate.viewport ||
      textDirection != oldDelegate.textDirection;
}
