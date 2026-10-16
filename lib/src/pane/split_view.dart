import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'pane.dart';
import 'pane_controller.dart';
import 'splitter.dart';

/// Builds a splitter between two panes.
typedef FSplitterBuilder = Widget Function(
  BuildContext context,
  int index,
  Axis direction,
  ValueChanged<double> onResize,
  VoidCallback onReset,
  VoidCallback onEnd,
);

/// A resizable row or column of [FPane]s.
class FSplitView extends StatefulWidget {
  /// Creates a split view.
  const FSplitView({
    super.key,
    required this.direction,
    required this.children,
    this.controller,
    this.splitterThickness = 6,
    this.splitterHitTestExtent = 10,
    this.splitterBuilder,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 180),
  })  : assert(children.length > 0),
        assert(splitterThickness > 0),
        assert(splitterHitTestExtent >= splitterThickness);

  /// Creates a left-to-right split view (or right-to-left under RTL).
  const FSplitView.horizontal({
    super.key,
    required this.children,
    this.controller,
    this.splitterThickness = 6,
    this.splitterHitTestExtent = 10,
    this.splitterBuilder,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 180),
  })  : direction = Axis.horizontal,
        assert(children.length > 0),
        assert(splitterThickness > 0),
        assert(splitterHitTestExtent >= splitterThickness);

  /// Creates a top-to-bottom split view.
  const FSplitView.vertical({
    super.key,
    required this.children,
    this.controller,
    this.splitterThickness = 6,
    this.splitterHitTestExtent = 10,
    this.splitterBuilder,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 180),
  })  : direction = Axis.vertical,
        assert(children.length > 0),
        assert(splitterThickness > 0),
        assert(splitterHitTestExtent >= splitterThickness);

  /// Main axis along which panes are placed.
  final Axis direction;

  /// Panes to arrange; each child must be an [FPane].
  final List<FPane> children;

  /// Optional externally owned pane state controller.
  final FPaneController? controller;

  /// Visible splitter thickness.
  final double splitterThickness;

  /// Pointer target thickness for each splitter.
  final double splitterHitTestExtent;

  /// Optional visual override for splitter widgets.
  final FSplitterBuilder? splitterBuilder;

  /// Whether size changes animate. Disabled by default to keep pointer resize
  /// direct and stable.
  final bool animate;

  /// Animation duration when [animate] is enabled.
  final Duration animationDuration;

  @override
  State<FSplitView> createState() => _FSplitViewState();
}

class _FSplitViewState extends State<FSplitView> {
  late FPaneController _ownedController;
  FPaneController get _controller => widget.controller ?? _ownedController;

  @override
  void initState() {
    super.initState();
    _ownedController = FPaneController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(FSplitView oldWidget) {
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

  List<_PaneSpec> _paneSpecs() {
    final ids = <String>{};
    return List<_PaneSpec>.generate(widget.children.length, (index) {
      final pane = widget.children[index];
      final id = pane.id ?? 'pane-$index';
      assert(ids.add(id), 'FSplitView pane ids must be unique: "$id".');
      final initial = pane.preferredSize ?? pane.minSize;
      _controller.configurePane(
        id: id,
        initialSize: initial,
        minSize: pane.minSize,
        maxSize: pane.maxSize,
        collapsible: pane.collapsible,
      );
      return _PaneSpec(id: id, pane: pane);
    });
  }

  @override
  Widget build(BuildContext context) {
    final panes = _paneSpecs();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = widget.direction == Axis.horizontal;
        final available =
            isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        if (!available.isFinite) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('FSplitView needs a bounded main axis.'),
            ErrorDescription(
              'The ${isHorizontal ? 'width' : 'height'} constraint is unbounded, '
              'so flex panes have no finite space to divide.',
            ),
            ErrorHint(
              'Place FSplitView under a bounded parent or give it an explicit '
              'size in its main axis.',
            ),
          ]);
        }
        final splitterSpace =
            math.max(0, panes.length - 1) * widget.splitterHitTestExtent;
        final paneSpace = math.max(0.0, available - splitterSpace);
        final sizes = _resolveSizes(panes, paneSpace);
        final axisDirection = isHorizontal ? Axis.horizontal : Axis.vertical;
        final children = <Widget>[];
        for (var i = 0; i < panes.length; i++) {
          final pane = panes[i];
          final state = _controller.stateFor(pane.id)!;
          final collapsed = state.collapsed;
          final paneSize = collapsed ? pane.pane.collapsedSize : sizes[i];
          final paneWidget = widget.animate
              ? AnimatedContainer(
                  duration: widget.animationDuration,
                  width: isHorizontal ? paneSize : null,
                  height: isHorizontal ? null : paneSize,
                  child: pane.pane.child,
                )
              : SizedBox(
                  width: isHorizontal ? paneSize : null,
                  height: isHorizontal ? null : paneSize,
                  child: pane.pane.child,
                );
          children.add(ClipRect(child: paneWidget));
          if (i < panes.length - 1) {
            final splitterIndex = i;
            final nextPaneId = panes[i + 1].id;
            void onResize(double delta) =>
                _resizeAdjacent(panes, sizes, splitterIndex, delta);
            void onReset() {
              _controller.reset(pane.id);
              _controller.reset(nextPaneId);
            }

            void onEnd() {
              final maxSize = pane.pane.maxSize.isFinite
                  ? pane.pane.maxSize
                  : math.max(pane.pane.minSize, paneSpace);
              _controller.setSize(pane.id, maxSize);
            }

            children.add(
              widget.splitterBuilder?.call(
                    context,
                    i,
                    axisDirection,
                    onResize,
                    onReset,
                    onEnd,
                  ) ??
                  FSplitter(
                    direction: axisDirection,
                    thickness: widget.splitterThickness,
                    hitTestExtent: widget.splitterHitTestExtent,
                    value: sizes[i],
                    min: pane.pane.minSize,
                    max: pane.pane.maxSize,
                    onResize: onResize,
                    onReset: onReset,
                    onEnd: onEnd,
                    onToggleCollapse: () => _controller.toggle(nextPaneId),
                  ),
            );
          }
        }
        return Flex(
          direction: axisDirection,
          textDirection: isHorizontal ? Directionality.of(context) : null,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }

  List<double> _resolveSizes(List<_PaneSpec> panes, double available) {
    final states = panes.map((item) => _controller.stateFor(item.id)!).toList();
    final active = <int>[];
    final sizes = List<double>.generate(panes.length, (index) {
      final pane = panes[index].pane;
      if (states[index].collapsed) return 0;
      active.add(index);
      final configured =
          states[index].size.clamp(pane.minSize, pane.maxSize).toDouble();
      return pane.isFlexible && !states[index].userSized
          ? pane.minSize
          : configured;
    });
    var required = active.fold<double>(0, (sum, index) => sum + sizes[index]);
    final automaticallyCollapsed = <int>{};

    // Reduce remembered preferred/user sizes toward their minimum before
    // hiding panes. This preserves all panes whenever their minimums fit.
    if (required > available) {
      final shrinkOrder = List<int>.of(active)
        ..sort(
          (a, b) => panes[a].pane.collapsePriority.compareTo(
                panes[b].pane.collapsePriority,
              ),
        );
      var excess = required - available;
      for (final index in shrinkOrder) {
        if (excess <= 0) break;
        final minimum = panes[index].pane.minSize;
        final reducible = math.max(0.0, sizes[index] - minimum);
        final reduction = math.min(excess, reducible);
        sizes[index] -= reduction;
        excess -= reduction;
      }
      required = sizes.fold<double>(0, (sum, value) => sum + value);
    }

    // If minimum requirements still do not fit, collapse the lowest priority
    // panes. Collapse is temporary and reverses automatically on resize.
    final candidates =
        active.where((index) => panes[index].pane.collapsible).toList()
          ..sort(
            (a, b) => panes[a].pane.collapsePriority.compareTo(
                  panes[b].pane.collapsePriority,
                ),
          );
    for (final index in candidates) {
      if (required <= available) break;
      required -= sizes[index];
      sizes[index] = panes[index].pane.collapsedSize;
      automaticallyCollapsed.add(index);
    }
    required = sizes.fold<double>(0, (sum, value) => sum + value);

    if (required > available && required > 0) {
      final scale = available / required;
      for (final index in active) {
        sizes[index] *= scale;
      }
      required = available;
    }
    var remaining = math.max(0.0, available - required);
    var flexible = active
        .where(
          (index) =>
              panes[index].pane.isFlexible &&
              !automaticallyCollapsed.contains(index),
        )
        .toList();
    while (flexible.isNotEmpty && remaining > 0.01) {
      final totalWeight = flexible.fold<double>(
        0,
        (sum, index) => sum + panes[index].pane.flex,
      );
      var allocated = 0.0;
      final capped = <int>[];
      for (final index in flexible) {
        final pane = panes[index].pane;
        final addition = remaining * pane.flex / totalWeight;
        final room = math.max(0.0, pane.maxSize - sizes[index]);
        final applied = math.min(addition, room);
        sizes[index] += applied;
        allocated += applied;
        if (applied + .01 < addition) capped.add(index);
      }
      remaining -= allocated;
      if (capped.isEmpty || allocated <= .01) break;
      flexible = flexible.where((index) => !capped.contains(index)).toList();
    }
    return sizes;
  }

  void _resizeAdjacent(
    List<_PaneSpec> panes,
    List<double> sizes,
    int index,
    double delta,
  ) {
    final first = panes[index];
    final second = panes[index + 1];
    final firstState = _controller.stateFor(first.id)!;
    final secondState = _controller.stateFor(second.id)!;
    if (firstState.collapsed || secondState.collapsed) return;
    final firstFlexible = first.pane.isFlexible && !firstState.userSized;
    final secondFlexible = second.pane.isFlexible && !secondState.userSized;
    final firstSize = firstState.userSized ? firstState.size : sizes[index];
    final secondSize =
        secondState.userSized ? secondState.size : sizes[index + 1];
    if (firstFlexible && !secondFlexible) {
      final next = (secondSize - delta)
          .clamp(second.pane.minSize, second.pane.maxSize)
          .toDouble();
      _controller.setSize(second.id, next);
      return;
    }
    if (secondFlexible && !firstFlexible) {
      final next = (firstSize + delta)
          .clamp(first.pane.minSize, first.pane.maxSize)
          .toDouble();
      _controller.setSize(first.id, next);
      return;
    }
    final nextFirstSize = (firstSize + delta)
        .clamp(first.pane.minSize, first.pane.maxSize)
        .toDouble();
    final applied = nextFirstSize - firstSize;
    final nextSecondSize = (secondSize - applied)
        .clamp(second.pane.minSize, second.pane.maxSize)
        .toDouble();
    final actual = secondSize - nextSecondSize;
    _controller.setSize(first.id, firstSize + actual);
    _controller.setSize(second.id, nextSecondSize);
  }
}

class _PaneSpec {
  const _PaneSpec({required this.id, required this.pane});
  final String id;
  final FPane pane;
}
