import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fframe_layout/fframe_layout.dart';

void main() {
  testWidgets('selects three, two, and one pane layouts by available width',
      (tester) async {
    final size = tester.view.physicalSize;
    final ratio = tester.view.devicePixelRatio;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = ratio;
    });

    Future<void> pumpWidth(double width) async {
      await tester.binding.setSurfaceSize(Size(width, 600));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: width,
            height: 600,
            child: FWorkspace(
              navigation: const FWorkspacePane(child: Text('navigation')),
              content: const Text('content'),
              inspector: const FWorkspacePane(child: Text('inspector')),
            ),
          ),
        ),
      );
    }

    await pumpWidth(1440);
    expect(find.text('navigation'), findsOneWidget);
    expect(find.text('inspector'), findsOneWidget);
    await pumpWidth(800);
    expect(find.text('navigation'), findsOneWidget);
    expect(find.text('inspector'), findsNothing);
    await pumpWidth(640);
    expect(find.text('navigation'), findsNothing);
    expect(find.text('content'), findsOneWidget);
    for (final width in <double>[1024, 1280, 1920, 2560]) {
      await pumpWidth(width);
      expect(find.text('content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an overlay pane when the app opens it', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = FWorkspaceController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FWorkspace(
          controller: controller,
          navigation: const FWorkspacePane(
            collapseBehavior: FPaneCollapseBehavior.overlay,
            child: Text('overlay navigation'),
          ),
          content: const Text('main content'),
        ),
      ),
    );
    expect(find.text('overlay navigation'), findsNothing);
    controller.toggleNavigation();
    await tester.pump();
    expect(find.text('overlay navigation'), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
