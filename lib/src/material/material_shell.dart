import 'package:flutter/material.dart';

/// A destination shown by [FMaterialShell].
@immutable
class FMaterialDestination {
  /// Creates a Material navigation destination.
  const FMaterialDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.tooltip,
  });

  /// Unselected icon.
  final Widget icon;

  /// Selected icon, if different from [icon].
  final Widget? selectedIcon;

  /// Visible destination label.
  final String label;

  /// Optional compact-navigation tooltip.
  final String? tooltip;
}

/// Material navigation shell that adapts between NavigationBar and
/// NavigationRail based on its local width.
class FMaterialShell extends StatelessWidget {
  /// Creates a Material shell. Use inside a [MaterialApp].
  const FMaterialShell({
    super.key,
    required this.destinations,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extendedBreakpoint = 1200,
    this.bottomBreakpoint = 600,
    this.drawerBreakpoint = 420,
    this.backgroundColor,
    this.navigationBarLabelBehavior = NavigationRailLabelType.all,
    this.scaffoldKey,
  })  : assert(destinations.length > 0),
        assert(selectedIndex >= 0),
        assert(extendedBreakpoint >= bottomBreakpoint),
        assert(drawerBreakpoint >= 0 && drawerBreakpoint <= bottomBreakpoint);

  /// Navigation destinations.
  final List<FMaterialDestination> destinations;

  /// Current destination body.
  final Widget body;

  /// Selected destination index.
  final int selectedIndex;

  /// Destination selection callback.
  final ValueChanged<int> onDestinationSelected;

  /// Width at which labels are shown with an extended rail.
  final double extendedBreakpoint;

  /// Width below which a bottom navigation bar is used.
  final double bottomBreakpoint;

  /// Width below which an app-supplied or generated drawer is used.
  final double drawerBreakpoint;

  /// Optional scaffold background.
  final Color? backgroundColor;

  /// Label mode for the compact rail.
  final NavigationRailLabelType navigationBarLabelBehavior;

  /// Optional key for app-owned drawer triggers in the body.
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          assert(selectedIndex < destinations.length);
          if (constraints.maxWidth < drawerBreakpoint) {
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: backgroundColor,
              drawer: Builder(
                builder: (drawerContext) => NavigationDrawer(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    onDestinationSelected(index);
                    Scaffold.of(drawerContext).closeDrawer();
                  },
                  children: <Widget>[
                    for (final destination in destinations)
                      NavigationDrawerDestination(
                        icon: destination.icon,
                        label: Text(destination.label),
                      ),
                  ],
                ),
              ),
              body: body,
            );
          }
          if (constraints.maxWidth < bottomBreakpoint) {
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: backgroundColor,
              body: body,
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: <NavigationDestination>[
                  for (final destination in destinations)
                    NavigationDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: destination.label,
                      tooltip: destination.tooltip,
                    ),
                ],
              ),
            );
          }
          final extended = constraints.maxWidth >= extendedBreakpoint;
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: backgroundColor,
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  extended: extended,
                  labelType: extended ? null : navigationBarLabelBehavior,
                  destinations: <NavigationRailDestination>[
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Tooltip(
                          message: destination.tooltip ?? destination.label,
                          child: destination.icon,
                        ),
                        selectedIcon: Tooltip(
                          message: destination.tooltip ?? destination.label,
                          child: destination.selectedIcon ?? destination.icon,
                        ),
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        },
      );
}
