// Patrol — exportação e compartilhamento (EXP).

import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/budget_card_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-EXP-001 — Gerar PDF com dados completos (parcial)',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o primeiro orçamento existente.
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.tap();
      await $.pumpAndSettle();
      // Esperado: tela de edição carregada com botão de salvar e
      // botão de exportar (ícone de compartilhamento no cabeçalho).
      expect($('Salvar Alterações'), findsOneWidget);
    },
  );

}
