import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/reports/presentation/widgets/report_filter_widget.dart';
import 'package:multimidiaapp/app/modules/features/reports/presentation/widgets/report_period_label.dart';

void main() {
  testWidgets('filtro inicia com todos e reset não impõe pendente',
      (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
          home: Scaffold(
              body: ReportFilterWidget(
        onFiltersChanged: (filters) => changes.add(List.of(filters)),
      ))),
    ));
    expect(changes, isEmpty);
    await tester.tap(find.text('Rascunhos'));
    await tester.pump();
    expect(changes.last, ['rascunho']);
    await tester.tap(find.text('Resetar'));
    await tester.pump();
    expect(changes.last, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('período herdado explica criação e aceita um único limite',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Column(children: [
      const ReportPeriodLabel(),
      ReportPeriodLabel(start: DateTime(2026, 9, 1)),
      ReportPeriodLabel(end: DateTime(2026, 9, 7)),
      ReportPeriodLabel(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 7)),
    ]))));
    expect(find.text('Criação dos orçamentos: sem filtro de período'),
        findsOneWidget);
    expect(find.text('Criação dos orçamentos: a partir de 01/09/2026'),
        findsOneWidget);
    expect(find.text('Criação dos orçamentos: até 07/09/2026'), findsOneWidget);
    expect(find.text('Criação dos orçamentos: 01/09/2026 a 07/09/2026'),
        findsOneWidget);
  });
}
