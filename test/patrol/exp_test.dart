// Testes Patrol — Domínio EXP (Geração e compartilhamento)
//
// Caso automatizado: EXP-001
// Caso skipado: EXP-008 (PDF renova validade em 60 dias)

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

  patrolTest(
    'CT-MOB-EXP-008 — Gerar PDF renova validade para 60 dias',
    config: patrolConfig,
    skip:
        true, // Requer gerar/compartilhar PDF e reler a validade no orçamento (válido e expirado).
    ($) async {
      await loginAsSeller($);
      expect($('Novo Orç.'), findsOneWidget);
    },
  );
}
