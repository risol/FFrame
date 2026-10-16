# fframe_wpf

The WPF-inspired design system for FFrame applications. It supplies Windows
desktop colors, compact Segoe UI typography, square control geometry, and
familiar hover, pressed, disabled, and keyboard-focus treatments to FFrame's
own controls. It does not host .NET WPF controls or require the .NET desktop
runtime.

```dart
import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';

FFrameApp(
  designSystem: FWpfDesignSystem.light(),
  home: FPanel(
    child: FButton(
      variant: FButtonVariant.primary,
      onPressed: () {},
      child: const FText('Save'),
    ),
  ),
)
```

Applications compose views with FFrame APIs only. `fframe_wpf` controls the
visual system; Flutter remains the runtime implementation beneath FFrame.
