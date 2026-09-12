// Jornadas do vendedor: login, sessão, menu, criar, editar e PDF.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/budget_card_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'seller_login_shows_own_budget_list (AUT-001, ORC-001)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('seller_budget', (fixture) async {
        await loginAsFixture($, fixture);
        expect($('Novo Orç.'), findsOneWidget);
        expect($('Orçamentos'), findsWidgets);
        expect($('Digite o código'), findsNothing);
        await $(fixture.expectedBudgetName).waitUntilVisible();
        expect($(BudgetCardWidget), findsWidgets);
      });
    },
  );

  patrolTest(
    'seller_confirms_logout (AUT-010)',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await logoutToLogin($);
      expect($('Acessar'), findsOneWidget);
    },
  );

  patrolTest(
    'seller_reopens_app_with_valid_session (AUT-012)',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await startApp($);
      await $('Novo Orç.').waitUntilVisible();
      expect($('Novo Orç.'), findsOneWidget);
      expect($('Acessar'), findsNothing);
    },
  );

  patrolTest(
    'seller_menu_hides_admin_entries (NAV-002, EMP-002, CAT-001, PRO-001)',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      expect($('Editar perfil'), findsOneWidget);
      expect($('Wiki'), findsOneWidget);
      expect($('Drive'), findsOneWidget);
      expect($('Sair'), findsOneWidget);
      expect($('Deletar conta'), findsOneWidget);
      expect($('Editar empresa'), findsNothing);
      expect($('Configurar produtos'), findsNothing);
      expect($('Prospecção de parceiros'), findsNothing);
      expect($('Gestão administrativa'), findsNothing);
    },
  );

  patrolTest(
    'seller_creates_single_city_budget (CRI-001, CRI-006, CRI-017, CRI-019)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('subordinate', (fixture) async {
        final stateName = fixture.stateName;
        final cityName = fixture.cityName;
        if (stateName == null ||
            stateName.isEmpty ||
            cityName == null ||
            cityName.isEmpty) {
          throw StateError(
            'Fixture subordinate veio sem estado/cidade. '
            'Confira cidades ativas no backend de teste.',
          );
        }

        await loginAsFixture($, fixture);
        await $('Novo Orç.').tap();
        await $.pumpAndSettle();
        expect($('Novo orçamento'), findsOneWidget);
        expect($('Gerar orçamento para (opcional):'), findsNothing);

        await selectSearchableDropdown(
          $,
          hint: 'Estado',
          item: stateName,
          searchHint: 'Pesquisar estado...',
        );
        await selectSearchableDropdown(
          $,
          hint: 'Cidade',
          item: cityName,
          searchHint: 'Pesquisar cidade...',
        );
        await $('Próximo').tap();
        await $('Censo Escolar').waitUntilVisible();
        expect($('Nenhuma categoria disponível'), findsNothing);
        if (fixture.categoryName != null && fixture.categoryName!.isNotEmpty) {
          expect($(fixture.categoryName!), findsWidgets);
        }

        await tapIfVisible($, 'Selecionar todos');
        await $.tester.ensureVisible(find.text('Salvar Orçamento'));
        await $('Salvar Orçamento').tap();
        await $.pumpAndSettle();
        await tapIfVisible($, 'Salvar mesmo assim');
        await dismissInfoDialog($);
        await $('Censo Escolar').waitUntilVisible();
        await $.tester.ensureVisible(find.text('Salvar Alterações'));

        await popToBudgetList($);
        await $(fixture.expectedBudgetName).waitUntilVisible();
      });
    },
  );

  patrolTest(
    'seller_edits_budget_and_list_updates (ORC-012, CAL-009)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('seller_budget', (fixture) async {
        await loginAsFixture($, fixture);
        await $(fixture.expectedBudgetName).waitUntilVisible();
        await $(fixture.expectedBudgetName).tap();
        await $.pumpAndSettle();
        await $('Censo Escolar').waitUntilVisible();
        await $.tester.ensureVisible(find.text('Salvar Alterações'));
        await $.pumpAndSettle();
        expect($('Salvar Alterações'), findsOneWidget);

        await tapIfVisible($, 'Selecionar todos');
        await $(TextField).at(1).enterText('45');
        await $.tester.ensureVisible(find.text('Salvar Alterações'));
        await $('Salvar Alterações').tap();
        await $.pumpAndSettle();
        await dismissInfoDialog($);
        expect($(find.widgetWithText(TextField, '45')), findsOneWidget);

        await popToBudgetList($);
        await $(fixture.expectedBudgetName).waitUntilVisible();
      });
    },
  );

  patrolTest(
    'seller_opens_export_pdf_modal (EXP-001)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('seller_budget', (fixture) async {
        await loginAsFixture($, fixture);
        await $(fixture.expectedBudgetName).waitUntilVisible();
        await $(fixture.expectedBudgetName).tap();
        await $.pumpAndSettle();
        await $('Censo Escolar').waitUntilVisible();
        await $(Icons.ios_share).tap();
        await $.pumpAndSettle();
        await $('Exportar PDF').waitUntilVisible();
        expect($('Exportar PDF'), findsOneWidget);
        expect($('Compartilhar PDF'), findsOneWidget);
      });
    },
  );
}
