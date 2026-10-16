import 'package:flutter/widgets.dart';

/// Common width classes. Use [FWindowClass.fromWidth] with custom thresholds
/// when an application has different layout requirements.
enum FWindowClass { compact, medium, expanded }

extension FWindowClassSizing on FWindowClass {
  /// Maps a window width to a class. The default boundaries are 600 and 1200
  /// logical pixels.
  static FWindowClass fromWidth(
    double width, {
    double compactMax = 600,
    double mediumMax = 1200,
  }) {
    if (width < compactMax) return FWindowClass.compact;
    if (width < mediumMax) return FWindowClass.medium;
    return FWindowClass.expanded;
  }
}

/// A value with one variant for each [FWindowClass].
@immutable
class FAdaptiveValue<T> {
  /// Creates a value for compact, medium, and expanded layouts.
  const FAdaptiveValue({
    required this.compact,
    required this.medium,
    required this.expanded,
  });

  /// Value for a compact layout.
  final T compact;

  /// Value for a medium layout.
  final T medium;

  /// Value for an expanded layout.
  final T expanded;

  /// Returns the value for [windowClass].
  T resolve(FWindowClass windowClass) => switch (windowClass) {
        FWindowClass.compact => compact,
        FWindowClass.medium => medium,
        FWindowClass.expanded => expanded,
      };
}

/// A set of width and height capabilities required by a layout state.
@immutable
class FLayoutCondition {
  /// Creates a condition. All provided limits must match.
  const FLayoutCondition({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.test,
  })  : assert(minWidth == null || minWidth >= 0),
        assert(maxWidth == null || maxWidth >= 0),
        assert(minHeight == null || minHeight >= 0),
        assert(maxHeight == null || maxHeight >= 0),
        assert(minWidth == null || maxWidth == null || minWidth <= maxWidth),
        assert(
            minHeight == null || maxHeight == null || minHeight <= maxHeight);

  /// Minimum available width.
  final double? minWidth;

  /// Maximum available width.
  final double? maxWidth;

  /// Minimum available height.
  final double? minHeight;

  /// Maximum available height.
  final double? maxHeight;

  /// Optional capability predicate.
  final bool Function(Size size)? test;

  /// Whether [size] satisfies every configured limit.
  bool matches(Size size) {
    if (minWidth != null && size.width < minWidth!) return false;
    if (maxWidth != null && size.width > maxWidth!) return false;
    if (minHeight != null && size.height < minHeight!) return false;
    if (maxHeight != null && size.height > maxHeight!) return false;
    return test?.call(size) ?? true;
  }
}

/// A conditional adaptive layout builder.
typedef FAdaptiveWidgetBuilder = Widget Function(BuildContext context);

/// One branch of [FAdaptiveBuilder].
@immutable
class FLayoutState {
  /// Creates a branch that applies when [when] matches.
  const FLayoutState({required this.when, required this.builder})
      : isFallback = false;

  const FLayoutState._fallback({required this.builder})
      : when = null,
        isFallback = true;

  /// Creates the final fallback branch.
  factory FLayoutState.fallback({required FAdaptiveWidgetBuilder builder}) =>
      FLayoutState._fallback(builder: builder);

  /// Condition for this branch, or null for fallback.
  final FLayoutCondition? when;

  /// Builds the selected layout.
  final FAdaptiveWidgetBuilder builder;

  /// Whether this is the fallback branch.
  final bool isFallback;
}

/// Layout metadata available below an [FAdaptiveBuilder].
@immutable
class FLayoutStateData {
  /// Creates resolved layout metadata.
  const FLayoutStateData({required this.size, required this.windowClass});

  /// Available constraints at the adaptive builder.
  final Size size;

  /// Window class derived from [size].
  final FWindowClass windowClass;
}

/// Provides the nearest adaptive layout metadata to descendants.
class FLayoutScope extends InheritedWidget {
  /// Creates a layout scope.
  const FLayoutScope({super.key, required this.data, required super.child});

  /// Resolved metadata.
  final FLayoutStateData data;

  /// Returns the nearest layout metadata, if present.
  static FLayoutStateData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FLayoutScope>()?.data;

  @override
  bool updateShouldNotify(FLayoutScope oldWidget) => data != oldWidget.data;
}

/// Selects the first matching adaptive branch using local constraints.
class FAdaptiveBuilder extends StatelessWidget {
  /// Creates an adaptive builder. Put more demanding conditions before broad
  /// ones; the first matching state is selected.
  FAdaptiveBuilder({
    super.key,
    required this.states,
    this.compactMaxWidth = 600,
    this.mediumMaxWidth = 1200,
  })  : assert(states.isNotEmpty),
        assert(compactMaxWidth >= 0),
        assert(mediumMaxWidth >= compactMaxWidth);

  /// Branches ordered from most specific to least specific.
  final List<FLayoutState> states;

  /// Width below which [FWindowClass.compact] is used.
  final double compactMaxWidth;

  /// Width below which [FWindowClass.medium] is used.
  final double mediumMaxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final windowClass = FWindowClassSizing.fromWidth(
            constraints.maxWidth,
            compactMax: compactMaxWidth,
            mediumMax: mediumMaxWidth,
          );
          FLayoutState? fallback;
          FLayoutState? selected;
          for (final state in states) {
            if (state.isFallback) {
              fallback = state;
            } else if (state.when!.matches(size)) {
              selected = state;
              break;
            }
          }
          selected ??= fallback;
          assert(
            selected != null,
            'FAdaptiveBuilder requires a matching state or FLayoutState.fallback.',
          );
          return FLayoutScope(
            data: FLayoutStateData(size: size, windowClass: windowClass),
            child: Builder(
              builder: (scopedContext) =>
                  selected?.builder(scopedContext) ?? const SizedBox.shrink(),
            ),
          );
        },
      );
}

/// Shows or hides a child based on local constraints.
class FAdaptiveVisibility extends StatelessWidget {
  /// Creates a conditional visibility wrapper.
  const FAdaptiveVisibility({
    super.key,
    required this.when,
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.maintainState = true,
  });

  /// Condition under which [child] is visible.
  final FLayoutCondition when;

  /// The controlled child.
  final Widget child;

  /// Shown when the condition does not match and state is not maintained.
  final Widget replacement;

  /// Whether to keep the hidden child mounted and laid out offstage.
  final bool maintainState;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final visible = when.matches(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
          if (maintainState) return Offstage(offstage: !visible, child: child);
          return visible ? child : replacement;
        },
      );
}
