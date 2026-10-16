import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fframe/fframe.dart';

void main() {
  testWidgets('renders and resizes adjacent panes with pointer drag',
      (tester) async {
    final controller = FPaneController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 800,
          height: 400,
          child: FSplitView.horizontal(
            controller: controller,
            children: const <FPane>[
              FPane(
                  id: 'sidebar',
                  preferredSize: 200,
                  minSize: 150,
                  maxSize: 400,
                  child: SizedBox.expand()),
              FPane.flex(id: 'content', minSize: 300, child: SizedBox.expand()),
            ],
          ),
        ),
      ),
    );

    expect(controller.stateFor('sidebar')!.size, 200);
    await tester.drag(find.byType(FSplitter), const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(controller.stateFor('sidebar')!.size, 240);

    await tester.tap(find.byType(FSplitter));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(controller.stateFor('sidebar')!.size, 250);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(controller.stateFor('sidebar')!.size, 200);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(controller.stateFor('sidebar')!.size, 400);
    await tester.pump(const Duration(milliseconds: 300));
    controller.dispose();
  });

  testWidgets(
      'temporarily collapses low priority panes under narrow constraints',
      (tester) async {
    final controller = FPaneController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 600,
          height: 300,
          child: FSplitView.horizontal(
            controller: controller,
            children: const <FPane>[
              FPane.flex(id: 'content', minSize: 450, child: SizedBox.expand()),
              FPane(
                  id: 'inspector',
                  preferredSize: 240,
                  minSize: 200,
                  collapsible: true,
                  collapsePriority: 1,
                  child: SizedBox.expand()),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(FSplitView), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
