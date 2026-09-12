// Patrol — cadastro e parceria (REG).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';
import 'helpers.dart';

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

  patrolTest(
    'CT-MOB-REG-010 — Rejeitar e-mail duplicado no autocadastro',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        final companyCnpj = fixture.companyCnpj;
        final companyName = fixture.companyName;
        if (companyCnpj == null || companyName == null) {
          throw StateError('O fixture não possui empresa vinculada.');
        }

        await startApp($);
        await $('Cadastrar').tap();
        await $.pumpAndSettle();
        await $(TextField).enterText(companyCnpj);
        await $('Próximo').tap();
        await $('A empresa $companyName está correta?').waitUntilVisible();
        await $('Sim').tap();
        await $.pumpAndSettle();

        final fields = $(TextFormField);
        await fields.at(0).enterText(fixture.email);
        await fields.at(1).enterText(fixture.email);
        await fields.at(2).enterText('Cadastro duplicado');
        await fields.at(3).enterText('11999999999');
        await fields.at(4).enterText('SenhaForte@123');
        await fields.at(5).enterText('SenhaForte@123');
        await $.scrollUntilVisible(finder: $('Cadastrar'));
        await $('Cadastrar').tap();

        await $('Este e-mail já está cadastrado no sistema.')
            .waitUntilVisible();
        expect($('Este e-mail já está cadastrado no sistema.'), findsOneWidget);
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-REG-014 — Validar obrigatórios da solicitação de parceria',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $('Quero me tornar um parceiro').tap();
      await $.pumpAndSettle();
      await $.scrollUntilVisible(finder: $('Quero ser parceiro'));
      await $('Quero ser parceiro').tap();

      await $('Campos obrigatórios').waitUntilVisible();
      expect($('Campos obrigatórios'), findsOneWidget);
      expect($(find.textContaining('• Nome')), findsOneWidget);
      expect($(find.textContaining('• E-mail')), findsOneWidget);
      expect($(find.textContaining('• Telefone')), findsOneWidget);
      expect($(find.textContaining('• Empresa')), findsOneWidget);
      expect($(find.textContaining('• CPF/CNPJ')), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-REG-011 — Concluir autocadastro de vendedor',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        final companyCnpj = fixture.companyCnpj;
        final companyName = fixture.companyName;
        if (companyCnpj == null || companyName == null) {
          throw StateError('O fixture não possui empresa vinculada.');
        }

        // Usa um e-mail novo derivado do fixture para o autocadastro.
        final newEmail =
            'auto_${DateTime.now().millisecondsSinceEpoch}@test.com';

        await startApp($);
        await $('Cadastrar').tap();
        await $.pumpAndSettle();
        await $(TextField).enterText(companyCnpj);
        await $('Próximo').tap();
        await $('A empresa $companyName está correta?').waitUntilVisible();
        await $('Sim').tap();
        await $.pumpAndSettle();

        final fields = $(TextFormField);
        await fields.at(0).enterText(newEmail);
        await fields.at(1).enterText(newEmail);
        await fields.at(2).enterText('Vendedor Teste');
        await fields.at(3).enterText('11999999999');
        await fields.at(4).enterText('SenhaForte@123');
        await fields.at(5).enterText('SenhaForte@123');
        await $.scrollUntilVisible(finder: $('Cadastrar'));
        await $('Cadastrar').tap();

        // Esperado: confirmação de cadastro realizado.
        await $('Cadastro realizado!').waitUntilVisible();
        expect($('Cadastro realizado!'), findsOneWidget);
        expect(
          'Seu cadastro foi realizado com sucesso. Aguarde a ativação pelo gestor da empresa para acessar o sistema.',
          findsOneWidget,
        );
        await $('Ir para Login').tap();
        await $.pumpAndSettle();
        expect($('Acessar'), findsOneWidget);
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-REG-012 — Usuário recém-cadastrado pendente não autentica',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        final companyCnpj = fixture.companyCnpj;
        final companyName = fixture.companyName;
        if (companyCnpj == null || companyName == null) {
          throw StateError('O fixture não possui empresa vinculada.');
        }

        final newEmail =
            'pend_${DateTime.now().millisecondsSinceEpoch}@test.com';

        await startApp($);
        await $('Cadastrar').tap();
        await $.pumpAndSettle();
        await $(TextField).enterText(companyCnpj);
        await $('Próximo').tap();
        await $('A empresa $companyName está correta?').waitUntilVisible();
        await $('Sim').tap();
        await $.pumpAndSettle();

        final fields = $(TextFormField);
        await fields.at(0).enterText(newEmail);
        await fields.at(1).enterText(newEmail);
        await fields.at(2).enterText('Vendedor Pendente');
        await fields.at(3).enterText('11999999999');
        await fields.at(4).enterText('SenhaForte@123');
        await fields.at(5).enterText('SenhaForte@123');
        await $.scrollUntilVisible(finder: $('Cadastrar'));
        await $('Cadastrar').tap();

        await $('Cadastro realizado!').waitUntilVisible();
        await $('Ir para Login').tap();
        await $.pumpAndSettle();

        // Tenta logar com as credenciais recém-cadastradas.
        await $(TextField).at(0).enterText(newEmail);
        await $(TextField).at(1).enterText('SenhaForte@123');
        await $('Acessar').tap();
        // Esperado: login rejeitado enquanto a conta estiver pendente/inativa.
        await $('Login ou senha incorretos, tente novamente!')
            .waitUntilVisible();
        expect(
            $('Login ou senha incorretos, tente novamente!'), findsOneWidget);
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-REG-015 — Enviar solicitação de parceria válida',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Cadastrar').tap();
      await $.pumpAndSettle();
      await $('Quero me tornar um parceiro').tap();
      await $.pumpAndSettle();
      await $.scrollUntilVisible(finder: $('Quero ser parceiro'));

      // Preenche os campos obrigatórios.
      final fields = $(TextFormField);
      await fields.at(0).enterText('Parceiro Teste');
      await fields.at(1).enterText(
          'parceiro_${DateTime.now().millisecondsSinceEpoch}@test.com');
      await fields.at(2).enterText('11999999999');
      await fields.at(3).enterText('Empresa Teste');
      await fields.at(4).enterText('12345678901');

      await $('Quero ser parceiro').tap();

      // Esperado: confirmação de envio sem autenticar.
      await $('Solicitação enviada!').waitUntilVisible();
      expect($('Solicitação enviada!'), findsOneWidget);
      await $('Entendi').tap();
      await $.pumpAndSettle();
      // Esperado: tela de login exibida (não autenticou).
      expect($('Acessar'), findsOneWidget);
    },
  );
}
