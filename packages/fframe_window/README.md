# fframe_window

Optional Windows, macOS, and Linux native-window adapter for `FWindowManager`. It uses `desktop_multi_window` for additional Flutter engines and `window_manager` for native title-bar operations. Add this package only to desktop applications that need native windows.

Add it to a desktop app with `flutter pub add fframe_window`.

## Bootstrap

The same entry point runs in the main and child engines. Use `currentWindow.route` to select the FFrame root for each window:

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

Child engines need generated plugin registration. Add the callback beside the primary runner's existing registration:

**Windows** (`windows/runner/flutter_window.cpp`), add the include and callback after the existing `RegisterPlugins` call:

```cpp
#include <desktop_multi_window/desktop_multi_window_plugin.h>

DesktopMultiWindowSetWindowCreatedCallback([](void* controller) {
  auto* view_controller =
      reinterpret_cast<flutter::FlutterViewController*>(controller);
  RegisterPlugins(view_controller->engine());
});
```

**macOS** (`macos/Runner/MainFlutterWindow.swift`), add `import desktop_multi_window` and register after the existing plugin registration:

```swift
FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
  RegisterGeneratedPlugins(registry: controller)
}
```

**Linux** (`linux/runner/my_application.cc`), add the include and callback after the existing `fl_register_plugins` call:

```cpp
#include <desktop_multi_window/desktop_multi_window_plugin.h>

desktop_multi_window_plugin_set_window_created_callback(
    [](FlPluginRegistry* registry) { fl_register_plugins(registry); });
```

The Showcase runners contain working callback examples. The package has a web-safe stub, so browser apps can keep the same import and select `runFFrameApp` when the desktop bootstrap is unavailable.

See the root [windowing guide](../../docs/controls/windowing.md) for the `FWindowManager`, title-bar, and floating-panel contracts.
