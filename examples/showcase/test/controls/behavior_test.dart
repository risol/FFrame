import 'dart:ui' as ui;

import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show EditableText;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FListView builds only visible and cached rows', (tester) async {
    tester.view.physicalSize = const ui.Size(320, 220);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var built = 0;

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FListView.builder(
          itemCount: 10000,
          itemBuilder: (context, index) {
            built++;
            return FText('Row $index');
          },
        ),
      ),
    );

    expect(built, lessThan(100));
    expect(find.text('Row 0'), findsOneWidget);
  });

  testWidgets('numeric formatting and FForm validation are surfaced', (
    tester,
  ) async {
    final form = FFormController();
    final input = FTextEditingController(text: '808');
    String? savedValue;
    addTearDown(input.dispose);

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FForm(
          controller: form,
          child: FColumn(
            children: <FWidget>[
              FTextField(
                controller: input,
                label: 'Port',
                keyboardType: FTextInputType.number,
                inputFormatters: <FTextInputFormatter>[
                  FInputFormatters.digitsOnly,
                ],
                maxLength: 3,
                validator: (value) => value.length == 3 ? null : 'Required',
                onSaved: (value) => savedValue = value,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '');
    await tester.enterText(find.byType(EditableText), '12a34');
    expect(input.text, '123');
    expect(form.validate(), isTrue);
    form.save();
    expect(savedValue, '123');
    form.reset();
    expect(input.text, '808');
    await tester.enterText(find.byType(EditableText), '');
    expect(form.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('FTextField supports secure, multiline, errors, and length', (
    tester,
  ) async {
    final password = FTextEditingController();
    addTearDown(password.dispose);

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FColumn(
          children: <FWidget>[
            FTextField(
              controller: password,
              label: 'Password',
              obscureText: true,
              maxLength: 8,
              errorText: 'Credential required',
            ),
            const FTextField(label: 'Notes', minLines: 2, maxLines: 4),
          ],
        ),
      ),
    );

    final editableFields = tester.widgetList<EditableText>(
      find.byType(EditableText),
    );
    expect(editableFields.first.obscureText, isTrue);
    expect(editableFields.last.maxLines, 4);
    expect(find.text('Credential required'), findsOneWidget);
    expect(find.text('0/8'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'long-password');
    expect(password.text, 'long-pas');
    await tester.pump();
    expect(find.text('8/8'), findsOneWidget);
  });

  testWidgets('FMarkdown hosts an adapter result through FWidget', (
    tester,
  ) async {
    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: const FMarkdown(
          source: '# A heading',
          renderer: _PlainMarkdownRenderer(),
        ),
      ),
    );

    expect(find.text('Rendered: # A heading'), findsOneWidget);
  });

  testWidgets('FDataGrid sorts rows and reports controlled selection', (
    tester,
  ) async {
    tester.view.physicalSize = const ui.Size(400, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selected = <Object>{};
    const rows = <_GridRecord>[_GridRecord(1, 'Zoe'), _GridRecord(2, 'Alice')];

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FSizedBox(
          width: 400,
          height: 240,
          child: FDataGrid<_GridRecord>(
            rows: rows,
            rowKey: (row) => row.id,
            onSelectionChanged: (value) => selected = value,
            columns: <FDataGridColumn<_GridRecord>>[
              FDataGridColumn<_GridRecord>(
                label: 'Name',
                width: 200,
                cellBuilder: (context, row) => FText(row.name),
                compare: (left, right) => left.name.compareTo(right.name),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Alice')).dy,
      lessThan(tester.getTopLeft(find.text('Zoe')).dy),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(selected, <Object>{2});
  });

  testWidgets('FTreeView loads children when expanded', (tester) async {
    tester.view.physicalSize = const ui.Size(320, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FSizedBox(
          width: 320,
          height: 240,
          child: FTreeView<String>(
            nodes: <FTreeNode<String>>[
              FTreeNode<String>(
                id: 'root',
                value: 'root',
                label: 'Root',
                loadChildren: () async => <FTreeNode<String>>[
                  const FTreeNode<String>(
                    id: 'child',
                    value: 'child',
                    label: 'Child',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Child'), findsOneWidget);
  });

  testWidgets('popover Escape dismisses and restores trigger focus', (
    tester,
  ) async {
    final triggerFocus = FFocusNode();
    final popupFocus = FFocusNode();
    addTearDown(triggerFocus.dispose);
    addTearDown(popupFocus.dispose);

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FPopover(
          focusNode: triggerFocus,
          trigger: const FText('Open details'),
          content: FTextField(
            focusNode: popupFocus,
            label: 'Details',
            autofocus: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    expect(popupFocus.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
    expect(triggerFocus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('popover outside dismissal restores trigger focus', (
    tester,
  ) async {
    final triggerFocus = FFocusNode();
    addTearDown(triggerFocus.dispose);

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FColumn(
          crossAxisAlignment: FCrossAxisAlignment.start,
          children: <FWidget>[
            FPopover(
              focusNode: triggerFocus,
              trigger: const FText('Open menu'),
              content: const FPanel(child: FText('Popover content')),
            ),
            const FSizedBox(height: 60),
            FButton(onPressed: () {}, child: const FText('Outside action')),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();
    expect(find.text('Popover content'), findsOneWidget);
    await tester.tap(find.text('Outside action'));
    await tester.pumpAndSettle();
    expect(find.text('Popover content'), findsNothing);
    expect(triggerFocus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialog Escape closes the route and returns focus', (
    tester,
  ) async {
    final triggerFocus = FFocusNode();
    final dialogFocus = FFocusNode();
    addTearDown(triggerFocus.dispose);
    addTearDown(dialogFocus.dispose);

    await tester.pumpWidget(
      FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: _DialogTrigger(
          triggerFocus: triggerFocus,
          dialogFocus: dialogFocus,
        ),
      ),
    );

    await tester.tap(find.text('Show dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog field'), findsOneWidget);
    expect(dialogFocus.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Dialog field'), findsNothing);
    expect(triggerFocus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class _DialogTrigger extends FStatelessWidget {
  const _DialogTrigger({required this.triggerFocus, required this.dialogFocus});

  final FFocusNode triggerFocus;
  final FFocusNode dialogFocus;

  @override
  FWidget build(FBuildContext context) => FCenter(
    child: FButton(
      focusNode: triggerFocus,
      onPressed: () => showFDialog<void>(
        context: context,
        builder: (dialogContext) => FDialog(
          title: const FText('Confirm'),
          content: FTextField(
            focusNode: dialogFocus,
            label: 'Dialog field',
            autofocus: true,
          ),
        ),
      ),
      child: const FText('Show dialog'),
    ),
  );
}

class _GridRecord {
  const _GridRecord(this.id, this.name);

  final int id;
  final String name;
}

class _PlainMarkdownRenderer implements FMarkdownRenderer {
  const _PlainMarkdownRenderer();

  @override
  FWidget build(
    FBuildContext context, {
    required String source,
    required FMarkdownStyle style,
    required bool selectable,
  }) => FWidgetAdapter(builder: (_) => FText('Rendered: $source'));
}
