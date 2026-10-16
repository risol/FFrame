# Migrate to FFrame 0.2

FFrame 0.2 turns the former single package into a package suite. Replace the old package imports with the package that owns the capability:

```dart
import 'package:fframe/fframe.dart'; // FFrame application and control APIs
import 'package:fframe_wpf/fframe_wpf.dart'; // WPF visual system
```

The main `fframe` library is the application-facing API. App source uses only
FFrame-owned names such as `FText`, `FRow`, `FButton`, and `FFrameApp`; it does
not import Flutter Widgets or Material. Flutter remains FFrame's runtime layer.
`fframe_wpf` is the only first-party visual system. Previous FFrame Minimal,
Fluent, and Material visual-system packages have been removed.

In this monorepo, run `dart pub get` at the root and then `dart run melos bootstrap`. Published packages refer to each other through normal semver constraints.
