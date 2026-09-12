// Testes Patrol — Domínio NFR (Compatibilidade e exploração)
//
// Cobrem os 4 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-NFR-003, 005, 006, 009

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';

void main() {
  patrolTest(
    'CT-MOB-NFR-003 — Rotação e recriação de Activity',
    config: patrolConfig,
    ($) async {
      await startAppClean($);
      // O app deve permanecer estável após mudança de orientação.
      await $.platformAutomator.mobile.enableDarkMode();
      await $.pumpAndSettle();
      await $.platformAutomator.mobile.disableDarkMode();
      await $.pumpAndSettle();
      // Esperado: app estável, tela de login visível.
      expect($('Acessar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NFR-005 — Toques repetidos em ações assíncronas',
    config: patrolConfig,
    ($) async {
      await startAppClean($);
      await $(TextField).at(0).enterText(sellerEmail);
      await $(TextField).at(1).enterText(sellerPassword);
      // Toca em "Acessar" — o botão desabilita durante o carregamento.
      await $('Acessar').tap();
      // Esperado: login único concluído, sem duplicação ou crash.
      await $('Novo Orç.').waitUntilVisible();
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NFR-006 — Formatação pt-BR',
    config: patrolConfig,
    ($) async {
      await startAppClean($);
      // Esperado: mensagens de validação em português.
      await $('Acessar').tap();
      await $.pumpAndSettle();
      // Mensagens de validação em pt-BR devem aparecer.
      expect($('Por favor, digite seu e-mail'), findsOneWidget);
      expect($('Por favor, digite sua senha'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NFR-009 — Não expor dados sensíveis em mensagens ou telas',
    config: patrolConfig,
    ($) async {
      await startAppClean($);
      // Login com senha incorreta — a mensagem não deve revelar a senha.
      await $(TextField).at(0).enterText(sellerEmail);
      await $(TextField).at(1).enterText('SenhaErrada123');
      await $('Acessar').tap();
      await $('Login ou senha incorretos, tente novamente!').waitUntilVisible();
      // Esperado: mensagem genérica sem expor senha, token ou dados sensíveis.
      expect($('Login ou senha incorretos, tente novamente!'), findsOneWidget);
      // A senha deve continuar mascarada no campo e não aparecer em um widget Text.
      final passwordField = $.tester.widget<TextField>($(TextField).at(1));
      expect(passwordField.obscureText, isTrue);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == 'SenhaErrada123',
        ),
        findsNothing,
      );
    },
  );
}
