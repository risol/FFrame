import 'dart:ui' as ui;

import 'package:fframe/fframe.dart';
import 'package:fframe_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the database client shell', (tester) async {
    tester.view.physicalSize = const ui.Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FFrameExampleApp());
    expect(find.byType(FDesktopShell), findsOneWidget);
    expect(find.text('customer_overview.sql'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the adaptive administration settings workspace', (
    tester,
  ) async {
    tester.view.physicalSize = const ui.Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FFrameExampleApp());
    await tester.tap(find.text('Administration'));
    await tester.pumpAndSettle();

    expect(find.text('FFrame Administration'), findsOneWidget);
    expect(find.text('Organization name'), findsOneWidget);
    expect(find.byType(FDesktopShell), findsOneWidget);

    await tester.tap(find.text('Security'));
    await tester.pumpAndSettle();
    expect(find.text('Require two factor authentication'), findsOneWidget);
    expect(tester.widget<FSwitch>(find.byType(FSwitch).first).value, isTrue);
    await tester.tap(find.byType(FSwitch).first);
    await tester.pumpAndSettle();
    expect(tester.widget<FSwitch>(find.byType(FSwitch).first).value, isFalse);
    expect(tester.takeException(), isNull);
  });
}
