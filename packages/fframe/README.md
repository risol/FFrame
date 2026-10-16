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

Application UI is composed with FFrame's `F*` APIs. Integration packages may
adapt Riverpod, Markdown, FFlow, or platform widgets at the `FWidget` boundary;
FFrame itself remains independent of those packages. Material controls are not
part of the shared control surface. The WPF-inspired design system is available
from `fframe_wpf`.

See the [API index](../../docs/api/README.md) and [integration boundaries](../../docs/guides/integrations.md).
