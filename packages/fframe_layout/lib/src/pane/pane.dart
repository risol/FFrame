import 'package:flutter/widgets.dart';

/// A pane displayed by [FSplitView].
class FPane extends StatelessWidget {
  /// Creates a preferred-size pane.
  const FPane({
    super.key,
    this.id,
    this.preferredSize = 240,
    this.minSize = 0,
    this.maxSize = double.infinity,
    this.collapsible = false,
    this.collapsedSize = 0,
    this.collapsePriority = 100,
    this.flex = 0,
    required this.child,
  })  : assert(minSize >= 0 && minSize < double.infinity),
        assert(maxSize >= minSize),
        assert(preferredSize == null ||
            preferredSize >= 0 && preferredSize < double.infinity),
        assert(collapsedSize >= 0 && collapsedSize < double.infinity);

  /// Creates a pane that receives a share of remaining space.
  const FPane.flex({
    super.key,
    this.id,
    this.minSize = 0,
    this.maxSize = double.infinity,
    this.collapsible = false,
    this.collapsedSize = 0,
    this.collapsePriority = 100,
    this.flex = 1,
    required this.child,
  })  : preferredSize = null,
        assert(minSize >= 0 && minSize < double.infinity),
        assert(maxSize >= minSize),
        assert(flex > 0),
        assert(collapsedSize >= 0 && collapsedSize < double.infinity);

  /// Stable id used by an [FPaneController].
  final String? id;

  /// Preferred extent for a fixed pane, or null when the pane is flexible.
  final double? preferredSize;

  /// Minimum extent while expanded.
  final double minSize;

  /// Maximum extent while expanded.
  final double maxSize;

  /// Whether users and adaptive layouts can collapse this pane.
  final bool collapsible;

  /// Extent retained while collapsed, usually zero.
  final double collapsedSize;

  /// Lower values collapse sooner when space is insufficient.
  final int collapsePriority;

  /// Flex weight. Zero denotes a preferred-size pane.
  final double flex;

  /// Pane contents.
  final Widget child;

  bool get isFlexible => flex > 0 && preferredSize == null;

  @override
  Widget build(BuildContext context) => child;
}
