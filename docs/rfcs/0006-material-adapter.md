# RFC 0006 — Material adapter (superseded)

This proposal is retained as a historical record. Its Material adapters and
the `FWpfMaterialThemeData` bridge are removed. FFrame application code must
use the FFrame API from `package:fframe/fframe.dart`; it does not import or
compose Flutter Material controls. `fframe_wpf` styles FFrame controls only.

The implementation of FFrame may use Flutter's runtime internally. That does
not make Flutter Widgets or Material part of the application-facing API.
