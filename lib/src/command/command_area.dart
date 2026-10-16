import 'package:flutter/widgets.dart';

/// One command that can expose a compact representation under width pressure.
@immutable
class FCommandItem {
  /// Creates a responsive command item.
  const FCommandItem({
    required this.expanded,
    this.compact,
    this.priority = 0,
    this.preferredWidth = 120,
    this.compactWidth = 40,
  })  : assert(priority >= 0),
        assert(preferredWidth >= 0 && preferredWidth < double.infinity),
        assert(compactWidth >= 0 && compactWidth < double.infinity),
        assert(compact == null || compactWidth <= preferredWidth);

  /// Full command representation.
  final Widget expanded;

  /// Compact command representation, typically an icon button.
  final Widget? compact;

  /// Higher priority commands remain visible longer when space is limited.
  final int priority;

  /// Estimated width of the expanded representation.
  final double preferredWidth;

  /// Estimated width of the compact representation.
  final double compactWidth;
}

/// Builds overflow UI for commands that do not fit.
typedef FCommandOverflowBuilder = Widget Function(
  BuildContext context,
  List<FCommandItem> hiddenItems,
);

/// Lays out command items and chooses compact representations as width falls.
class FCommandArea extends StatelessWidget {
  /// Creates a command area.
  const FCommandArea({
    super.key,
    this.primary = const <FCommandItem>[],
    this.secondary = const <FCommandItem>[],
    this.overflow = const <FCommandItem>[],
    this.overflowBuilder,
    this.spacing = 4,
    this.runSpacing = 4,
    this.alignment = MainAxisAlignment.start,
    this.padding = EdgeInsets.zero,
    this.overflowButtonWidth = 40,
  })  : assert(spacing >= 0),
        assert(runSpacing >= 0),
        assert(overflowButtonWidth >= 0);

  /// Primary commands.
  final List<FCommandItem> primary;

  /// Secondary commands, hidden before primary commands.
  final List<FCommandItem> secondary;

  /// Commands always presented in the overflow builder.
  final List<FCommandItem> overflow;

  /// Optional UI-library-specific overflow menu builder.
  final FCommandOverflowBuilder? overflowBuilder;

  /// Horizontal space between commands.
  final double spacing;

  /// Vertical space between wrapped commands.
  final double runSpacing;

  /// Horizontal alignment.
  final MainAxisAlignment alignment;

  /// Outer padding.
  final EdgeInsetsGeometry padding;

  /// Estimated width of the overflow affordance when an adapter displays one.
  final double overflowButtonWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final resolvedPadding = padding.resolve(Directionality.of(context));
          final width = (constraints.maxWidth - resolvedPadding.horizontal)
              .clamp(0, double.infinity);
          final ordered = <FCommandItem>[...primary, ...secondary];
          final compact = <FCommandItem>{};
          final hidden = <FCommandItem>{...overflow};
          final degradable = <({FCommandItem item, bool secondary, int index})>[
            for (var i = 0; i < secondary.length; i++)
              (item: secondary[i], secondary: true, index: i),
            for (var i = 0; i < primary.length; i++)
              (item: primary[i], secondary: false, index: i),
          ]..sort((a, b) {
              final byPriority = a.item.priority.compareTo(b.item.priority);
              if (byPriority != 0) return byPriority;
              if (a.secondary != b.secondary) return a.secondary ? -1 : 1;
              return b.index.compareTo(a.index);
            });

          double requiredWidth() {
            final visibleItems =
                ordered.where((item) => !hidden.contains(item)).toList();
            var result = visibleItems.fold<double>(
                0,
                (sum, item) =>
                    sum +
                    (compact.contains(item)
                        ? item.compactWidth
                        : item.preferredWidth));
            if (visibleItems.length > 1) {
              result += spacing * (visibleItems.length - 1);
            }
            if (overflowBuilder != null && hidden.isNotEmpty) {
              result += overflowButtonWidth;
              if (visibleItems.isNotEmpty) {
                result += spacing;
              }
            }
            return result;
          }

          if (overflowBuilder != null) {
            for (final candidate in degradable) {
              if (requiredWidth() <= width) break;
              final item = candidate.item;
              if (item.compact != null && !compact.contains(item)) {
                compact.add(item);
              } else {
                hidden.add(item);
              }
            }
          } else {
            for (final candidate in degradable) {
              if (requiredWidth() <= width) break;
              if (candidate.item.compact != null) compact.add(candidate.item);
            }
          }

          final visible =
              ordered.where((item) => !hidden.contains(item)).toList();
          final children = <Widget>[
            for (final item in visible)
              item.compact != null && compact.contains(item)
                  ? item.compact!
                  : item.expanded,
          ];
          if (hidden.isNotEmpty && overflowBuilder != null) {
            children.add(overflowBuilder!(
              context,
              <FCommandItem>[
                ...overflow,
                ...ordered.where(hidden.contains),
              ],
            ));
          } else if (hidden.isNotEmpty) {
            // Without an adapter-provided menu, keep commands reachable by
            // wrapping them onto another line.
            children
                .addAll(hidden.map((item) => item.compact ?? item.expanded));
          }
          return Padding(
            padding: padding,
            child: Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              alignment: _wrapAlignment(alignment),
              children: children,
            ),
          );
        },
      );

  WrapAlignment _wrapAlignment(MainAxisAlignment value) => switch (value) {
        MainAxisAlignment.start => WrapAlignment.start,
        MainAxisAlignment.end => WrapAlignment.end,
        MainAxisAlignment.center => WrapAlignment.center,
        MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
        MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
        MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
      };
}
