# fframe

FFrame is a desktop-first Flutter application framework. Import
`package:fframe/fframe.dart` for FFrame's own application, composition,
layout, design-system, and control APIs. App source uses `F`-prefixed names such
as `FStatelessWidget`, `FText`, `FRow`, `FButton`, and `FDesktopShell`.

```dart
import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';

void main() => runFFrameApp(const ExampleApp());

class ExampleApp extends FStatelessWidget {
  const ExampleApp();

  @override
  FWidget build(FBuildContext context) => FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FDesktopShell(
          body: FCenter(
            child: FButton(
              onPressed: () {},
              child: const FText('Save'),
            ),
          ),
        ),
      );
}
```

Application code does not import or compose Flutter Widgets or Material
controls. Flutter provides the runtime beneath FFrame; its low-level types and
rendering details stay inside FFrame's implementation. The WPF-inspired design
system is available from `fframe_wpf`.
