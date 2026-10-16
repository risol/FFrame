/// Optional native desktop window implementation for FFrame.
library;

export 'src/desktop_window_stub.dart'
    if (dart.library.io) 'src/desktop_window.dart';
