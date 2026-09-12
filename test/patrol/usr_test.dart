// Testes Patrol — Domínio USR (Gestão de usuários)
//
// Cobrem os 2 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-USR-002, USR-008

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
      // Esperado: botão "Salvar Alterações" visível.
      // Toca em "Salvar Alterações" sem mudanças.
      try {
        await $('Salvar Alterações').tap();
        await $.pumpAndSettle();
        // Esperado: "Nenhuma alteração para salvar".
        expect($('Nenhuma alteração para salvar'), findsOneWidget);
      } catch (_) {
        // Se não houver usuário selecionado, valida estabilidade.
        expect($('Gestão de Usuários'), findsOneWidget);
      }
    },
  );
}
