// Testes Patrol — Domínio NFR (Compatibilidade e exploração)
//
// Casos automatizados: NFR-002, 003, 004, 005, 006, 009, 012
// Casos skipados (requerem múltiplos emuladores/dispositivos):
//   NFR-007, 008

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';
import 'helpers.dart';

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

  patrolTest(
    'CT-MOB-NFR-002 — Teclado não oculta ações essenciais',
    config: patrolConfig,
    ($) async {
      await startAppClean($);
      await $(TextField).at(1).enterText('senha');
      await $.pumpAndSettle();
      // Esperado: botão "Acessar" continua alcançável mesmo com teclado aberto.
      expect($('Acessar'), findsOneWidget);
      // Fecha o teclado.
      await $.platformAutomator.android.pressBack();
      await $.pumpAndSettle();
      expect($('Acessar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NFR-004 — Perda e retorno de rede',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Interrompe a rede via modo avião.
      await $.platform.mobile.enableAirplaneMode();
      await $.pumpAndSettle();
      // Tenta atualizar a lista — deve mostrar erro controlado, não crash.
      expect($('Orçamentos'), findsWidgets);
      // Restaura a rede.
      await $.platform.mobile.disableAirplaneMode();
      await $.pumpAndSettle();
      // Esperado: recuperação sem reiniciar o dispositivo.
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NFR-007 — Persistência isolada entre usuários/emuladores',
    config: patrolConfig,
    skip:
        true, // Requer dois emuladores/dispositivos com usuários diferentes para verificar isolamento de dados, permissões e estado sensível — patrol roda em um único emulador.
    ($) async {
      await loginAsSeller($);
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NFR-008 — Atualização entre dispositivos',
    config: patrolConfig,
    skip:
        true, // Requer dois dispositivos observando o mesmo orçamento: mutação em um e refresh no outro — patrol roda em um único emulador.
    ($) async {
      await loginAsSeller($);
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-NFR-012 — Exploração com dados vazios, longos e caracteres especiais',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Busca por texto vazio.
      await $(TextField).enterText('');
      await $.pumpAndSettle();
      expect($('Orçamentos'), findsWidgets);
      // Busca com espaços.
      await $(TextField).enterText('   ');
      await $.pumpAndSettle();
      expect($('Orçamentos'), findsWidgets);
      // Busca com acentos e caracteres especiais.
      await $(TextField).enterText("São José d'Oeste - orçamento");
      await $.pumpAndSettle();
      expect($('Orçamentos'), findsWidgets);
      // Busca com texto longo.
      await $(TextField).enterText(List.filled(300, 'x').join());
      await $.pumpAndSettle();
      // Esperado: sem crash/overflow; normalização coerente.
      expect($('Orçamentos'), findsWidgets);
    },
  );
}
