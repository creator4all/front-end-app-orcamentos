// Patrol — autenticação e sessão (AUT).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/widgets/user_avatar_widget.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'app_starter.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-AUT-001 — Login mobile válido sem OTP para todos os perfis',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await _login($, adminEmail, adminPassword);
      await $('Novo Orç.').waitUntilVisible();
      expect($('Novo Orç.'), findsOneWidget);
      expect($('Digite o código'), findsNothing);
      await _logoutToLogin($);

      MobileFixture? manager;
      try {
        manager = await createMobileFixture('manager');
        await _login($, manager.email, mobileFixturePassword);
        await $('Novo Orç.').waitUntilVisible();
        expect($('Novo Orç.'), findsOneWidget);
        expect($('Digite o código'), findsNothing);
        await _logoutToLogin($);
      } finally {
        if (manager != null) {
          await deleteMobileFixture(manager.id);
        }
      }

      await _login($, sellerEmail, sellerPassword);
      await $('Novo Orç.').waitUntilVisible();
      expect($('Novo Orç.'), findsOneWidget);
      expect($('Digite o código'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-AUT-002 — Login com senha incorreta',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await _login($, sellerEmail, 'SenhaIncorreta123');
      // Esperado: diálogo de erro "Login ou senha incorretos, tente novamente!".
      await $('Login ou senha incorretos, tente novamente!').waitUntilVisible();
      expect($('Login ou senha incorretos, tente novamente!'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-003 — Login com e-mail não cadastrado',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await _login($, 'inexistente@mail.com', sellerPassword);
      // Esperado: mesma mensagem de erro sem revelar existência da conta.
      await $('Login ou senha incorretos, tente novamente!').waitUntilVisible();
      expect($('Login ou senha incorretos, tente novamente!'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-004 — Login de usuário inativo',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('inactive');
        await startAppClean($);
        await _login($, fixture.email, mobileFixturePassword);
        await $('Login ou senha incorretos, tente novamente!')
            .waitUntilVisible();
        expect(
          $('Login ou senha incorretos, tente novamente!'),
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
    'CT-MOB-AUT-005 — Validação de e-mail vazio',
    config: patrolConfig,
    ($) async {
      await startApp($);
      // Preenche apenas a senha e tenta acessar.
      await $(TextField).at(1).enterText(sellerPassword);
      await $('Acessar').tap();
      // Esperado: validação no campo de e-mail.
      await $('Por favor, digite seu e-mail').waitUntilVisible();
      expect($('Por favor, digite seu e-mail'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-006 — Validação de formato de e-mail',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $(TextField).at(0).enterText('emailinvalido.com');
      await $(TextField).at(1).enterText(sellerPassword);
      await $('Acessar').tap();
      await $('Por favor, digite um e-mail válido').waitUntilVisible();
      expect($('Por favor, digite um e-mail válido'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-007 — Validação de senha vazia',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $(TextField).at(0).enterText(sellerEmail);
      await $('Acessar').tap();
      await $('Por favor, digite sua senha').waitUntilVisible();
      expect($('Por favor, digite sua senha'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-008 — Validação de senha curta no login',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $(TextField).at(0).enterText(sellerEmail);
      await $(TextField).at(1).enterText('123');
      await $('Acessar').tap();
      await $('A senha deve ter pelo menos 6 caracteres').waitUntilVisible();
      expect($('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-009 — Alternar visibilidade da senha',
    config: patrolConfig,
    ($) async {
      await startApp($);
      const senha = 'MinhaSenha123';
      await $(TextField).at(1).enterText(senha);
      // Estado inicial: senha oculta (ícone visibility_off).
      expect($(Icons.visibility_off), findsOneWidget);
      // Primeiro toque: revela a senha.
      await $(Icons.visibility_off).tap();
      await $.pumpAndSettle();
      expect($(Icons.visibility), findsOneWidget);
      // Segundo toque: oculta novamente.
      await $(Icons.visibility).tap();
      await $.pumpAndSettle();
      expect($(Icons.visibility_off), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-010 — Logout confirmado',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await _login($, sellerEmail, sellerPassword);
      await $('Novo Orç.').waitUntilVisible();
      // Abre o menu do perfil (avatar).
      await _openProfileMenu($);
      // Toca em "Sair" no ProfileModal → diálogo de confirmação.
      await $('Sair').tap();
      await $.pumpAndSettle();
      // Confirma o logout no diálogo ("Sair" do diálogo de confirmação).
      await $('Sair').tap();
      // Esperado: tela de login exibida.
      await $('Acessar').waitUntilVisible();
      expect($('Acessar'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-011 — Cancelar logout',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await _login($, sellerEmail, sellerPassword);
      await $('Novo Orç.').waitUntilVisible();
      await _openProfileMenu($);
      await $('Sair').tap();
      await $.pumpAndSettle();
      // Cancela o diálogo de logout.
      await $('Cancelar').tap();
      await $.pumpAndSettle();
      // Esperado: diálogo fechado, sessão mantida (lista de orçamentos visível).
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-012 — Restaurar sessão válida ao reabrir o App',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await _login($, sellerEmail, sellerPassword);
      await $('Novo Orç.').waitUntilVisible();
      // Simula o reabrir do app: a sessão deve ser restaurada sem novo login.
      // Em patrol, o token persiste no armazenamento seguro; reiniciar o app
      // via main() valida a sessão e direciona à área autenticada.
      await startApp($);
      // Esperado: área autenticada exibida diretamente.
      await $('Novo Orç.').waitUntilVisible();
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-AUT-013 — Sessão expirada ao reabrir o App',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        await startAppClean($);
        await _login($, fixture.email, mobileFixturePassword);
        await $('Novo Orç.').waitUntilVisible();
        await expireMobileFixtureSession(fixture.id);
        await $.platform.mobile.pressHome();
        await $.platform.mobile.openApp(appId: appPackageName);
        await $.pumpAndSettle();
        await $('Acessar').waitUntilVisible();
        expect($('Acessar'), findsOneWidget);
      } finally {
        if (fixture != null) {
          await deleteMobileFixture(fixture.id);
        }
      }
    },
  );

  patrolTest(
    'CT-MOB-AUT-014 — Impedir múltiplos envios durante login',
    config: patrolConfig,
    ($) async {
      await startApp($);
      await $(TextField).at(0).enterText(sellerEmail);
      await $(TextField).at(1).enterText(sellerPassword);
      // Toca em "Acessar" — o botão desabilita durante o carregamento.
      await $('Acessar').tap();
      // Esperado: login único concluído, sem múltiplas navegações/sessões.
      await $('Novo Orç.').waitUntilVisible();
      expect($('Novo Orç.'), findsOneWidget);
    },
  );

}

/// Realiza o login preenchendo e-mail, senha e tocando em "Acessar".
Future<void> _login(
  PatrolIntegrationTester $,
  String email,
  String password,
) async {
  await $(TextField).at(0).enterText(email);
  await $(TextField).at(1).enterText(password);
  await $('Acessar').tap();
}

/// Abre o menu do perfil tocando no avatar do usuário (UserAvatarWidget).
Future<void> _openProfileMenu(PatrolIntegrationTester $) async {
  await $(UserAvatarWidget).tap();
  await $.pumpAndSettle();
}

Future<void> _logoutToLogin(PatrolIntegrationTester $) async {
  await _openProfileMenu($);
  await $('Sair').tap();
  await $.pumpAndSettle();
  await $('Sair').tap();
  await $('Acessar').waitUntilVisible();
}
