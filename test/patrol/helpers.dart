// Helpers compartilhados para testes Patrol.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/user_avatar_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';

/// Preenche o login sem esperar a área autenticada.
Future<void> submitLogin(
  PatrolIntegrationTester $, {
  required String email,
  required String password,
}) async {
  await startAppClean($);
  await $(TextField).at(0).enterText(email);
  await $(TextField).at(1).enterText(password);
  await $('Acessar').tap();
}

Future<void> expectLoginRejected(PatrolIntegrationTester $) async {
  await $('Login ou senha incorretos, tente novamente!').waitUntilVisible();
  expect($('Login ou senha incorretos, tente novamente!'), findsOneWidget);
  expect($('Acessar'), findsOneWidget);
  expect($('Novo Orç.'), findsNothing);
  await tapIfVisible($, 'Entendi');
}

Future<void> searchBudgets(PatrolIntegrationTester $, String query) async {
  final searchField = find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Busca por código ou cidade',
  );
  await $(searchField).waitUntilExists();
  final textField = $.tester.widget<TextField>(searchField);
  final controller = textField.controller;
  if (controller == null) {
    throw StateError('Campo de busca da lista não tem controller.');
  }
  controller.text = query;
  textField.onChanged?.call(query);
  await $.tester.pump();
}

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
  const MobileFixture({
    required this.id,
    required this.email,
    required this.name,
    this.companyName,
    this.companyCnpj,
    this.budgetId,
    this.budgetName,
    this.cityId,
    this.cityName,
    this.stateName,
    this.stateUf,
    this.categoryName,
    this.searchToken,
    this.budgetNamePendente,
    this.budgetNameAprovado,
    this.budgetCount,
    this.budgetNamePrefix,
    this.budgetNameFirst,
    this.budgetNameLast,
    this.cityBId,
    this.cityBName,
    this.stateBName,
    this.stateBUf,
  });

  final int id;
  final String email;
  final String name;
  final String? companyName;
  final String? companyCnpj;
  final int? budgetId;
  final String? budgetName;
  final int? cityId;
  final String? cityName;
  final String? stateName;
  final String? stateUf;
  final String? categoryName;
  final String? searchToken;
  final String? budgetNamePendente;
  final String? budgetNameAprovado;
  final int? budgetCount;
  final String? budgetNamePrefix;
  final String? budgetNameFirst;
  final String? budgetNameLast;
  final int? cityBId;
  final String? cityBName;
  final String? stateBName;
  final String? stateBUf;

  factory MobileFixture.fromResponse(Map<String, dynamic> response) {
    final data = response['dados'] as Map<String, dynamic>;
    return MobileFixture(
      id: (data['fixture_id'] as num).toInt(),
      email: data['email'] as String,
      name: data['name'] as String,
      companyName: data['company_name'] as String?,
      companyCnpj: data['company_cnpj'] as String?,
      budgetId: (data['budget_id'] as num?)?.toInt(),
      budgetName: data['budget_name'] as String?,
      cityId: (data['city_id'] as num?)?.toInt(),
      cityName: data['city_name'] as String?,
      stateName: data['state_name'] as String?,
      stateUf: data['state_uf'] as String?,
      categoryName: data['category_name'] as String?,
      searchToken: data['search_token'] as String?,
      budgetNamePendente: data['budget_name_pendente'] as String?,
      budgetNameAprovado: data['budget_name_aprovado'] as String?,
      budgetCount: (data['budget_count'] as num?)?.toInt(),
      budgetNamePrefix: data['budget_name_prefix'] as String?,
      budgetNameFirst: data['budget_name_first'] as String?,
      budgetNameLast: data['budget_name_last'] as String?,
      cityBId: (data['city_b_id'] as num?)?.toInt(),
      cityBName: data['city_b_name'] as String?,
      stateBName: data['state_b_name'] as String?,
      stateBUf: data['state_b_uf'] as String?,
    );
  }

  String get expectedBudgetName {
    final city = cityName?.trim() ?? '';
    final uf = stateUf?.trim() ?? '';
    if (city.isNotEmpty && uf.isNotEmpty) {
      return '$city - $uf';
    }
    return budgetName ?? city;
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
    body: {'scenario': scenario},
  );
  return MobileFixture.fromResponse(response);
}

Future<void> expireMobileFixtureSession(int fixtureId) async {
  _requireFixtureApiKey();
  await _fixtureRequest('POST', '/users/$fixtureId/expire_session');
}

Future<void> expireMobileFixtureOtp(int fixtureId) async {
  _requireFixtureApiKey();
  await _fixtureRequest('POST', '/users/$fixtureId/expire_otp');
}

Future<void> deleteMobileFixture(int fixtureId) async {
  _requireFixtureApiKey();
  await _fixtureRequest('DELETE', '/users/$fixtureId');
}

Future<String> revealMobileFixtureOtp(int fixtureId) async {
  _requireFixtureApiKey();
  final response = await _fixtureRequest('GET', '/users/$fixtureId/otp');
  final data = response['dados'] as Map<String, dynamic>;
  final code = data['otp_code'] as String?;
  if (code == null || code.length != 6) {
    throw StateError('Fixture API não devolveu OTP de 6 dígitos.');
  }
  return code;
}

Future<Map<String, dynamic>> _fixtureRequest(
  String method,
  String path, {
  Map<String, dynamic>? body,
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client
        .openUrl(
          method,
          Uri.parse('$mobileFixtureApiUrl$path'),
        )
        .timeout(const Duration(seconds: 15));
    request.headers.set('X-Mobile-Fixture-Key', mobileFixtureApiKey);
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close().timeout(const Duration(seconds: 60));
    final responseBody = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 60));
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

Future<void> loginAsFixture(
  PatrolIntegrationTester $,
  MobileFixture fixture,
) async {
  await login($, email: fixture.email, password: mobileFixturePassword);
}

Future<void> logoutToLogin(PatrolIntegrationTester $) async {
  await openProfileMenu($);
  await $('Sair').tap();
  await $.pumpAndSettle();
  await $('Sair').tap();
  await $('Acessar').waitUntilVisible();
}

Future<T> withMobileFixture<T>(
  String scenario,
  Future<T> Function(MobileFixture fixture) body,
) async {
  final fixture = await createMobileFixture(scenario);
  try {
    return await body(fixture);
  } finally {
    await deleteMobileFixture(fixture.id);
  }
}

Future<void> tapIfVisible(PatrolIntegrationTester $, String text) async {
  if ($(text).visible) {
    await $(text).tap();
    await $.pumpAndSettle();
  }
}

Future<void> selectSearchableDropdown(
  PatrolIntegrationTester $, {
  required String hint,
  required String item,
  String searchHint = 'Pesquisar...',
}) async {
  await $(hint).waitUntilVisible();
  await $(hint).tap();
  await $.pumpAndSettle();

  final searchField = find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.hintText == searchHint,
  );
  await $(searchField).waitUntilExists();

  // Patrol enterText unfoca o campo (hideKeyboard). Este dropdown fecha e
  // limpa a busca ao perder o foco, então o item some da árvore.
  final textField = $.tester.widget<TextField>(searchField);
  final controller = textField.controller;
  if (controller == null) {
    throw StateError('Dropdown de "$hint" não tem controller de busca.');
  }
  controller.text = item;
  textField.onChanged?.call(item);
  await $.pumpAndSettle();

  await $(
    find.descendant(
      of: find.byType(ListView),
      matching: find.text(item),
    ),
  ).tap();
  await $.pumpAndSettle();
}

Future<void> dismissInfoDialog(PatrolIntegrationTester $) async {
  await $('Entendi').waitUntilVisible();
  await $('Entendi').tap();
  await $.pumpAndSettle();
}

Future<void> popToBudgetList(PatrolIntegrationTester $) async {
  // Native pressBack sai da Activity do teste e derruba o processo do Patrol.
  await $(Icons.arrow_back).tap();
  await $.pumpAndSettle();
  await $('Novo Orç.').waitUntilVisible();
}

Future<void> fillTextFieldByHint(
  PatrolIntegrationTester $, {
  required String hint,
  required String text,
  int index = 0,
}) async {
  final field = find
      .byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == hint,
      )
      .at(index);
  await $(field).waitUntilExists();
  final textField = $.tester.widget<TextField>(field);
  final controller = textField.controller;
  if (controller == null) {
    throw StateError('Campo "$hint" não tem controller.');
  }
  controller.text = text;
  textField.onChanged?.call(text);
  await $.tester.pump();
}
