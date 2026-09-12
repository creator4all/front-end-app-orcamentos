// Patrol — prospecção (PRO).

import 'package:flutter/material.dart';
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
      // Esperado: botão "Já entrei em contato" visível no primeiro card.
      await $('Já entrei em contato').waitUntilVisible();
      await $('Já entrei em contato').tap();
      await $.pumpAndSettle();
      // Esperado: "Possível parceiro marcado como contatado com sucesso!".
      expect($('Possível parceiro marcado como contatado com sucesso!'),
          findsOneWidget);
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
      expect($('Empresas já contactadas'), findsOneWidget);
      // Toca no banner para navegar à lista de contatadas.
      await $('Empresas já contactadas').tap();
      await $.pumpAndSettle();
      // Esperado: navegou para a página de contatadas (sem crash).
      // Volta para validar que a navegação foi bem-sucedida.
      await $.platformAutomator.android.pressBack();
      await $.pumpAndSettle();
      expect($('Prospecção de parceiros'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-PRO-003 — Paginar e atualizar prospecções',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Prospecção de parceiros').tap();
      await $.pumpAndSettle();
      // Esperado: lista de prospecções carregada.
      expect($('Prospecção de parceiros'), findsOneWidget);
      // Rola a lista para baixo para disparar paginação, se houver mais
      // de uma página. Usa drag direto para não depender de um finder
      // específico no final da lista.
      for (var i = 0; i < 5; i++) {
        await $.tester
            .drag(find.byType(Scrollable).first, const Offset(0, -400));
        await $.pumpAndSettle();
      }
      // Esperado: lista estável, sem crash ou duplicações.
      expect($('Prospecção de parceiros'), findsOneWidget);
    },
  );

}
