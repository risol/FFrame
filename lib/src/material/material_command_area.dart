import 'package:flutter/material.dart';

import '../command/command_area.dart';

/// Material [FCommandArea] that places hidden commands in a popup menu.
class FMaterialCommandArea extends StatelessWidget {
  /// Creates a Material command area.
  const FMaterialCommandArea({
    super.key,
    this.primary = const <FCommandItem>[],
    this.secondary = const <FCommandItem>[],
    this.overflow = const <FCommandItem>[],
    this.spacing = 4,
    this.padding = EdgeInsets.zero,
  });

  /// Primary commands.
  final List<FCommandItem> primary;

  /// Secondary commands.
  final List<FCommandItem> secondary;

  /// Commands always placed in the overflow menu.
  final List<FCommandItem> overflow;

  /// Space between commands.
  final double spacing;

  /// Outer padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => FCommandArea(
        primary: primary,
        secondary: secondary,
        overflow: overflow,
        spacing: spacing,
        padding: padding,
        overflowBuilder: (context, items) => PopupMenuButton<int>(
          tooltip: 'More commands',
          itemBuilder: (context) => <PopupMenuEntry<int>>[
            for (var i = 0; i < items.length; i++)
              PopupMenuItem<int>(value: i, child: items[i].expanded),
          ],
        ),
      );
}
