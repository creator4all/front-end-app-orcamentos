// Testes Patrol — Domínio REG (Cadastro e solicitação de parceria)
//
// Cobrem os 10 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-REG-001, 002, 003, 004, 005, 006, 007, 008, 009, 013
//
// Pré-requisitos:
//   - Emulador Android online com o app instalado.
//   - Backend acessível em http://10.0.2.2:8088 (proxy socat).
//   - Empresa ativa cadastrada: Apple (CNPJ 32.348.769/0001-91).
//   - Limpar dados do app antes da suíte:
//       adb shell pm clear br.com.multimidiaeducacional.parceiro

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';

void main() {
  patrolTest(
    'CT-MOB-REG-001 — Abrir cadastro pelo login',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      // Esperado: tela "Cadastro" com busca por CPF/CNPJ e "Quero me tornar um parceiro".
      expect($('Cadastro'), findsOneWidget);
      expect($('Quero me tornar um parceiro'), findsOneWidget);
      expect($('Próximo'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-REG-002 — Formatar CPF durante digitação',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('12345678901');
      await $.pumpAndSettle();
      // Esperado: máscara CPF aplicada "123.456.789-01".
      final campo = $.tester.widget<TextField>($(TextField));
      expect(campo.controller?.text, '123.456.789-01');
    },
  );

  patrolTest(
    'CT-MOB-REG-003 — Formatar CNPJ durante digitação',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('32348769000191');
      await $.pumpAndSettle();
      // Esperado: máscara CNPJ aplicada "32.348.769/0001-91".
      final campo = $.tester.widget<TextField>($(TextField));
      expect(campo.controller?.text, '32.348.769/0001-91');
    },
  );

  patrolTest(
    'CT-MOB-REG-004 — Rejeitar CPF ou CNPJ matematicamente inválido',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('11111111111');
      await $.pumpAndSettle();
      await $('Próximo').tap();
      // Esperado: "O CPF informado não é válido. Por favor, verifique os números digitados."
      await $(
        'O CPF informado não é válido. Por favor, verifique os números digitados.',
      ).waitUntilVisible();
      expect(
        $(
          'O CPF informado não é válido. Por favor, verifique os números digitados.',
        ),
        findsOneWidget,
      );
    },
  );

  patrolTest(
    'CT-MOB-REG-005 — Localizar empresa ativa por CNPJ',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('32348769000191');
      await $.pumpAndSettle();
      await $('Próximo').tap();
      // Esperado: diálogo "A empresa Apple está correta?" com Sim/Não.
      await $('A empresa Apple está correta?').waitUntilVisible();
      expect($('A empresa Apple está correta?'), findsOneWidget);
      expect($('Sim'), findsOneWidget);
      expect($('Não'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-REG-006 — Recusar empresa encontrada',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('32348769000191');
      await $.pumpAndSettle();
      await $('Próximo').tap();
      await $('A empresa Apple está correta?').waitUntilVisible();
      await $('Não').tap();
      await $.pumpAndSettle();
      // Esperado: diálogo fechado, campo de documento limpo.
      expect($('A empresa Apple está correta?'), findsNothing);
      final campo = $.tester.widget<TextField>($(TextField));
      expect(campo.controller?.text, isEmpty);
    },
  );

  patrolTest(
    'CT-MOB-REG-007 — Confirmar empresa encontrada',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('32348769000191');
      await $.pumpAndSettle();
      await $('Próximo').tap();
      await $('A empresa Apple está correta?').waitUntilVisible();
      await $('Sim').tap();
      await $.pumpAndSettle();
      // Esperado: formulário de cadastro com empresa vinculada
      // (campos de e-mail/nome/telefone/senha e botão "Cadastrar").
      expect($('Informe seu nome'), findsOneWidget);
      expect($('Cadastrar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-REG-008 — Empresa não encontrada ou inativa',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('99999999000191');
      await $.pumpAndSettle();
      await $('Próximo').tap();
      // Esperado: "Documento não encontrado" + mensagem + botões "Voltar"/"Ser parceiro".
      await $('Documento não encontrado').waitUntilVisible();
      expect($('Documento não encontrado'), findsOneWidget);
      expect(
        $('O documento informado não foi encontrado em nossa base de dados.'),
        findsOneWidget,
      );
      expect($('Voltar'), findsOneWidget);
      expect($('Ser parceiro'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-REG-009 — Validar campos obrigatórios do autocadastro',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('32348769000191');
      await $.pumpAndSettle();
      await $('Próximo').tap();
      await $('A empresa Apple está correta?').waitUntilVisible();
      await $('Sim').tap();
      await $.pumpAndSettle();
      // Rola até o botão "Cadastrar" no final do formulário de autocadastro.
      await $.scrollUntilVisible(finder: $('Cadastrar'));
      // Toca em "Cadastrar" com todos os campos vazios.
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      // Esperado: 6 mensagens de validação exibidas
      // (e-mail, confirmar e-mail, nome, telefone, senha, confirmar senha).
      expect($('Por favor, digite seu e-mail'), findsOneWidget);
      expect($('Por favor, confirme seu e-mail'), findsOneWidget);
      expect($('Por favor, digite seu nome'), findsOneWidget);
      expect($('Por favor, digite seu telefone'), findsOneWidget);
      expect($('Por favor, digite sua senha'), findsOneWidget);
      expect($('Por favor, confirme sua senha'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-REG-013 — Abrir formulário Quero me tornar um parceiro',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $('Quero me tornar um parceiro').tap();
      await $.pumpAndSettle();
      // Esperado: tela "Seja parceiro" com vídeo e formulário.
      expect($('Seja parceiro'), findsOneWidget);
      expect($('Seja nosso parceiro!'), findsOneWidget);
    },
  );
}
