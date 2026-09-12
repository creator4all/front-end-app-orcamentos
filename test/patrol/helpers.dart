// Helpers compartilhados para testes Patrol.
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
