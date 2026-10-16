import 'package:fframe/fframe.dart';

/// Builds the root FFrame app for a native desktop window.
typedef FDesktopAppBuilder = FWidget Function(
  FWindowManager windowManager,
  FWindowSpec currentWindow,
);

/// Web-safe entry point for the optional desktop window package.
abstract final class FDesktopWindowBootstrap {
  /// Native windows are unavailable when `dart:io` is not supported.
  static const bool isSupportedPlatform = false;

  /// Reports that the desktop-only adapter cannot run on this platform.
  static Future<void> run({
    required FWindowSpec mainWindow,
    required FDesktopAppBuilder appBuilder,
    bool frameless = true,
  }) =>
      Future<void>.error(
        UnsupportedError(
          'Native FFrame windows are unavailable on this platform.',
        ),
      );
}

/// Web-side type placeholder for the native adapter.
class FDesktopWindowAdapter implements FWindowAdapter {
  FDesktopWindowAdapter._();

  static FWindowSpec? decodeSpec(String payload) => null;

  @override
  Future<bool> openWindow(FWindowSpec spec) => _unsupported();

  @override
  Future<void> closeWindow(String id) => _unsupported();

  @override
  Future<void> closeCurrentWindow() => _unsupported();

  @override
  Future<void> minimizeCurrentWindow() => _unsupported();

  @override
  Future<void> toggleMaximizeCurrentWindow() => _unsupported();

  @override
  Future<void> beginWindowDrag() => _unsupported();

  Future<T> _unsupported<T>() => Future<T>.error(
        UnsupportedError(
          'Native FFrame windows are unavailable on this platform.',
        ),
      );
}
