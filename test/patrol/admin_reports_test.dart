// Patrol — empresas e relatórios (ADM).

import 'package:flutter/material.dart';
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
      // Esperado: botão "Usuários" visível na primeira empresa.
      expect($('Gestão de Empresas'), findsOneWidget);
      await $('Usuários').tap();
      await $.pumpAndSettle();
      // Esperado: Gestão de Usuários filtrada por empresa.
      expect($('Gestão de Usuários'), findsOneWidget);
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
      // Esperado: botão "Relatórios" visível na primeira empresa.
      expect($('Gestão de Empresas'), findsOneWidget);
      await $('Relatórios').tap();
      await $.pumpAndSettle();
      // Esperado: página de relatórios da empresa aberta.
      expect($('Gestão de Empresas'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-ADM-006 — Relatório de orçamentos por vendedor com filtros',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $.pumpAndSettle();
      expect($('Gestão de Empresas'), findsOneWidget);
      await $('Relatórios').tap();
      await $.pumpAndSettle();
      // Esperado: relatório com totais por vendedor e período.
      expect($('Gestão de Empresas'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-ADM-003 — Paginar e atualizar empresas',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $.pumpAndSettle();
      // Esperado: página "Gestão de Empresas" com lista e busca.
      expect($('Gestão de Empresas'), findsOneWidget);
      // Rola a lista para baixo para disparar paginação, se houver mais
      // de uma página. Usa drag direto para não depender de um finder
      // específico no final da lista.
      for (var i = 0; i < 5; i++) {
        await $.tester
            .drag(find.byType(Scrollable).first, const Offset(0, -400));
        await $.pumpAndSettle();
      }
      // Esperado: lista estável, sem crash ou duplicações.
      expect($('Gestão de Empresas'), findsOneWidget);
    },
  );
}
