import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fframe_layout/fframe_layout.dart';

void main() {
  testWidgets('lays out fixed and flex cells', (tester) async {
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
                    key: const ValueKey('left'),
                    column: 0,
                    child: const SizedBox.expand()),
                FGridItem(
                    key: const ValueKey('right'),
                    column: 1,
                    child: const SizedBox.expand()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('left'))),
        const Size(80, 100));
    expect(tester.getSize(find.byKey(const ValueKey('right'))),
        const Size(220, 100));
    expect(tester.getTopLeft(find.byKey(const ValueKey('right'))).dx, 330);
  });

  testWidgets('supports spans, gaps, and RTL logical columns', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SizedBox(
            width: 210,
            height: 100,
            child: FGrid(
              columns: const <FTrack>[FTrack.fixed(100), FTrack.fixed(100)],
              rows: const <FTrack>[FTrack.flex()],
              columnGap: 10,
              children: <FGridItem>[
                FGridItem(
                    key: const ValueKey('span'),
                    columnSpan: 2,
                    child: const SizedBox.expand()),
                FGridItem(
                    key: const ValueKey('start'),
                    column: 0,
                    child: const SizedBox.expand()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('span'))),
        const Size(210, 100));
    expect(tester.getTopLeft(find.byKey(const ValueKey('start'))).dx, 405);
  });
}
