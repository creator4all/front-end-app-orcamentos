// Testes Patrol — Domínio NAV (Navegação e permissões)
//
// Cobrem os casos automatizados desta suíte:
//   CT-MOB-NAV-002, NAV-003, NAV-004
//
// Pré-requisitos:
//   - Emulador Android online com o app instalado.
//   - Backend acessível em http://10.0.2.2:8088 (proxy socat).
//   - Credenciais de vendedor e administrador fornecidas via --dart-define.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/user_avatar_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-NAV-002 — Menu de vendedor',
    config: patrolConfig,
    ($) async {
      await startAppClean($);
      // Login como vendedor.
      await $(TextField).at(0).enterText(sellerEmail);
      await $(TextField).at(1).enterText(sellerPassword);
      await $('Acessar').tap();
      await $('Novo Orç.').waitUntilVisible();
      // Abre o menu do perfil.
      await $(UserAvatarWidget).tap();
      await $.pumpAndSettle();
      // Esperado: vendedor vê Editar perfil, Wiki, Drive, Sair, Deletar conta.
      expect($('Editar perfil'), findsOneWidget);
      expect($('Wiki'), findsOneWidget);
      expect($('Drive'), findsOneWidget);
      expect($('Sair'), findsOneWidget);
      expect($('Deletar conta'), findsOneWidget);
      // Vendedor não deve ver opções de admin.
      expect($('Editar empresa'), findsNothing);
      expect($('Configurar produtos'), findsNothing);
      expect($('Prospecção de parceiros'), findsNothing);
      expect($('Gestão administrativa'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-NAV-004 — Menu de administrador',
    config: patrolConfig,
    ($) async {
      await startAppClean($);
      // Login como administrador.
      await $(TextField).at(0).enterText(adminEmail);
      await $(TextField).at(1).enterText(adminPassword);
      await $('Acessar').tap();
      await $('Novo Orç.').waitUntilVisible();
      // Abre o menu do perfil.
      await $(UserAvatarWidget).tap();
      await $.pumpAndSettle();
      // Esperado: admin vê Editar perfil, Editar empresa, Configurar produtos,
      // Prospecção, Gestão administrativa, Wiki, Drive.
      expect($('Editar perfil'), findsOneWidget);
      expect($('Editar empresa'), findsOneWidget);
      expect($('Configurar produtos'), findsOneWidget);
      expect($('Prospecção de parceiros'), findsOneWidget);
      expect($('Gestão administrativa'), findsOneWidget);
      expect($('Wiki'), findsOneWidget);
      expect($('Drive'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NAV-003 — Menu de gestor',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('manager');
        await login($, email: fixture.email, password: mobileFixturePassword);
        await openProfileMenu($);

        expect($('Editar perfil'), findsOneWidget);
        expect($('Editar empresa'), findsOneWidget);
        expect($('Gestão administrativa'), findsOneWidget);
        expect($('Wiki'), findsOneWidget);
        expect($('Drive'), findsOneWidget);
        expect($('Sair'), findsOneWidget);
        expect($('Deletar conta'), findsOneWidget);
        expect($('Configurar produtos'), findsNothing);
        expect($('Prospecção de parceiros'), findsNothing);
        expect($('Relatórios'), findsNothing);
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );
}
