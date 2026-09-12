// Testes Patrol — Domínio RPS (Recuperação de senha)
//
// Cobrem os 6 casos aprovados do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-RPS-001, 002, 003, 005, 009, 010
//
// Pré-requisitos:
//   - Emulador Android online com o app instalado.
//   - Backend acessível em http://10.0.2.2:8088 (proxy socat).
//   - Mailpit acessível a partir do emulador (configurar `mailpitUrl` abaixo).
//     Por padrão assume-se `http://10.0.2.2:8025` (Mailpit exposto no host).
//     Se o Mailpit estiver em outro host (ex.: `asus`), exponha-o via proxy
//     `socat` na porta 8025 do host do emulador.
//   - Credenciais de vendedor fornecidas via --dart-define.
//   - Limpar dados do app antes da suíte:
//       adb shell pm clear br.com.multimidiaeducacional.parceiro

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';

/// URL base do Mailpit acessível a partir do emulador.
const String mailpitUrl = 'http://10.0.2.2:8025';

void main() {
  patrolTest(
    'CT-MOB-RPS-001 — Solicitar recuperação com e-mail cadastrado',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Esqueci minha senha').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText(sellerEmail);
      await $('Enviar Código').tap();
      // Esperado: tela de OTP exibida com 6 campos e contador de reenvio.
      await $('Digite o código').waitUntilVisible();
      expect($('Digite o código'), findsOneWidget);
      // Contador "Reenviar código em Ns" visível.
      expect($(RegExp(r'Reenviar código em \d+s')), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-RPS-002 — Solicitar recuperação com e-mail vazio',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Esqueci minha senha').tap();
      await $.pumpAndSettle();
      await $('Enviar Código').tap();
      // Esperado: validação "Por favor, digite seu e-mail".
      await $('Por favor, digite seu e-mail').waitUntilVisible();
      expect($('Por favor, digite seu e-mail'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-RPS-003 — Solicitar recuperação com e-mail inválido',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Esqueci minha senha').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText('emailinvalido.com');
      await $('Enviar Código').tap();
      // Esperado: validação "Por favor, digite um e-mail válido".
      await $('Por favor, digite um e-mail válido').waitUntilVisible();
      expect($('Por favor, digite um e-mail válido'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-RPS-005 — Validar OTP correto',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Esqueci minha senha').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText(sellerEmail);
      await $('Enviar Código').tap();
      await $('Digite o código').waitUntilVisible();
      // Recupera o OTP do Mailpit.
      final otp = await fetchOtpFromMailpit();
      // Preenche os 6 campos de OTP.
      for (var i = 0; i < 6; i++) {
        await $(TextFormField).at(i).enterText(otp[i]);
      }
      await $('Verificar').tap();
      // Esperado: tela "Nova Senha" com requisitos exibidos.
      await $('Requisitos da senha:').waitUntilVisible();
      expect($('Requisitos da senha:'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-RPS-009 — Rejeitar nova senha fora da política',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Esqueci minha senha').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText(sellerEmail);
      await $('Enviar Código').tap();
      await $('Digite o código').waitUntilVisible();
      final otp = await fetchOtpFromMailpit();
      for (var i = 0; i < 6; i++) {
        await $(TextFormField).at(i).enterText(otp[i]);
      }
      await $('Verificar').tap();
      await $('Requisitos da senha:').waitUntilVisible();
      // Senha "123" não atende a política (sem maiúscula, sem especial, <6).
      await $(TextField).at(0).enterText('123');
      await $(TextField).at(1).enterText('123');
      await $.pumpAndSettle();
      // Esperado: requisitos não atendidos permanecem visíveis.
      expect($('Mínimo 6 caracteres'), findsOneWidget);
      expect($('Pelo menos 1 letra maiúscula'), findsOneWidget);
      expect($('Pelo menos 1 caractere especial'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-RPS-010 — Rejeitar confirmação divergente',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $('Esqueci minha senha').tap();
      await $.pumpAndSettle();
      await $(TextField).enterText(sellerEmail);
      await $('Enviar Código').tap();
      await $('Digite o código').waitUntilVisible();
      final otp = await fetchOtpFromMailpit();
      for (var i = 0; i < 6; i++) {
        await $(TextFormField).at(i).enterText(otp[i]);
      }
      await $('Verificar').tap();
      await $('Requisitos da senha:').waitUntilVisible();
      // Senha válida na política, mas confirmação divergente.
      await $(TextField).at(0).enterText('SenhaForte@123');
      await $(TextField).at(1).enterText('SenhaDiferente@456');
      await $.pumpAndSettle();
      // Esperado: "As senhas não conferem" exibida.
      await $('As senhas não conferem').waitUntilVisible();
      expect($('As senhas não conferem'), findsOneWidget);
    },
  );
}

/// Recupera o OTP de 6 dígitos do Mailpit consultando a API REST.
///
/// Consulta a última mensagem recebida e extrai o código de 6 dígitos do
/// corpo do e-mail. Ajuste `mailpitUrl` caso o Mailpit esteja em outro host.
Future<String> fetchOtpFromMailpit() async {
  final client = HttpClient();
  try {
    final request =
        await client.getUrl(Uri.parse('$mailpitUrl/api/v1/messages'));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final messages = data['messages'] as List? ?? [];
    if (messages.isEmpty) {
      throw StateError('Nenhum e-mail encontrado no Mailpit');
    }
    // Busca o conteúdo da última mensagem e extrai o OTP de 6 dígitos.
    final last = messages.first as Map<String, dynamic>;
    final snippet =
        (last['Snippet'] as String?) ?? (last['snippet'] as String?) ?? '';
    final match = RegExp(r'\b(\d{6})\b').firstMatch(snippet);
    if (match == null) {
      // Tenta buscar o corpo completo da mensagem.
      final id = last['ID'] ?? last['id'];
      if (id != null) {
        final fullRequest = await client.getUrl(
          Uri.parse('$mailpitUrl/api/v1/message/$id'),
        );
        final fullResponse = await fullRequest.close();
        final fullBody = await fullResponse.transform(utf8.decoder).join();
        final fullMatch = RegExp(r'\b(\d{6})\b').firstMatch(fullBody);
        if (fullMatch != null) return fullMatch.group(1)!;
      }
      throw StateError('OTP de 6 dígitos não encontrado no e-mail');
    }
    return match.group(1)!;
  } finally {
    client.close();
  }
}
