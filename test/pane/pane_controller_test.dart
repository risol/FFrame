import 'package:flutter_test/flutter_test.dart';
import 'package:fframe/fframe.dart';

void main() {
  test('pane controller clamps, collapses, and restores snapshots', () {
    final controller = FPaneController();
    controller.configurePane(
      id: 'sidebar',
      initialSize: 240,
      minSize: 180,
      maxSize: 360,
      collapsible: true,
    );

    controller.setSize('sidebar', 400);
    expect(controller.stateFor('sidebar')!.size, 360);
    final snapshot = controller.snapshot();
    controller.collapse('sidebar');
    expect(controller.stateFor('sidebar')!.collapsed, isTrue);
    controller.setSize('sidebar', 260);
    controller.restore(snapshot);
    expect(controller.stateFor('sidebar'),
        const FPaneState(size: 360, userSized: true));
    controller.reset('sidebar');
    expect(controller.stateFor('sidebar'), const FPaneState(size: 240));
    controller.dispose();
  });

  test('restores state before panes are first configured', () {
    final controller = FPaneController();
    controller.restore(
      FPaneSnapshot(const <String, FPaneState>{
        'sidebar': FPaneState(size: 280, collapsed: true, userSized: true),
      }),
    );
    controller.configurePane(
      id: 'sidebar',
      initialSize: 240,
      minSize: 180,
      maxSize: 360,
      collapsible: true,
    );
    expect(
      controller.stateFor('sidebar'),
      const FPaneState(size: 280, collapsed: true, userSized: true),
    );
    controller.dispose();
  });
}
