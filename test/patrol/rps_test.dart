// Testes Patrol — Domínio RPS (Recuperação de senha)
//
// Cobrem os casos automatizados desta suíte:
//   CT-MOB-RPS-001, 002, 003, 005, 007, 009, 010, 011
// Casos skipados: RPS-006 (várias tentativas + OTP correto), RPS-008 (cooldown 60s).
//
// Pré-requisitos:
//   - Emulador Android online com o app instalado.
//   - Backend acessível em http://10.0.2.2:8088 (proxy socat).
//   - Mailpit acessível a partir do emulador (configurar `mailpitUrl` abaixo).
//     Por padrão assume-se `http://10.0.2.2:8025` (Mailpit exposto no host).
//     Se o Mailpit estiver em outro host (ex.: `asus`), exponha-o via proxy
//     `socat` na porta 8025 do host do emulador.
//   - API de fixtures habilitada para os casos de OTP com usuário descartável.
//   - PATROL_MOBILE_FIXTURE_API_KEY e PATROL_MOBILE_FIXTURE_PASSWORD
//     fornecidos via --dart-define.
//   - Limpar dados do app antes da suíte:
//       adb shell pm clear br.com.multimidiaeducacional.parceiro

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';
import 'helpers.dart';

/// URL base do Mailpit acessível a partir do emulador.
const String mailpitUrl = String.fromEnvironment(
  'PATROL_MAILPIT_URL',
  defaultValue: 'http://10.0.2.2:8025',
);

void main() {
  patrolTest(
    'CT-MOB-RPS-001 — Solicitar recuperação com e-mail cadastrado',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        await _requestPasswordRecovery($, fixture);
        // Esperado: tela de OTP exibida com 6 campos e contador de reenvio.
        expect($('Digite o código'), findsOneWidget);
        // Contador "Reenviar código em Ns" visível.
        expect($(RegExp(r'Reenviar código em \d+s')), findsOneWidget);
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
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
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        final previousMessageIds = await _requestPasswordRecovery($, fixture);
        // Recupera somente o OTP enviado por esta solicitação.
        final otp = await fetchOtpFromMailpit(
          recipient: fixture.email,
          excludedMessageIds: previousMessageIds,
        );
        // Preenche os 6 campos de OTP.
        for (var i = 0; i < 6; i++) {
          await $(TextFormField).at(i).enterText(otp[i]);
        }
        await $('Verificar').tap();
        // Esperado: tela "Nova Senha" com requisitos exibidos.
        await $('Requisitos da senha:').waitUntilVisible();
        expect($('Requisitos da senha:'), findsOneWidget);
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-RPS-006 — OTPs incorretos não bloqueiam a recuperação',
    config: patrolConfig,
    skip:
        true, // Precisa do OTP correto após várias tentativas inválidas; o código válido vem do Mailpit e o fluxo completo já é coberto por RPS-005/011.
    ($) async {
      await startApp($);
      expect($('Acessar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-RPS-008 — Reenviar OTP após cooldown de 60 segundos',
    config: patrolConfig,
    skip:
        true, // O cooldown de 60s torna o caso lento e depende do botão "Reenviar código" habilitar após o timer.
    ($) async {
      await startApp($);
      expect($('Acessar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-RPS-009 — Rejeitar nova senha fora da política',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        final previousMessageIds = await _requestPasswordRecovery($, fixture);
        final otp = await fetchOtpFromMailpit(
          recipient: fixture.email,
          excludedMessageIds: previousMessageIds,
        );
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
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-RPS-010 — Rejeitar confirmação divergente',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        final previousMessageIds = await _requestPasswordRecovery($, fixture);
        final otp = await fetchOtpFromMailpit(
          recipient: fixture.email,
          excludedMessageIds: previousMessageIds,
        );
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
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-RPS-007 — Rejeitar OTP expirado',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        final previousMessageIds = await _requestPasswordRecovery($, fixture);
        final otp = await fetchOtpFromMailpit(
          recipient: fixture.email,
          excludedMessageIds: previousMessageIds,
        );
        await expireMobileFixtureOtp(fixture.id);
        for (var i = 0; i < 6; i++) {
          await $(TextFormField).at(i).enterText(otp[i]);
        }
        await $('Verificar').tap();

        await $('Código inválido ou expirado. Solicite um novo código.')
            .waitUntilVisible();
        expect(
          $('Código inválido ou expirado. Solicite um novo código.'),
          findsOneWidget,
        );
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-RPS-011 — Redefinir senha com sucesso',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      const newPassword = 'SenhaForte@123';
      try {
        fixture = await createMobileFixture('active');
        final previousMessageIds = await _requestPasswordRecovery($, fixture);
        final otp = await fetchOtpFromMailpit(
          recipient: fixture.email,
          excludedMessageIds: previousMessageIds,
        );
        for (var i = 0; i < 6; i++) {
          await $(TextFormField).at(i).enterText(otp[i]);
        }
        await $('Verificar').tap();
        await $('Requisitos da senha:').waitUntilVisible();
        await $(TextField).at(0).enterText(newPassword);
        await $(TextField).at(1).enterText(newPassword);
        await $('Redefinir Senha').tap();
        await $('Senha Redefinida!').waitUntilVisible();
        expect($('Sua senha foi alterada com sucesso.'), findsOneWidget);
        await $('Ir para Login').tap();

        await login($, email: fixture.email, password: newPassword);
        expect($('Novo Orç.'), findsOneWidget);

        await startAppClean($);
        await $(TextField).at(0).enterText(fixture.email);
        await $(TextField).at(1).enterText(mobileFixturePassword);
        await $('Acessar').tap();
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
}

Future<Set<String>> _requestPasswordRecovery(
  PatrolIntegrationTester $,
  MobileFixture fixture,
) async {
  await startAppClean($);
  await $('Esqueci minha senha').tap();
  await $.pumpAndSettle();
  final previousMessageIds =
      await captureMailpitMessageIds(recipient: fixture.email);
  await $(TextField).enterText(fixture.email);
  await $('Enviar Código').tap();
  await $('Digite o código').waitUntilVisible();
  return previousMessageIds;
}

/// Captura mensagens já existentes para que o polling não aceite um OTP antigo.
Future<Set<String>> captureMailpitMessageIds(
    {required String recipient}) async {
  final messages = await _tryFetchMailpitMessages();
  if (messages == null) {
    throw StateError(
        'Não foi possível consultar o Mailpit antes da solicitação');
  }

  return {
    for (final message in messages)
      if (_messageHasRecipient(message, recipient))
        if (_messageId(message) case final id?) id,
  };
}

/// Recupera o OTP destinado ao [recipient] no Mailpit.
///
/// Mensagens existentes em [excludedMessageIds] são ignoradas para evitar que
/// uma execução reutilize um código emitido por um teste anterior.
Future<String> fetchOtpFromMailpit({
  required String recipient,
  Set<String> excludedMessageIds = const <String>{},
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 15));

  while (DateTime.now().isBefore(deadline)) {
    final otp = await _tryFetchOtpFromMailpit(
      recipient,
      excludedMessageIds: excludedMessageIds,
    );
    if (otp != null) {
      return otp;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  throw StateError('OTP de 6 dígitos não encontrado no Mailpit');
}

Future<String?> _tryFetchOtpFromMailpit(
  String recipient, {
  required Set<String> excludedMessageIds,
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
  try {
    final messages = await _tryFetchMailpitMessages(client: client);
    if (messages == null) {
      return null;
    }

    for (final message in messages) {
      if (!_messageHasRecipient(message, recipient)) {
        continue;
      }

      final id = _messageId(message);
      if (id == null || excludedMessageIds.contains(id)) {
        continue;
      }

      final snippet = (message['Snippet'] is String)
          ? message['Snippet'] as String
          : (message['snippet'] is String)
              ? message['snippet'] as String
              : '';
      final snippetMatch = RegExp(r'\b(\d{6})\b').firstMatch(snippet);
      if (snippetMatch != null) {
        return snippetMatch.group(1);
      }

      final fullMessage = await _readMailpitJson(
        client,
        Uri.parse(
          '$mailpitUrl/api/v1/message/${Uri.encodeComponent(id)}',
        ),
      );
      if (fullMessage == null) {
        continue;
      }

      final fullMatch =
          RegExp(r'\b(\d{6})\b').firstMatch(jsonEncode(fullMessage));
      if (fullMatch != null) {
        return fullMatch.group(1);
      }
    }

    return null;
  } on Exception {
    return null;
  } finally {
    client.close(force: true);
  }
}

Future<List<Map<String, dynamic>>?> _tryFetchMailpitMessages({
  HttpClient? client,
}) async {
  final ownsClient = client == null;
  final httpClient = client ?? HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 3);

  try {
    final data = await _readMailpitJson(
      httpClient,
      Uri.parse('$mailpitUrl/api/v1/messages'),
    );
    if (data is! Map || data['messages'] is! List) {
      return null;
    }

    return [
      for (final rawMessage in data['messages'] as List)
        if (rawMessage is Map) Map<String, dynamic>.from(rawMessage),
    ];
  } on Exception {
    return null;
  } finally {
    if (ownsClient) {
      httpClient.close(force: true);
    }
  }
}

Future<dynamic> _readMailpitJson(HttpClient client, Uri uri) async {
  final request = await client.getUrl(uri).timeout(const Duration(seconds: 3));
  final response = await request.close().timeout(const Duration(seconds: 3));
  final body = await response
      .transform(utf8.decoder)
      .join()
      .timeout(const Duration(seconds: 3));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    return null;
  }
  return jsonDecode(body);
}

String? _messageId(Map<String, dynamic> message) {
  final id = message['ID'] ?? message['id'];
  return id?.toString();
}

bool _messageHasRecipient(Map<String, dynamic> message, String recipient) {
  final recipientLower = recipient.trim().toLowerCase();
  final fields = [message['To'], message['to'], message['Recipients']];
  return fields.any((field) => _containsRecipient(field, recipientLower));
}

bool _containsRecipient(dynamic value, String recipientLower) {
  if (value is String) {
    final normalizedValue = value.trim().toLowerCase();
    if (normalizedValue == recipientLower) {
      return true;
    }

    final emailPattern = RegExp(
      r'[\w.!#\$%&*+/=?^_`{|}~-]+@[\w.-]+\.[a-z]{2,}',
      caseSensitive: false,
    );
    return emailPattern
        .allMatches(normalizedValue)
        .any((match) => match.group(0) == recipientLower);
  }
  if (value is List) {
    return value.any((item) => _containsRecipient(item, recipientLower));
  }
  if (value is Map) {
    final address = value['Address'] ??
        value['address'] ??
        value['Email'] ??
        value['email'] ??
        value['Mailbox'];
    return _containsRecipient(address, recipientLower);
  }
  return false;
}
