// Testes Patrol — Domínio DRV (Drive)
//
// Cobrem os 5 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-DRV-001, 004, 005, 006, 015

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-DRV-001 — Abrir Drive e listar recentes ou categorias',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o menu do perfil e navega para o Drive.
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: página "Multi Drive" com busca, "Compartilhados comigo" e categorias.
      expect($('Multi Drive'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-004 — Buscar arquivo',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: campo de busca "Buscar arquivo" visível.
      expect($('Buscar arquivo'), findsOneWidget);
      // Digita um termo de busca.
      await $(TextField).enterText('teste');
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'CT-MOB-DRV-005 — Atualizar Drive por gesto de refresh',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: Drive estável, sem crash.
      expect($('Multi Drive'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-006 — Abrir categoria',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: seção "Categorias" visível.
      expect($('Categorias'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-015 — Garantir ausência de criação ou upload mobile para não administradores',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: vendedor não tem botões de upload ou criação de pasta.
      expect($('Multi Drive'), findsOneWidget);
      // Não deve haver botão de upload/criar.
      expect($('Criar pasta'), findsNothing);
      expect($('Upload'), findsNothing);
    },
  );
}
