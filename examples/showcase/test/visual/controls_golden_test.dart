import 'dart:ui' as ui;

import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WPF control baseline', (tester) async {
    tester.view.physicalSize = const ui.Size(800, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = FTextEditingController(text: 'database.internal');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FContainer(
          color: const FColor(0xfff3f3f3),
          child: FCenter(
            child: FPanel(
              padding: const FEdgeInsets.all(24),
              child: FColumn(
                mainAxisSize: FMainAxisSize.min,
                crossAxisAlignment: FCrossAxisAlignment.start,
                children: <FWidget>[
                  FText('Connection settings'),
                  const FSizedBox(height: 14),
                  FTextField(
                    controller: controller,
                    label: 'Host name',
                    maxLength: 40,
                    errorText: 'Host is not reachable',
                  ),
                  const FSizedBox(height: 16),
                  FSegmentedControl<String>(
                    items: <FSegmentedItem<String>>[
                      FSegmentedItem(value: 'read', label: 'Read only'),
                      FSegmentedItem(value: 'write', label: 'Read and write'),
                    ],
                    selectedValue: 'read',
                    onChanged: (value) {},
                  ),
                  const FSizedBox(height: 18),
                  FRow(
                    mainAxisAlignment: FMainAxisAlignment.end,
                    children: <FWidget>[
                      FButton(
                        onPressed: null,
                        variant: FButtonVariant.secondary,
                        child: const FText('Cancel'),
                      ),
                      const FSizedBox(width: 8),
                      FButton(
                        onPressed: () {},
                        variant: FButtonVariant.primary,
                        child: const FText('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(FPanel),
      matchesGoldenFile('goldens/controls_baseline.png'),
    );
  });
}
