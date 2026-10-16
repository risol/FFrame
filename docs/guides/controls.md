# FFrame application controls

FFrame applications build shared UI with `F`-prefixed APIs from
`package:fframe/fframe.dart`. State-manager-specific screens and bridge widgets
may use their package's base classes, then return FFrame controls through the
`FWidget` boundary. Keep reusable input, navigation, focus, and semantics
behavior in FFrame controls.

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
          titleBar: const FContainer(
            height: 44,
            child: FCenter(child: FText('Workspace')),
          ),
          body: const FCenter(child: FText('Content')),
        ),
      );
}
```

Use `FRow`, `FColumn`, `FStack`, `FWrap`, `FContainer`, `FPadding`,
`FSizedBox`, `FExpanded`, `FScrollArea`, and `FListView` to compose views. FFrame
controls such as `FButton`, `FTextField`, `FSelect`, `FSwitch`, `FTabs`,
`FSegmentedControl`, `FDataGrid`, `FTreeView`, `FTooltip`, and `FDialog` supply
their own behavior and read the active design system through `FTheme`.

`FIcons` is the stable FFrame icon vocabulary. Add a new FFrame icon name when
application code needs a symbol that is not in the existing set; app code
should not refer to another library's icon catalog. See the [icon guide](../design-system/icons.md).

Flutter's rendering, focus, input, and accessibility mechanisms remain below
FFrame as its runtime implementation. New application-facing conveniences
should be added to the FFrame API before they are used by examples or product
code. For state and content packages, follow the [integration boundary guide](integrations.md).
