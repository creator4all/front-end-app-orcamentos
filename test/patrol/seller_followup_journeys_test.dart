// Jornadas do vendedor: busca, paginação, multi-cidade, senha, cadastro e Drive.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'login_is_rejected_without_session (AUT-002, AUT-003, AUT-004)',
    config: patrolConfig,
    ($) async {
      await submitLogin($, email: sellerEmail, password: 'SenhaIncorreta123');
      await expectLoginRejected($);

      await $(TextField).at(0).enterText('inexistente@mail.com');
      await $(TextField).at(1).enterText(sellerPassword);
      await $('Acessar').tap();
      await expectLoginRejected($);

      await withMobileFixture('inactive', (fixture) async {
        await $(TextField).at(0).enterText(fixture.email);
        await $(TextField).at(1).enterText(mobileFixturePassword);
        await $('Acessar').tap();
        await expectLoginRejected($);
      });
    },
  );

  patrolTest(
    'budget_list_search_and_filters (ORC-004, ORC-005, ORC-006)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('seller_list', (fixture) async {
        final pendente = fixture.budgetNamePendente;
        final aprovado = fixture.budgetNameAprovado;
        if (pendente == null || aprovado == null) {
          throw StateError('Fixture seller_list veio sem nomes de orçamento.');
        }

        await loginAsFixture($, fixture);
        await $(pendente).waitUntilVisible();
        expect($(aprovado), findsNothing);

        await searchBudgets($, pendente);
        expect($(pendente), findsWidgets);
        expect($(aprovado), findsNothing);

        await $('Resetar').tap();
        await $.tester.pump();
        await $(pendente).waitUntilVisible();

        await $('Aprovados').tap();
        await $('Pendentes').tap();
        await $.tester.pump();
        await $(aprovado).waitUntilVisible();
        expect($(pendente), findsNothing);

        await $('Arquivados').tap();
        await $.tester.pump();
        expect($('Arquivados'), findsWidgets);
        expect($(pendente), findsNothing);
        expect($(aprovado), findsNothing);
      });
    },
  );

  patrolTest(
    'budget_list_paginates (ORC-008)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('seller_pagination', (fixture) async {
        final firstName = fixture.budgetNameFirst;
        final lastName = fixture.budgetNameLast;
        if (firstName == null || lastName == null) {
          throw StateError('Fixture seller_pagination veio sem nomes.');
        }

        await loginAsFixture($, fixture);
        await $(lastName).waitUntilVisible();
        expect($(lastName), findsOneWidget);

        for (var i = 0; i < 12; i++) {
          if ($(firstName).visible) {
            break;
          }
          await $.tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -400),
          );
          await $.tester.pump();
        }

        await $(firstName).waitUntilVisible();
        expect($(firstName), findsWidgets);
      });
    },
  );

  patrolTest(
    'seller_creates_multi_city_budget (CRI-010, CRI-016)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('subordinate', (fixture) async {
        final stateA = fixture.stateName;
        final cityA = fixture.cityName;
        final stateB = fixture.stateBName;
        final cityB = fixture.cityBName;
        if (stateA == null ||
            cityA == null ||
            stateB == null ||
            cityB == null) {
          throw StateError(
            'Fixture subordinate veio sem duas cidades. '
            'Confira cidades ativas no backend de teste.',
          );
        }

        const budgetName = 'P1 Multi Cidades';
        await loginAsFixture($, fixture);
        await $('Novo Orç.').tap();
        await $.pumpAndSettle();
        await $('Orçamento multi-cidades').tap();
        await $('Nome do Orçamento').waitUntilVisible();
        await fillTextFieldByHint(
          $,
          hint: 'Ex: Projeto Educação 2024',
          text: budgetName,
        );
        await $('Próximo').tap();
        await $('Adicionar cidades').waitUntilVisible();

        await selectSearchableDropdown(
          $,
          hint: 'Selecione o estado',
          item: stateA,
          searchHint: 'Pesquisar estado...',
        );
        await selectSearchableDropdown(
          $,
          hint: 'Selecione a cidade',
          item: cityA,
          searchHint: 'Pesquisar cidade...',
        );
        if (stateA != stateB) {
          await selectSearchableDropdown(
            $,
            hint: stateA,
            item: stateB,
            searchHint: 'Pesquisar estado...',
          );
        }
        await selectSearchableDropdown(
          $,
          hint: 'Selecione a cidade',
          item: cityB,
          searchHint: 'Pesquisar cidade...',
        );
        await $('Adicionar').tap();
        await $('Censo escolar').waitUntilVisible();
        expect($('$cityA - ${fixture.stateUf}'), findsWidgets);
        expect($('$cityB - ${fixture.stateBUf}'), findsWidgets);

        await $.tester.ensureVisible(find.text('Próximo'));
        await $('Próximo').tap();
        await $('Censo Escolar').waitUntilVisible();
        await tapIfVisible($, 'Selecionar todos');
        await $.tester.ensureVisible(find.text('Salvar Orçamento'));
        await $('Salvar Orçamento').tap();
        await $.pumpAndSettle();
        await tapIfVisible($, 'Salvar mesmo assim');
        await dismissInfoDialog($);
        await popToBudgetList($);
        await $(budgetName).waitUntilVisible();
      });
    },
  );

  patrolTest(
    'saving_budget_creates_archived_version (ORC-018)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('seller_budget', (fixture) async {
        await loginAsFixture($, fixture);
        await $(fixture.expectedBudgetName).waitUntilVisible();
        await $(fixture.expectedBudgetName).tap();
        await $.pumpAndSettle();
        await $('Censo Escolar').waitUntilVisible();
        await $.tester.ensureVisible(find.text('Salvar Alterações'));
        await tapIfVisible($, 'Selecionar todos');
        await $(TextField).at(1).enterText('45');
        await $.tester.ensureVisible(find.text('Salvar Alterações'));
        await $('Salvar Alterações').tap();
        await $.pumpAndSettle();
        await dismissInfoDialog($);

        await popToBudgetList($);
        await $(fixture.expectedBudgetName).waitUntilVisible();
        await $('Arquivados').tap();
        await $('Pendentes').tap();
        await $.tester.pump();
        await $(fixture.expectedBudgetName).waitUntilVisible();
      });
    },
  );

  patrolTest(
    'password_recovery_replaces_old_password (RPS-011)',
    config: patrolConfig,
    ($) async {
      const newPassword = 'SenhaForte@123';
      await withMobileFixture('active', (fixture) async {
        await startAppClean($);
        await $('Esqueci minha senha').tap();
        await $.pumpAndSettle();
        await $(TextField).enterText(fixture.email);
        await $('Enviar Código').tap();
        await $('Digite o código').waitUntilVisible();

        final otp = await revealMobileFixtureOtp(fixture.id);
        for (var i = 0; i < 6; i++) {
          await $(TextFormField)
              .at(i)
              .enterText(otp[i], hideKeyboard: i == 5);
        }
        await $.tester.ensureVisible(find.text('Verificar'));
        await $('Verificar').tap();
        await $('Requisitos da senha:').waitUntilExists();
        await fillTextFieldByHint(
          $,
          hint: 'Digite sua senha',
          text: newPassword,
        );
        await fillTextFieldByHint(
          $,
          hint: 'Digite sua senha',
          text: newPassword,
          index: 1,
        );
        await $.tester.ensureVisible(find.text('Redefinir Senha'));
        await $('Redefinir Senha').tap();
        await $('Senha Redefinida!').waitUntilVisible();
        await $('Ir para Login').tap();

        await login($, email: fixture.email, password: newPassword);
        expect($('Novo Orç.'), findsOneWidget);

        await logoutToLogin($);
        await $(TextField).at(0).enterText(fixture.email);
        await $(TextField).at(1).enterText(mobileFixturePassword);
        await $('Acessar').tap();
        await expectLoginRejected($);
      });
    },
  );

  patrolTest(
    'pending_self_registration_cannot_login (REG-011, REG-012)',
    config: patrolConfig,
    ($) async {
      await withMobileFixture('active', (fixture) async {
        final companyCnpj = fixture.companyCnpj;
        final companyName = fixture.companyName;
        if (companyCnpj == null || companyName == null) {
          throw StateError('O fixture não possui empresa vinculada.');
        }

        final newEmail =
            'ct-mob-pending-${DateTime.now().millisecondsSinceEpoch}@example.test';

        await startAppClean($);
        await $('Cadastrar').tap();
        await $.pumpAndSettle();
        await $(TextField).enterText(companyCnpj);
        await $('Próximo').tap();
        await $('A empresa $companyName está correta?').waitUntilVisible();
        await $('Sim').tap();
        await $.pumpAndSettle();

        final fields = $(TextFormField);
        await fields.at(0).enterText(fixture.email);
        await fields.at(1).enterText(fixture.email);
        await fields.at(2).enterText('Cadastro duplicado');
        await fields.at(3).enterText('11999999999');
        await $.tester.ensureVisible(find.byType(TextFormField).at(4));
        await $.tester.pump();
        await fields.at(4).enterText('SenhaForte@123');
        await $.tester.ensureVisible(find.byType(TextFormField).at(5));
        await $.tester.pump();
        await fields.at(5).enterText('SenhaForte@123');
        await $.scrollUntilVisible(finder: $('Cadastrar'));
        await $('Cadastrar').tap();
        await $('Este e-mail já está cadastrado no sistema.').waitUntilVisible();
        await tapIfVisible($, 'Entendi');

        await fields.at(0).enterText(newEmail);
        await fields.at(1).enterText(newEmail);
        await $.scrollUntilVisible(finder: $('Cadastrar'));
        await $('Cadastrar').tap();
        await $('Cadastro realizado!').waitUntilVisible();
        await $('Ir para Login').tap();
        await $.pumpAndSettle();

        await $(TextField).at(0).enterText(newEmail);
        await $(TextField).at(1).enterText('SenhaForte@123');
        await $('Acessar').tap();
        await expectLoginRejected($);
      });
    },
  );

  patrolTest(
    'seller_drive_lists_without_write_actions (DRV-001, DRV-006, DRV-015)',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      await $('Multi Drive').waitUntilVisible();
      expect($('Categorias'), findsOneWidget);
      expect($('Buscar arquivo'), findsOneWidget);
      expect($('Criar pasta'), findsNothing);
      expect($('Upload'), findsNothing);
    },
  );
}
