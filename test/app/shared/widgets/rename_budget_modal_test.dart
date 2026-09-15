import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/rename_budget_modal.dart';

void main() {
  testWidgets('confirma o nome atual sem rejeitar a operacao', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var calls = 0;
    String? receivedName;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => RenameBudgetModal.show<void>(
                  context: context,
                  currentName: 'projeto 2026',
                  onRename: (newName) async {
                    calls++;
                    receivedName = newName;
                  },
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('projeto 2026'), findsNWidgets(2));
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      'projeto 2026',
    );

    await tester.tap(find.text('Renomear'));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(receivedName, 'projeto 2026');
    expect(find.text('Renomear orçamento'), findsNothing);
    expect(find.text('Orçamento renomeado com sucesso!'), findsOneWidget);
  });
}
