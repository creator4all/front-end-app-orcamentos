// Helpers compartilhados para testes Patrol.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multimidiaapp/app/shared/widgets/user_avatar_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';

/// Realiza login com as credenciais fornecidas e aguarda a tela autenticada.
Future<void> login(
  PatrolIntegrationTester $, {
  required String email,
  required String password,
}) async {
  await startAppClean($);
  await $(TextField).at(0).enterText(email);
  await $(TextField).at(1).enterText(password);
  await $('Acessar').tap();
  await $('Novo Orç.').waitUntilVisible();
}

/// Realiza login como vendedor ativo.
Future<void> loginAsSeller(PatrolIntegrationTester $) async {
  await login($, email: sellerEmail, password: sellerPassword);
}

/// Realiza login como administrador.
Future<void> loginAsAdmin(PatrolIntegrationTester $) async {
  await login($, email: adminEmail, password: adminPassword);
}

/// Abre o menu do perfil tocando no avatar do usuário.
Future<void> openProfileMenu(PatrolIntegrationTester $) async {
  await $(UserAvatarWidget).tap();
  await $.pumpAndSettle();
}

final class MobileFixture {
  const MobileFixture({required this.id, required this.email});

  final int id;
  final String email;

  factory MobileFixture.fromResponse(Map<String, dynamic> response) {
    final data = response['dados'] as Map<String, dynamic>;
    return MobileFixture(
      id: (data['fixture_id'] as num).toInt(),
      email: data['email'] as String,
    );
  }
}

Future<MobileFixture> createMobileFixture(String scenario) async {
  _requireFixtureApiKey();
  if (mobileFixturePassword.isEmpty) {
    throw StateError(
        'Informe PATROL_MOBILE_FIXTURE_PASSWORD via --dart-define.');
  }
  final response = await _fixtureRequest(
    'POST',
    '/users',
    body: {
      'scenario': scenario,
      'source_user_id': mobileFixtureSourceUserId,
    },
  );
  return MobileFixture.fromResponse(response);
}

Future<void> expireMobileFixtureSession(int fixtureId) async {
  _requireFixtureApiKey();
  await _fixtureRequest('POST', '/users/$fixtureId/expire_session');
}

Future<void> deleteMobileFixture(int fixtureId) async {
  _requireFixtureApiKey();
  await _fixtureRequest('DELETE', '/users/$fixtureId');
}

Future<Map<String, dynamic>> _fixtureRequest(
  String method,
  String path, {
  Map<String, dynamic>? body,
}) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(
      method,
      Uri.parse('$mobileFixtureApiUrl$path'),
    );
    request.headers.set('X-Mobile-Fixture-Key', mobileFixtureApiKey);
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Fixture API retornou HTTP ${response.statusCode}.');
    }
    return jsonDecode(responseBody) as Map<String, dynamic>;
  } finally {
    client.close(force: true);
  }
}

void _requireFixtureApiKey() {
  if (mobileFixtureApiKey.isEmpty) {
    throw StateError(
        'Informe PATROL_MOBILE_FIXTURE_API_KEY via --dart-define.');
  }
}
