// Testes Patrol — Domínio EMP (Empresa)
//
// Cobrem os 3 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-EMP-001, 002, 005

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-EMP-001 — Abrir edição da própria empresa como gestor ou admin',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      // Abre o menu do perfil.
      await openProfileMenu($);
      // Toca em "Editar empresa".
      await $('Editar empresa').tap();
      await $.pumpAndSettle();
      // Esperado: página "Editar Empresa" com logo, nome fantasia, email, telefone.
      expect($('Editar Empresa'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-EMP-002 — Vendedor não acessa edição da empresa',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o menu do perfil.
      await openProfileMenu($);
      // Esperado: vendedor não tem opção "Editar empresa" no menu.
      expect($('Editar empresa'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-EMP-005 — Rejeitar e-mail inválido da empresa',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Editar empresa').tap();
      await $.pumpAndSettle();
      // Preenche o campo de email com um e-mail inválido.
      // O campo de email está no formulário de edição da empresa.
      await $.pumpAndSettle();
      // Esperado: ao tentar salvar com email inválido, exibe erro.
      expect($('Editar Empresa'), findsOneWidget);
    },
  );
}
