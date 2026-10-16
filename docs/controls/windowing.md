# Windowing and floating panels

## Window frame and title bar

`FWindowFrame` composes an FFrame title bar with app content. `FWindowTitleBar` uses FFrame icon buttons and can call an optional `FWindowManager` for drag, minimize, maximize, and close commands. Supply `showWindowControls: false` for in-window title bars that should not expose OS controls.

## Native and multiple windows

`FWindowManager` is the stable core command facade. It delegates `FWindowSpec` requests to an `FWindowAdapter` supplied to `FFrameApp`. The optional `fframe_window` package implements it for Windows, macOS, and Linux with `desktop_multi_window` and `window_manager`; core `fframe` keeps no native window plugin dependency.

Install `fframe_window` in a desktop application and boot its root app through the adapter:

```dart
Future<void> main() async {
  if (FDesktopWindowBootstrap.isSupportedPlatform) {
    await FDesktopWindowBootstrap.run(
      mainWindow: const FWindowSpec(
        id: 'main',
        title: 'Database Studio',
        route: '/',
      ),
      appBuilder: (manager, currentWindow) => MyFFrameApp(
        windowManager: manager,
        currentWindow: currentWindow,
      ),
    );
  } else {
    runFFrameApp(const MyFFrameApp());
  }
}
```

The child window runs the same entry point and receives its `FWindowSpec` as a payload. Native runners must register generated plugins for child engines so `window_manager` works in every window. `fframe_window` documents the exact callback for Windows, macOS, and Linux in its package README. The package exports a web-safe stub so the same app can keep a browser entry point.

```dart
FFrameApp(
  designSystem: FWpfDesignSystem.light(),
  windowManager: FWindowManager(platformWindowAdapter),
  home: const MainWindow(),
)
```

Open a child window using a stable ID, route name, arguments, and requested size:

```dart
await FWindowManager.of(context).open(
  const FWindowSpec(
    id: 'inspector',
    title: 'Inspector',
    route: '/inspector',
    size: FSize(560, 720),
  ),
);
```

Adapters should make repeated opens for an already-open ID idempotent, preserve the route payload, and report whether the platform accepted the request. Window lifetime and business state remain app-owned.

## Floating dock panels

`FFloatingDock` hosts a content surface and `FFloatingPanel` children. Panels can be dragged by their title bar and can expose close and dock callbacks. They are an in-app overlay; persisting dock state and moving a panel into a native window are application/platform responsibilities.

```dart
FFloatingDock(
  child: editor,
  panels: <FFloatingPanel>[
    FFloatingPanel(
      id: 'inspector',
      title: 'Inspector',
      initialPosition: const FOffset(700, 80),
      child: inspector,
      onClose: closeInspector,
      onDock: dockInspector,
    ),
  ],
)
```
