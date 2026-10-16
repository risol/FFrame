import 'package:flutter/widgets.dart';

import '../pane/pane.dart';
import '../pane/pane_controller.dart';
import '../pane/split_view.dart';
import 'workspace_policy.dart';

/// Contents and behavior for a workspace side pane.
@immutable
class FWorkspacePane {
  /// Creates a workspace pane.
  const FWorkspacePane({
    required this.child,
    this.compactChild,
    this.collapseBehavior = FPaneCollapseBehavior.remove,
    this.preferredSize,
    this.minSize,
    this.maxSize,
    this.collapsible,
    this.collapsePriority,
  });

  /// Main contents.
  final Widget child;

  /// Compact alternative, commonly an icon rail.
  final Widget? compactChild;

  /// Behavior when this pane cannot fit in the workspace.
  final FPaneCollapseBehavior collapseBehavior;

  /// Optional preferred size override.
  final double? preferredSize;

  /// Optional minimum size override.
  final double? minSize;

  /// Optional maximum size override.
  final double? maxSize;

  /// Optional collapse support override.
  final bool? collapsible;

  /// Optional collapse priority override.
  final int? collapsePriority;
}

/// Controls visibility of workspace panes that use overlay behavior.
class FWorkspaceController extends ChangeNotifier {
  /// Creates a workspace controller.
  FWorkspaceController({FPaneController? paneController})
      : panes = paneController ?? FPaneController(),
        _ownsPaneController = paneController == null;

  /// Pane sizing controller shared by workspace splitters.
  final FPaneController panes;
  final bool _ownsPaneController;

  bool _navigationVisible = false;
  bool _inspectorVisible = false;

  /// Whether an overlay navigation pane is currently open.
  bool get navigationVisible => _navigationVisible;

  /// Whether an overlay inspector pane is currently open.
  bool get inspectorVisible => _inspectorVisible;

  /// Opens or closes the navigation overlay.
  void setNavigationVisible(bool visible) {
    if (_navigationVisible == visible) return;
    _navigationVisible = visible;
    notifyListeners();
  }

  /// Opens or closes the inspector overlay.
  void setInspectorVisible(bool visible) {
    if (_inspectorVisible == visible) return;
    _inspectorVisible = visible;
    notifyListeners();
  }

  /// Toggles the navigation overlay.
  void toggleNavigation() => setNavigationVisible(!_navigationVisible);

  /// Toggles the inspector overlay.
  void toggleInspector() => setInspectorVisible(!_inspectorVisible);

  @override
  void dispose() {
    if (_ownsPaneController) panes.dispose();
    super.dispose();
  }
}

/// Adaptive navigation/content/inspector application workspace.
class FWorkspace extends StatefulWidget {
  /// Creates a workspace. Pane selection is based on the minimum content
  /// requirements and available constraints, not the device platform.
  const FWorkspace({
    super.key,
    this.navigation,
    required this.content,
    this.inspector,
    this.policy = const FWorkspacePolicy(),
    this.controller,
    this.splitterBuilder,
    this.animate = false,
  });

  /// Optional navigation pane.
  final FWorkspacePane? navigation;

  /// Main workspace content.
  final Widget content;

  /// Optional inspector pane.
  final FWorkspacePane? inspector;

  /// Sizing and collapse policy.
  final FWorkspacePolicy policy;

  /// Optional external workspace state controller.
  final FWorkspaceController? controller;

  /// Optional custom splitter visuals.
  final FSplitterBuilder? splitterBuilder;

  /// Whether split size changes animate.
  final bool animate;

  @override
  State<FWorkspace> createState() => _FWorkspaceState();
}

class _FWorkspaceState extends State<FWorkspace> {
  late FWorkspaceController _ownedController;
  FWorkspaceController get _controller => widget.controller ?? _ownedController;

  @override
  void initState() {
    super.initState();
    _ownedController = FWorkspaceController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(FWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController).removeListener(
        _handleControllerChanged,
      );
      _controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _ownedController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final policy = widget.policy;
          final nav = widget.navigation;
          final inspector = widget.inspector;
          final gap = policy.splitterThickness;
          final splitterExtent = policy.splitterHitTestExtent;
          final contentMin = policy.content.minSize;
          final navPreferred =
              nav?.preferredSize ?? policy.navigation.preferredSize;
          final navMin = nav?.minSize ?? policy.navigation.minSize;
          final inspectorPreferred =
              inspector?.preferredSize ?? policy.inspector.preferredSize;
          final inspectorMin = inspector?.minSize ?? policy.inspector.minSize;

          final canShowInspector = inspector != null &&
              width.isFinite &&
              width >=
                  (nav == null ? 0 : navMin + splitterExtent) +
                      contentMin +
                      inspectorMin +
                      splitterExtent;
          final canShowExpandedNavigation = nav != null &&
              width.isFinite &&
              width >= navMin + contentMin + splitterExtent;
          final compactNavigation = nav != null &&
              !canShowExpandedNavigation &&
              nav.compactChild != null &&
              width.isFinite &&
              width >=
                  policy.navigation.compactSize + contentMin + splitterExtent;

          Widget base;
          if (canShowInspector) {
            base = FSplitView(
              direction: Axis.horizontal,
              controller: _controller.panes,
              splitterThickness: gap,
              splitterHitTestExtent: splitterExtent,
              splitterBuilder: widget.splitterBuilder,
              animate: widget.animate,
              children: <FPane>[
                if (nav != null)
                  FPane(
                    id: 'workspace.navigation',
                    preferredSize: nav.preferredSize ?? navPreferred,
                    minSize: nav.minSize ?? navMin,
                    maxSize: nav.maxSize ?? policy.navigation.maxSize,
                    collapsible:
                        nav.collapsible ?? policy.navigation.collapsible,
                    collapsePriority: nav.collapsePriority ??
                        policy.navigation.collapsePriority,
                    child: nav.child,
                  ),
                FPane.flex(
                  id: 'workspace.content',
                  minSize: contentMin,
                  child: widget.content,
                ),
                FPane(
                  id: 'workspace.inspector',
                  preferredSize: inspector.preferredSize ?? inspectorPreferred,
                  minSize: inspector.minSize ?? inspectorMin,
                  maxSize: inspector.maxSize ?? policy.inspector.maxSize,
                  collapsible:
                      inspector.collapsible ?? policy.inspector.collapsible,
                  collapsePriority: inspector.collapsePriority ??
                      policy.inspector.collapsePriority,
                  child: inspector.child,
                ),
              ],
            );
          } else if (nav != null && canShowExpandedNavigation) {
            base = FSplitView.horizontal(
              controller: _controller.panes,
              splitterThickness: gap,
              splitterHitTestExtent: splitterExtent,
              splitterBuilder: widget.splitterBuilder,
              animate: widget.animate,
              children: <FPane>[
                FPane(
                  id: 'workspace.navigation',
                  preferredSize: nav.preferredSize ?? navPreferred,
                  minSize: nav.minSize ?? navMin,
                  maxSize: nav.maxSize ?? policy.navigation.maxSize,
                  collapsible: nav.collapsible ?? policy.navigation.collapsible,
                  collapsePriority: nav.collapsePriority ??
                      policy.navigation.collapsePriority,
                  child: nav.child,
                ),
                FPane.flex(
                  id: 'workspace.content',
                  minSize: contentMin,
                  child: widget.content,
                ),
              ],
            );
          } else if (compactNavigation) {
            base = FSplitView.horizontal(
              splitterThickness: gap,
              splitterHitTestExtent: splitterExtent,
              children: <FPane>[
                FPane(
                  id: 'workspace.navigation.compact',
                  preferredSize: policy.navigation.compactSize,
                  minSize: policy.navigation.compactSize,
                  maxSize: policy.navigation.compactSize,
                  child: nav.compactChild!,
                ),
                FPane.flex(
                  id: 'workspace.content',
                  minSize: contentMin,
                  child: widget.content,
                ),
              ],
            );
          } else {
            base = SizedBox(
              width: width.isFinite ? width : null,
              height:
                  constraints.maxHeight.isFinite ? constraints.maxHeight : null,
              child: widget.content,
            );
          }

          final showNavigationOverlay = nav != null &&
              nav.collapseBehavior == FPaneCollapseBehavior.overlay &&
              width.isFinite &&
              !canShowExpandedNavigation &&
              !compactNavigation &&
              _controller.navigationVisible;
          final showInspectorOverlay = inspector != null &&
              inspector.collapseBehavior == FPaneCollapseBehavior.overlay &&
              width.isFinite &&
              !canShowInspector &&
              _controller.inspectorVisible;
          if (!showNavigationOverlay && !showInspectorOverlay) return base;
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              base,
              if (showNavigationOverlay)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: nav.preferredSize ?? navPreferred,
                  child: nav.child,
                ),
              if (showInspectorOverlay)
                PositionedDirectional(
                  end: 0,
                  top: 0,
                  bottom: 0,
                  width: inspector.preferredSize ?? inspectorPreferred,
                  child: inspector.child,
                ),
            ],
          );
        },
      );
}
