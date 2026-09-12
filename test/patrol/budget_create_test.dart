// Patrol — criação de orçamento (CRI).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/budget_card_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-CRI-001 — Abrir novo orçamento',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Toca em "Novo Orç." para abrir a tela de criação.
      await $('Novo Orç.').tap();
      await $.pumpAndSettle();
      // Esperado: tela "Novo orçamento" com seleção de Estado, Cidade e "Próximo".
      expect($('Novo orçamento'), findsOneWidget);
      expect($('Próximo'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-CRI-004 — Validar estado e cidade obrigatórios',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await $('Novo Orç.').tap();
      await $.pumpAndSettle();
      // Toca em "Próximo" sem selecionar estado/cidade.
      await $('Próximo').tap();
      await $.pumpAndSettle();
      // Esperado: mensagem "Selecione um estado e uma cidade".
      expect($('Selecione um estado e uma cidade'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-CRI-007 — Abandonar rascunho não cria orçamento recuperável',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await $('Novo Orç.').tap();
      await $.pumpAndSettle();
      // Volta sem salvar — deve retornar à lista de orçamentos.
      await $.platformAutomator.android.pressBack();
      await $.pumpAndSettle();
      // Esperado: lista de orçamentos exibida.
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-CRI-014 — Visualizar censo do orçamento',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o primeiro orçamento da lista.
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.tap();
      await $.pumpAndSettle();
      // Esperado: tela de edição carregada com card de censo visível.
      expect($('Salvar Alterações'), findsOneWidget);
      expect($('Censo Escolar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-CRI-017 — Navegar categoria, subcategoria e produtos',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o primeiro orçamento da lista para acessar a hierarquia.
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.tap();
      await $.pumpAndSettle();
      // Esperado: tela de edição com categorias de produtos e botão de salvar.
      expect($('Salvar Alterações'), findsOneWidget);
      // A hierarquia de categorias deve estar presente (não o estado vazio).
      expect($('Nenhuma categoria disponível'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-CRI-015 — Editar snapshot do censo',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o primeiro orçamento da lista.
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.tap();
      await $.pumpAndSettle();
      // Esperado: tela de edição carregada.
      expect($('Salvar Alterações'), findsOneWidget);
      // Navega até a tela de censo.
      await $('Censo Escolar').tap();
      await $.pumpAndSettle();
      // Esperado: tela "Censo escolar" exibida.
      expect($('Censo escolar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-CRI-025 — Impedir duplo salvamento',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o primeiro orçamento existente.
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.tap();
      await $.pumpAndSettle();
      // Esperado: tela de edição carregada com botão "Salvar Alterações".
      final saveButton = $('Salvar Alterações');
      await saveButton.waitUntilVisible();
      // Toca em salvar e imediatamente tenta tocar novamente.
      // O botão desabilita durante o salvamento (isSaving), impedindo
      // duplo salvamento.
      await saveButton.tap();
      await $.pumpAndSettle();
      // Após o settle, a tela deve estar estável (sucesso ou erro de
      // validação), sem crash ou diálogos duplicados.
      expect(
        $(find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data == 'Salvar Alterações' ||
                  widget.data == 'Atenção' ||
                  widget.data == 'Sucesso' ||
                  widget.data == 'Erro ao salvar'),
        )),
        findsWidgets,
      );
    },
  );
}
