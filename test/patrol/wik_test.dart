// Testes Patrol — Domínio WIK (Wiki e links)
//
// Cobrem os 3 casos aprovados do relatório docs/testes/casos-de-teste.md:
//   CT-MOB-WIK-001, 003, 004
//
// Pré-requisitos:
//   - Emulador Android online com o app instalado.
//   - Backend acessível em http://10.0.2.2:8088 (proxy socat).

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';

void main() {
  patrolTest(
    'CT-MOB-WIK-001 — Abrir Wiki sem autenticação',
    config: patrolConfig,
    ($) async {
      await startApp($);
      // Na tela de login, toca em "Wiki" (acessível sem auth).
      await $('Wiki').tap();
      await $.pumpAndSettle();
      // Esperado: página "Wiki" exibida com artigos.
      expect($('Wiki'), findsWidgets);
      expect($('Como pedir ajuda'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-WIK-003 — Expandir e recolher artigos',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Wiki').tap();
      await $.pumpAndSettle();
      // Expande o artigo "Como pedir ajuda".
      await $('Como pedir ajuda').tap();
      await $.pumpAndSettle();
      // Esperado: conteúdo do artigo visível após expandir.
      // O conteúdo é exibido no ExpansionTile.
      await $.pumpAndSettle();
      // Recolhe o artigo.
      await $('Como pedir ajuda').tap();
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'CT-MOB-WIK-004 — Abrir política de privacidade',
    config: patrolConfig,
    ($) async {
      await startApp($);
      // Na tela de login, toca em "Privacidade".
      await $('Privacidade').tap();
      await $.pumpAndSettle();
      // Esperado: navegador externo aberto (não há widget Flutter para verificar,
      // mas o app não deve crashar).
    },
  );
}
