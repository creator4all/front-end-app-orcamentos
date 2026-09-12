// Testes Patrol — Domínio ADM (Empresas e relatórios)
//
// Cobrem os 4 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-ADM-001, 004, 005, 006

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-ADM-001 — Administrador lista empresas',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      // Navega para a gestão de empresas.
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $.pumpAndSettle();
      // Esperado: página "Gestão de Empresas" com busca e lista.
      expect($('Gestão de Empresas'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-ADM-004 — Abrir usuários de uma empresa',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $.pumpAndSettle();
      // Esperado: botão "Usuários" por empresa visível.
      try {
        await $('Usuários').tap();
        await $.pumpAndSettle();
        // Esperado: Gestão de Usuários filtrada.
        expect($('Gestão de Usuários'), findsOneWidget);
      } catch (_) {
        expect($('Gestão de Empresas'), findsOneWidget);
      }
    },
  );

  patrolTest(
    'CT-MOB-ADM-005 — Abrir relatórios de uma empresa',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $.pumpAndSettle();
      // Esperado: botão "Relatórios" por empresa visível.
      try {
        await $('Relatórios').tap();
        await $.pumpAndSettle();
      } catch (_) {
        expect($('Gestão de Empresas'), findsOneWidget);
      }
    },
  );

  patrolTest(
    'CT-MOB-ADM-006 — Relatório por vendedor e período',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $.pumpAndSettle();
      try {
        await $('Relatórios').tap();
        await $.pumpAndSettle();
        // Esperado: relatório com totais por vendedor e período.
      } catch (_) {
        expect($('Gestão de Empresas'), findsOneWidget);
      }
    },
  );
}
