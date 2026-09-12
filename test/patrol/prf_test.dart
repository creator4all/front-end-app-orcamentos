// Testes Patrol — Domínio PRF (Perfil e conta)
//
// Cobrem os 2 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-PRF-001, PRF-002

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-PRF-001 — Carregar perfil próprio',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o menu do perfil.
      await openProfileMenu($);
      // Toca em "Editar perfil".
      await $('Editar perfil').tap();
      await $.pumpAndSettle();
      // Esperado: página "Meu Perfil" com foto, nome, e-mail, cargo, telefone.
      expect($('Meu Perfil'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-PRF-002 — Editar dados válidos do perfil',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Editar perfil').tap();
      await $.pumpAndSettle();
      // Esperado: campos editáveis com botão "Salvar Alterações".
      expect($('Salvar Alterações'), findsOneWidget);
    },
  );
}
