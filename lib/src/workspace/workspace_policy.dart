import 'package:flutter/widgets.dart';

/// Strategy used when a workspace pane does not fit beside the content.
enum FPaneCollapseBehavior { remove, overlay, compact }

/// Size and responsive behavior for a workspace pane.
@immutable
class FPanePolicy {
  /// Creates a pane policy.
  const FPanePolicy({
    this.preferredSize = 240,
    this.minSize = 160,
    this.maxSize = double.infinity,
    this.collapsePriority = 100,
    this.collapsible = true,
    this.compactSize = 56,
  })  : assert(preferredSize >= 0),
        assert(minSize >= 0),
        assert(maxSize >= minSize),
        assert(compactSize >= 0);

  /// Preferred expanded extent.
  final double preferredSize;

  /// Minimum expanded extent.
  final double minSize;

  /// Maximum expanded extent.
  final double maxSize;

  /// Lower values collapse first when space is limited.
  final int collapsePriority;

  /// Whether an explicit splitter or controller may collapse the pane.
  final bool collapsible;

  /// Width used by compact navigation when available.
  final double compactSize;
}

/// Size and collapse rules for a workspace.
@immutable
class FWorkspacePolicy {
  /// Creates a workspace policy.
  const FWorkspacePolicy({
    this.navigation = const FPanePolicy(
      preferredSize: 240,
      minSize: 180,
      collapsePriority: 2,
    ),
    this.content = const FPanePolicy(
      preferredSize: 0,
      minSize: 480,
      collapsible: false,
    ),
    this.inspector = const FPanePolicy(
      preferredSize: 320,
      minSize: 260,
      collapsePriority: 1,
    ),
    this.splitterThickness = 6,
    this.splitterHitTestExtent = 10,
  })  : assert(splitterThickness > 0),
        assert(splitterHitTestExtent >= splitterThickness);

  /// Navigation pane policy.
  final FPanePolicy navigation;

  /// Main content policy.
  final FPanePolicy content;

  /// Inspector pane policy.
  final FPanePolicy inspector;

  /// Splitter thickness for workspace panes.
  final double splitterThickness;

  /// Pointer hit extent reserved for workspace splitters.
  final double splitterHitTestExtent;
}
