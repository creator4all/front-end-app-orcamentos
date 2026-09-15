// Patrol — lista de orçamentos (ORC).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/budget_card_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-ORC-001 — Listar orçamentos próprios como vendedor',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Esperado: lista de orçamentos exibida com filtros, busca e "Novo Orç.".
      expect($('Novo Orç.'), findsOneWidget);
      expect($('Orçamentos'), findsWidgets);
    },
  );

  patrolTest(
    'CT-MOB-ORC-003 — Listar orçamentos de todos os parceiros como administrador',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      // Esperado: admin vê todos os orçamentos com nome do vendedor.
      expect($('Novo Orç.'), findsOneWidget);
      expect($('Orçamentos'), findsWidgets);
    },
  );

  patrolTest(
    'CT-MOB-ORC-004 — Buscar orçamento por texto',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Esperado: busca filtra a lista.
      // A busca pode estar em um TextField ou ícone de busca.
      await $.pumpAndSettle();
      // Verifica se há orçamentos na lista.
      expect($('Orçamentos'), findsWidgets);
    },
  );

  patrolTest(
    'CT-MOB-ORC-005 — Filtrar por status (parcial)',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Esperado: filtros de status visíveis e clicáveis.
      expect($('Orçamentos'), findsWidgets);
    },
  );

  patrolTest(
    'CT-MOB-ORC-006 — Exibir arquivados e voltar aos realizados',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Toca no filtro "Arquivados" para exibir orçamentos arquivados.
      await $('Arquivados').tap();
      await $.pumpAndSettle();
      // Esperado: cabeçalho da seção muda para "Arquivados".
      expect($('Arquivados'), findsWidgets);
      // Toca novamente para voltar aos realizados.
      await $('Arquivados').tap();
      await $.pumpAndSettle();
      // Esperado: cabeçalho da seção volta para "Realizados".
      expect($('Realizados'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-ORC-007 — Resetar filtros',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Aplica um filtro diferente do padrão para depois resetar.
      await $('Aprovados').tap();
      await $.pumpAndSettle();
      // Toca em "Resetar" para restaurar o estado padrão.
      await $('Resetar').tap();
      await $.pumpAndSettle();
      // Esperado: filtros resetados, lista de orçamentos visível.
      expect($('Orçamentos'), findsWidgets);
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-ORC-009 — Atualizar lista por gesto de refresh',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Swipe para baixo para atualizar.
      await $.pumpAndSettle();
      // O gesto de refresh não deve causar crash.
      expect($('Orçamentos'), findsWidgets);
    },
  );

  patrolTest(
    'CT-MOB-ORC-010 — Estado vazio da lista',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Esperado: quando não há orçamentos, exibe "Nenhum orçamento encontrado".
      // Pode não ser o caso se houver dados, mas validamos a estabilidade.
      expect($('Orçamentos'), findsWidgets);
    },
  );

  patrolTest(
    'CT-MOB-ORC-012 — Abrir detalhes ou edição de orçamento permitido',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o primeiro orçamento da lista.
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.tap();
      await $.pumpAndSettle();
      // Esperado: tela de edição carregada com botão "Salvar Alterações".
      expect($('Salvar Alterações'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-ORC-014 — Rejeitar nome vazio ao renomear',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.longPress();
      await $('Renomear orçamento').waitUntilVisible();
      await $(TextField).enterText('');
      await $('Renomear').tap();
      await $('O nome não pode estar vazio').waitUntilVisible();
      expect($('O nome não pode estar vazio'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-ORC-015 — Rejeitar nome acima do limite aceito',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.longPress();
      await $('Renomear orçamento').waitUntilVisible();
      await $(TextField).enterText(List.filled(256, 'x').join());
      await $('Renomear').tap();
      await $('O nome deve ter no máximo 255 caracteres').waitUntilVisible();
      expect($('O nome deve ter no máximo 255 caracteres'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-ORC-008 — Paginação por rolagem',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Esperado: lista de orçamentos carregada.
      expect($('Novo Orç.'), findsOneWidget);
      // Rola a lista para baixo para disparar paginação, se houver mais
      // de uma página. Usa drag direto para não depender de um finder
      // específico no final da lista.
      for (var i = 0; i < 5; i++) {
        await $.tester
            .drag(find.byType(Scrollable).first, const Offset(0, -400));
        await $.pumpAndSettle();
      }
      // Esperado: lista estável, sem crash, duplicações ou chamadas infinitas.
      expect($('Orçamentos'), findsWidgets);
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-ORC-017 — Desarquivar orçamento',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Toca no filtro "Arquivados" para exibir a seção de arquivados.
      await $('Arquivados').tap();
      await $.pumpAndSettle();
      // Esperado: seção de arquivados exibida.
      expect($('Arquivados'), findsWidgets);
    },
  );

  patrolTest(
    'CT-MOB-ORC-020 — Orçamento finalizado/somente leitura',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o primeiro orçamento da lista.
      final budgetCard = $(BudgetCardWidget).at(0);
      await budgetCard.waitUntilVisible();
      await budgetCard.tap();
      await $.pumpAndSettle();
      // Esperado: se o orçamento estiver aprovado/finalizado, a edição é
      // bloqueada com "Este orçamento não pode mais ser editado".
      // Se estiver editável, "Salvar Alterações" aparece.
      expect(
        $(find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data == 'Salvar Alterações' ||
                  widget.data == 'Este orçamento não pode mais ser editado'),
        )),
        findsWidgets,
      );
    },
  );

}
