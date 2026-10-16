import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fframe/fframe.dart';
import 'package:window_manager/window_manager.dart';

/// Builds the root FFrame app for the current native window.
typedef FDesktopAppBuilder = FWidget Function(
  FWindowManager windowManager,
  FWindowSpec currentWindow,
);

/// Boots a desktop FFrame app and configures the current OS window.
///
/// The same Dart entry point is started in the primary and every child window.
/// Child windows receive their [FWindowSpec] as JSON arguments. Configure the
/// platform plugin registration callback described in the package README for
/// each native runner so plugins are available in child Flutter engines.
abstract final class FDesktopWindowBootstrap {
  /// Whether the current Flutter target can create native desktop windows.
  static bool get isSupportedPlatform => !kIsWeb && _isDesktop;

  static Future<void> run({
    required FWindowSpec mainWindow,
    required FDesktopAppBuilder appBuilder,
    bool frameless = true,
  }) async {
    if (!isSupportedPlatform) {
      throw UnsupportedError(
        'FDesktopWindowBootstrap supports Windows, macOS, and Linux desktop.',
      );
    }
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    final current = await WindowController.fromCurrentEngine();
    final spec =
        FDesktopWindowAdapter.decodeSpec(current.arguments) ?? mainWindow;
    final options = WindowOptions(
      title: spec.title,
      size: spec.size,
      minimumSize: spec.minimumSize,
      titleBarStyle: frameless ? TitleBarStyle.hidden : TitleBarStyle.normal,
      windowButtonVisibility: !frameless,
    );
    await windowManager.waitUntilReadyToShow(options);
    await windowManager.show();
    await windowManager.focus();

    final adapter = FDesktopWindowAdapter._(current);
    await adapter._installCurrentWindowHandler();
    runFFrameApp(appBuilder(FWindowManager(adapter), spec));
  }

  static bool get _isDesktop => switch (defaultTargetPlatform) {
        TargetPlatform.windows ||
        TargetPlatform.macOS ||
        TargetPlatform.linux =>
          true,
        _ => false,
      };
}

/// Native [FWindowAdapter] implementation backed by desktop plugins.
class FDesktopWindowAdapter implements FWindowAdapter {
  FDesktopWindowAdapter._(this._currentWindow);

  final WindowController _currentWindow;
  final Map<String, WindowController> _controllers =
      <String, WindowController>{};

  @override
  Future<bool> openWindow(FWindowSpec spec) async {
    final existing = await _findController(spec.id);
    if (existing != null) {
      await existing.show();
      return true;
    }
    final controller = await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode(_encodeSpec(spec)),
        hiddenAtLaunch: true,
      ),
    );
    _controllers[spec.id] = controller;
    // The child bootstrap applies its native size and shows the new window.
    return true;
  }

  @override
  Future<void> closeWindow(String id) async {
    final controller = await _findController(id);
    if (controller != null) {
      await controller.invokeMethod<void>('fframe.close');
      _controllers.remove(id);
    }
  }

  @override
  Future<void> closeCurrentWindow() => windowManager.close();

  @override
  Future<void> minimizeCurrentWindow() => windowManager.minimize();

  @override
  Future<void> toggleMaximizeCurrentWindow() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Future<void> beginWindowDrag() => windowManager.startDragging();

  Future<WindowController?> _findController(String id) async {
    _controllers.clear();
    for (final controller in await WindowController.getAll()) {
      final spec = decodeSpec(controller.arguments);
      if (spec != null) {
        _controllers[spec.id] = controller;
      }
    }
    return _controllers[id];
  }

  Future<void> _installCurrentWindowHandler() =>
      _currentWindow.setWindowMethodHandler((call) async {
        switch (call.method) {
          case 'fframe.close':
            await windowManager.close();
            return null;
          default:
            throw MissingPluginException(
              'FFrame window method not implemented: ${call.method}',
            );
        }
      });

  static Map<String, Object?> _encodeSpec(FWindowSpec spec) =>
      <String, Object?>{
        'fframeWindowSpec': 1,
        'id': spec.id,
        'title': spec.title,
        'route': spec.route,
        'arguments': spec.arguments,
        'width': spec.size.width,
        'height': spec.size.height,
        'minimumWidth': spec.minimumSize.width,
        'minimumHeight': spec.minimumSize.height,
      };

  /// Decodes an optional FFrame window payload from a native engine.
  static FWindowSpec? decodeSpec(String payload) {
    if (payload.isEmpty) return null;
    try {
      final value = jsonDecode(payload);
      if (value is! Map<String, dynamic> || value['fframeWindowSpec'] != 1) {
        return null;
      }
      return FWindowSpec(
        id: value['id'] as String,
        title: value['title'] as String,
        route: value['route'] as String,
        arguments: value['arguments'],
        size: Size(
          (value['width'] as num).toDouble(),
          (value['height'] as num).toDouble(),
        ),
        minimumSize: Size(
          (value['minimumWidth'] as num).toDouble(),
          (value['minimumHeight'] as num).toDouble(),
        ),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
