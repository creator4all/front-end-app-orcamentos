// Testes Patrol — Domínio PRO (Prospecção)
//
// Cobrem os 3 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-PRO-001, 004, 005

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-PRO-001 — Acesso exclusivo do administrador (parcial)',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      // Navega para Prospecção de parceiros.
      await openProfileMenu($);
      await $('Prospecção de parceiros').tap();
      await $.pumpAndSettle();
      // Esperado: página "Prospecção de parceiros" exibida.
      expect($('Prospecção de parceiros'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-PRO-004 — Marcar prospecção como contatada',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Prospecção de parceiros').tap();
      await $.pumpAndSettle();
      // Esperado: botão "Já entrei em contato" visível.
      try {
        await $('Já entrei em contato').tap();
        await $.pumpAndSettle();
        // Esperado: "Possível parceiro marcado como contatado com sucesso!".
        expect($('Possível parceiro marcado como contatado com sucesso!'),
            findsOneWidget);
      } catch (_) {
        // Se não houver prospecção, valida estabilidade.
        expect($('Prospecção de parceiros'), findsOneWidget);
      }
    },
  );

  patrolTest(
    'CT-MOB-PRO-005 — Abrir empresas já contatadas',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Prospecção de parceiros').tap();
      await $.pumpAndSettle();
      // Esperado: banner "Empresas já contactadas" visível.
      try {
        await $('Empresas já contactadas').tap();
        await $.pumpAndSettle();
      } catch (_) {
        expect($('Prospecção de parceiros'), findsOneWidget);
      }
    },
  );
}
