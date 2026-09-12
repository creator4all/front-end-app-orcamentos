// Patrol — gestão de usuários (USR).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-USR-002 — Buscar usuário',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      // Navega para a gestão de usuários.
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $('Gestão de Empresas').waitUntilVisible();
      await $('Usuários').at(0).tap();
      await $('Gestão de Usuários').waitUntilVisible();
      // Esperado: página "Gestão de Usuários" com busca.
      expect($('Gestão de Usuários'), findsOneWidget);
      // Busca por "Apple".
      await $(TextField).enterText('Apple');
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'CT-MOB-USR-008 — Salvar sem alterações',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Gestão administrativa').tap();
      await $('Gestão de Empresas').waitUntilVisible();
      await $('Usuários').at(0).tap();
      await $('Gestão de Usuários').waitUntilVisible();
      // Esperado: botão "Salvar Alterações" visível na gestão de usuários.
      expect($('Gestão de Usuários'), findsOneWidget);
      // Toca em "Salvar Alterações" sem mudanças.
      await $('Salvar Alterações').tap();
      await $.pumpAndSettle();
      // Esperado: "Nenhuma alteração para salvar".
      expect($('Nenhuma alteração para salvar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-USR-001 — Gestor lista usuários da própria empresa',
    config: patrolConfig,
    ($) async {
      MobileFixture? manager;
      MobileFixture? subordinate;
      try {
        manager = await createMobileFixture('manager');
        subordinate = await createMobileFixture('subordinate');
        await login($, email: manager.email, password: mobileFixturePassword);
        await openProfileMenu($);
        await $('Gestão administrativa').tap();
        await $('Gestão de Usuários').waitUntilVisible();
        await $(find.text(subordinate.name)).waitUntilVisible();
        expect($(find.text(subordinate.name)), findsOneWidget);
        expect($(find.text(subordinate.email)), findsOneWidget);
      } finally {
        if (subordinate != null) {
          await deleteMobileFixture(subordinate.id);
        }
        if (manager != null) {
          await deleteMobileFixture(manager.id);
        }
      }
    },
  );
}
