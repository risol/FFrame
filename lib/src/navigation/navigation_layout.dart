import 'package:flutter/widgets.dart';

/// Adaptive presentation modes for application navigation.
enum FNavigationMode { expanded, compact, minimal, overlay }

/// Width thresholds and rail widths for [FAdaptiveNavigationLayout].
@immutable
class FNavigationPolicy {
  /// Creates navigation layout policy.
  const FNavigationPolicy({
    this.expandedBreakpoint = 1200,
    this.compactBreakpoint = 720,
    this.expandedWidth = 240,
    this.compactWidth = 56,
  })  : assert(expandedBreakpoint >= compactBreakpoint),
        assert(compactBreakpoint >= 0),
        assert(expandedWidth >= compactWidth),
        assert(compactWidth >= 0);

  /// Width at which expanded navigation can be used.
  final double expandedBreakpoint;

  /// Width at which compact navigation can be used.
  final double compactBreakpoint;

  /// Expanded navigation width.
  final double expandedWidth;

  /// Compact navigation width.
  final double compactWidth;
}

/// Places a navigation region beside or over its content.
class FNavigationLayout extends StatelessWidget {
  /// Creates a navigation layout.
  const FNavigationLayout({
    super.key,
    required this.mode,
    required this.navigation,
    required this.content,
    this.expandedWidth = 240,
    this.compactWidth = 56,
    this.overlayVisible = false,
    this.overlayAlignment = AlignmentDirectional.centerStart,
  });

  /// Current navigation mode.
  final FNavigationMode mode;

  /// Navigation contents.
  final Widget navigation;

  /// Main contents.
  final Widget content;

  /// Width used for expanded mode.
  final double expandedWidth;

  /// Width used for compact mode.
  final double compactWidth;

  /// Whether the navigation overlay is visible in overlay mode.
  final bool overlayVisible;

  /// Alignment of the navigation overlay.
  final AlignmentGeometry overlayAlignment;

  @override
  Widget build(BuildContext context) {
    if (mode == FNavigationMode.minimal) return content;
    if (mode == FNavigationMode.overlay) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          content,
          if (overlayVisible)
            Align(
              alignment: overlayAlignment,
              child: SizedBox(width: expandedWidth, child: navigation),
            ),
        ],
      );
    }
    return Row(
      textDirection: Directionality.of(context),
      children: <Widget>[
        SizedBox(
          width:
              mode == FNavigationMode.expanded ? expandedWidth : compactWidth,
          child: navigation,
        ),
        Expanded(child: content),
      ],
    );
  }
}

/// Selects expanded, compact, or minimal navigation from local constraints.
class FAdaptiveNavigationLayout extends StatelessWidget {
  /// Creates an adaptive navigation layout.
  const FAdaptiveNavigationLayout({
    super.key,
    required this.navigationBuilder,
    required this.content,
    this.policy = const FNavigationPolicy(),
  });

  /// Builds navigation for the selected mode.
  final Widget Function(BuildContext context, FNavigationMode mode)
      navigationBuilder;

  /// Main contents.
  final Widget content;

  /// Width and mode selection policy.
  final FNavigationPolicy policy;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final mode = constraints.maxWidth >= policy.expandedBreakpoint
              ? FNavigationMode.expanded
              : constraints.maxWidth >= policy.compactBreakpoint
                  ? FNavigationMode.compact
                  : FNavigationMode.minimal;
          return FNavigationLayout(
            mode: mode,
            navigation: navigationBuilder(context, mode),
            content: content,
            expandedWidth: policy.expandedWidth,
            compactWidth: policy.compactWidth,
          );
        },
      );
}
