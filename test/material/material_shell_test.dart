import 'package:fframe/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses bottom navigation at compact widths', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: _shell()));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses the drawer navigation at very narrow widths',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester
        .pumpWidget(MaterialApp(home: _shell(scaffoldKey: scaffoldKey)));

    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('uses an extended rail at expanded widths', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: _shell()));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue);
  });
}

Widget _shell({GlobalKey<ScaffoldState>? scaffoldKey}) => FMaterialShell(
      destinations: const <FMaterialDestination>[
        FMaterialDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        FMaterialDestination(
            icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      scaffoldKey: scaffoldKey,
      body: const Text('Content'),
    );
