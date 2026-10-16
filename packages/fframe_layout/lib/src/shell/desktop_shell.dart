import 'package:flutter/widgets.dart';

import '../workspace/workspace.dart';
import '../workspace/workspace_policy.dart';

/// A desktop application shell made from app-provided regions.
class FDesktopShell extends StatelessWidget {
  /// Creates a shell. The core only arranges regions and does not provide
  /// title bar, command, or status visuals.
  const FDesktopShell({
    super.key,
    this.titleBar,
    this.commandArea,
    this.navigation,
    required this.body,
    this.inspector,
    this.statusBar,
    this.workspacePolicy = const FWorkspacePolicy(),
    this.workspaceController,
    this.mainAxisSize = MainAxisSize.max,
  });

  /// Optional title bar region.
  final Widget? titleBar;

  /// Optional command / toolbar region.
  final Widget? commandArea;

  /// Optional navigation pane.
  final FWorkspacePane? navigation;

  /// Main application content.
  final Widget body;

  /// Optional inspector pane.
  final FWorkspacePane? inspector;

  /// Optional status region.
  final Widget? statusBar;

  /// Adaptive workspace sizing policy.
  final FWorkspacePolicy workspacePolicy;

  /// Controller for pane and overlay visibility.
  final FWorkspaceController? workspaceController;

  /// Column sizing behavior.
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final content = navigation == null && inspector == null
        ? body
        : FWorkspace(
            navigation: navigation,
            content: body,
            inspector: inspector,
            policy: workspacePolicy,
            controller: workspaceController,
          );
    return Column(
      mainAxisSize: mainAxisSize,
      children: <Widget>[
        if (titleBar != null) titleBar!,
        if (commandArea != null) commandArea!,
        Expanded(child: content),
        if (statusBar != null) statusBar!,
      ],
    );
  }
}

/// Arranges leading, title, centered, and trailing title bar regions.
class FTitleBarLayout extends StatelessWidget {
  /// Creates a title bar layout.
  const FTitleBarLayout({
    super.key,
    this.leading,
    required this.title,
    this.center,
    this.actions = const <Widget>[],
    this.spacing = 8,
    this.titleFlex = 1,
  })  : assert(spacing >= 0),
        assert(titleFlex > 0);

  /// Leading content, commonly an app icon or navigation toggle.
  final Widget? leading;

  /// Title content.
  final Widget title;

  /// Optional centered content such as a search field.
  final Widget? center;

  /// Trailing actions.
  final List<Widget> actions;

  /// Space between regions.
  final double spacing;

  /// Flex factor for the title region.
  final int titleFlex;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (leading != null) {
      children.addAll(<Widget>[leading!, SizedBox(width: spacing)]);
    }
    children.add(Expanded(flex: titleFlex, child: title));
    if (center != null) {
      children.addAll(<Widget>[SizedBox(width: spacing), center!]);
    }
    for (final action in actions) {
      children.addAll(<Widget>[SizedBox(width: spacing), action]);
    }
    return Row(textDirection: Directionality.of(context), children: children);
  }
}

/// Arranges a status region and optional trailing status content.
class FStatusArea extends StatelessWidget {
  /// Creates a status area.
  const FStatusArea({
    super.key,
    required this.leading,
    this.trailing,
    this.spacing = 8,
  });

  /// Leading status content.
  final Widget leading;

  /// Optional trailing status content.
  final Widget? trailing;

  /// Space between regions.
  final double spacing;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(child: leading),
          if (trailing != null) ...<Widget>[
            SizedBox(width: spacing),
            trailing!
          ],
        ],
      );
}
