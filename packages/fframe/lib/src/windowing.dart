import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:fframe_design/fframe_design.dart';

import 'controls.dart';
import 'primitives.dart';

/// Descriptor sent to a platform adapter when an auxiliary window is opened.
class FWindowSpec {
  const FWindowSpec({
    required this.id,
    required this.title,
    required this.route,
    this.arguments,
    this.size = const Size(900, 640),
    this.minimumSize = const Size(480, 320),
  });

  final String id;
  final String title;
  final String route;
  final Object? arguments;
  final FSize size;
  final FSize minimumSize;
}

/// Platform integration required for real native window operations.
///
/// FFrame owns the stable command contract and window chrome. Desktop plugins
/// implement the host-specific parts, since Flutter's core widget runtime does
/// not create secondary OS windows by itself.
abstract interface class FWindowAdapter {
  Future<bool> openWindow(FWindowSpec spec);
  Future<void> closeWindow(String id);
  Future<void> closeCurrentWindow();
  Future<void> minimizeCurrentWindow();
  Future<void> toggleMaximizeCurrentWindow();
  Future<void> beginWindowDrag();
}

/// App-scoped facade for auxiliary windows and native title-bar commands.
class FWindowManager {
  FWindowManager(this.adapter);

  final FWindowAdapter adapter;

  Future<bool> open(FWindowSpec spec) => adapter.openWindow(spec);
  Future<void> close(String id) => adapter.closeWindow(id);
  Future<void> closeCurrent() => adapter.closeCurrentWindow();
  Future<void> minimizeCurrent() => adapter.minimizeCurrentWindow();
  Future<void> toggleMaximizeCurrent() => adapter.toggleMaximizeCurrentWindow();
  Future<void> beginDrag() => adapter.beginWindowDrag();

  static FWindowManager? maybeOf(FBuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FWindowScope>()?.manager;

  static FWindowManager of(FBuildContext context) {
    final manager = maybeOf(context);
    assert(manager != null, 'No FWindowManager was supplied to FFrameApp.');
    return manager!;
  }
}

class FWindowScope extends InheritedWidget {
  const FWindowScope({super.key, required this.manager, required super.child});

  final FWindowManager? manager;

  @override
  bool updateShouldNotify(FWindowScope oldWidget) =>
      manager != oldWidget.manager;
}

typedef FWindowAction = FutureOr<void> Function();

/// FFrame title bar with optional native minimize, maximize, and close actions.
class FWindowTitleBar extends StatelessWidget {
  const FWindowTitleBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const <FWidget>[],
    this.showWindowControls = true,
    this.onMinimize,
    this.onToggleMaximize,
    this.onClose,
    this.height,
  });

  final String title;
  final FWidget? leading;
  final List<FWidget> actions;
  final bool showWindowControls;
  final FWindowAction? onMinimize;
  final FWindowAction? onToggleMaximize;
  final FWindowAction? onClose;
  final double? height;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final manager = FWindowManager.maybeOf(context);
    Future<void> invoke(FWindowAction? action, FWindowAction? fallback) async {
      final callback = action ?? fallback;
      if (callback != null) await callback();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart:
          manager == null ? null : (_) => unawaited(manager.beginDrag()),
      child: Container(
        height: height ?? theme.effectiveDensity.toolbarHeight,
        padding: const EdgeInsetsDirectional.only(start: 10, end: 6),
        decoration: BoxDecoration(
          color: theme.tokens.colors.surfaceSubtle,
          border: Border(
            bottom: BorderSide(color: theme.tokens.colors.border, width: 1),
          ),
        ),
        child: Row(
          children: <FWidget>[
            if (leading != null) ...<FWidget>[
              leading!,
              const SizedBox(width: 8)
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.tokens.typography.windowTitle
                    .copyWith(color: theme.tokens.colors.textPrimary),
              ),
            ),
            ...actions,
            if (showWindowControls &&
                (manager != null ||
                    onMinimize != null ||
                    onToggleMaximize != null ||
                    onClose != null)) ...<FWidget>[
              FIconButton(
                icon: const FIcon(FIcons.remove, size: 16),
                tooltip: 'Minimize window',
                onPressed: manager == null && onMinimize == null
                    ? null
                    : () => unawaited(invoke(
                          onMinimize,
                          manager?.minimizeCurrent,
                        )),
                size: FControlSize.compact,
              ),
              FIconButton(
                icon: const FIcon(FIcons.openInFull, size: 16),
                tooltip: 'Maximize or restore window',
                onPressed: manager == null && onToggleMaximize == null
                    ? null
                    : () => unawaited(invoke(
                          onToggleMaximize,
                          manager?.toggleMaximizeCurrent,
                        )),
                size: FControlSize.compact,
              ),
              FIconButton(
                icon: const FIcon(FIcons.close, size: 16),
                tooltip: 'Close window',
                onPressed: manager == null && onClose == null
                    ? null
                    : () => unawaited(
                          invoke(onClose, manager?.closeCurrent),
                        ),
                size: FControlSize.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Window-like app frame that keeps its title bar and content in FFrame.
class FWindowFrame extends StatelessWidget {
  const FWindowFrame({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.actions = const <FWidget>[],
    this.showWindowControls = true,
  });

  final String title;
  final FWidget child;
  final FWidget? leading;
  final List<FWidget> actions;
  final bool showWindowControls;

  @override
  FWidget build(FBuildContext context) => Column(
        children: <FWidget>[
          FWindowTitleBar(
            title: title,
            leading: leading,
            actions: actions,
            showWindowControls: showWindowControls,
          ),
          Expanded(child: child),
        ],
      );
}

/// Stack host for movable floating panels.
class FFloatingDock extends StatelessWidget {
  const FFloatingDock({
    super.key,
    required this.child,
    this.panels = const <FFloatingPanel>[],
  });

  final FWidget child;
  final List<FFloatingPanel> panels;

  @override
  FWidget build(FBuildContext context) => Stack(
        fit: StackFit.expand,
        children: <FWidget>[child, ...panels],
      );
}

/// Draggable floating dock panel. Place it under [FFloatingDock].
class FFloatingPanel extends StatefulWidget {
  const FFloatingPanel({
    super.key,
    required this.id,
    required this.title,
    required this.child,
    this.initialPosition = const Offset(48, 48),
    this.width = 360,
    this.height = 280,
    this.onClose,
    this.onDock,
  }) : assert(width > 0 && height > 0);

  final String id;
  final String title;
  final FWidget child;
  final FOffset initialPosition;
  final double width;
  final double height;
  final FVoidCallback? onClose;
  final FVoidCallback? onDock;

  @override
  State<FFloatingPanel> createState() => _FFloatingPanelState();
}

class _FFloatingPanelState extends State<FFloatingPanel> {
  late FOffset _position = widget.initialPosition;

  @override
  void didUpdateWidget(FFloatingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPosition != widget.initialPosition) {
      _position = widget.initialPosition;
    }
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      width: widget.width,
      height: widget.height,
      child: FPanel(
        raised: true,
        padding: EdgeInsets.zero,
        child: Column(
          children: <FWidget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) =>
                  setState(() => _position += details.delta),
              child: Container(
                height: theme.effectiveDensity.toolbarHeight,
                padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
                decoration: BoxDecoration(
                  color: theme.tokens.colors.surfaceSubtle,
                  border: Border(
                    bottom: BorderSide(color: theme.tokens.colors.border),
                  ),
                ),
                child: Row(
                  children: <FWidget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.tokens.typography.windowTitle,
                      ),
                    ),
                    if (widget.onDock != null)
                      FIconButton(
                        icon: const FIcon(FIcons.openInFull, size: 14),
                        tooltip: 'Dock panel',
                        onPressed: widget.onDock,
                        size: FControlSize.compact,
                      ),
                    FIconButton(
                      icon: const FIcon(FIcons.close, size: 14),
                      tooltip: 'Close panel',
                      onPressed: widget.onClose,
                      size: FControlSize.compact,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
