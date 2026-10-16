import 'package:fframe_layout/fframe_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fixed and flex tracks render consistently', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 100,
            child: FGrid(
              columns: const <FTrack>[FTrack.fixed(80), FTrack.flex()],
              rows: const <FTrack>[FTrack.flex()],
              children: <FGridItem>[
                FGridItem(
                  column: 0,
                  child: const ColoredBox(color: Color(0xFF26364A)),
                ),
                FGridItem(
                  column: 1,
                  child: const ColoredBox(color: Color(0xFF5D77D5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(FGrid),
      matchesGoldenFile('goldens/grid_fixed_flex.png'),
    );
  });
}
