import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fframe/fframe.dart';

void main() {
  test('adaptive values and width classes resolve', () {
    const value = FAdaptiveValue<int>(compact: 8, medium: 12, expanded: 16);
    expect(value.resolve(FWindowClass.compact), 8);
    expect(value.resolve(FWindowClass.medium), 12);
    expect(FWindowClassSizing.fromWidth(1200), FWindowClass.expanded);
  });

  testWidgets('selects the first matching state and exposes scope data',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 900,
          height: 600,
          child: FAdaptiveBuilder(
            states: <FLayoutState>[
              FLayoutState(
                when: const FLayoutCondition(minWidth: 800),
                builder: (context) =>
                    Text(FLayoutScope.maybeOf(context)!.windowClass.name),
              ),
              FLayoutState.fallback(builder: (_) => const Text('compact')),
            ],
          ),
        ),
      ),
    );
    expect(find.text('medium'), findsOneWidget);
  });

  testWidgets('adaptive visibility uses local width constraints',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 500,
            height: 200,
            child: FAdaptiveVisibility(
              when: const FLayoutCondition(minWidth: 600),
              child: const Text('wide only'),
            ),
          ),
        ),
      ),
    );
    expect(tester.widget<Offstage>(find.byType(Offstage)).offstage, isTrue);
  });
}
