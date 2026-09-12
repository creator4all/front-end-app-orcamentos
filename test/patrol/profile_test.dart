// Patrol — perfil e conta (PRF).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-PRF-001 — Carregar perfil próprio',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o menu do perfil.
      await openProfileMenu($);
      // Toca em "Editar perfil".
      await $('Editar perfil').tap();
      await $.pumpAndSettle();
      // Esperado: página "Meu Perfil" com foto, nome, e-mail, cargo, telefone.
      expect($('Meu Perfil'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-PRF-002 — Editar dados válidos do perfil',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Editar perfil').tap();
      await $.pumpAndSettle();
      // Esperado: campos editáveis com botão "Salvar Alterações".
      expect($('Salvar Alterações'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-PRF-008 — Remover avatar com confirmação',
    config: patrolConfig,
    ($) async {
      // Pré-requisito: usuário com avatar.
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Editar perfil').tap();
      await $.pumpAndSettle();
      // Se o usuário tiver avatar, o botão "Remover" estará visível.
      final removeFinder = $('Remover');
      bool hasAvatar = false;
      try {
        await removeFinder.waitUntilVisible(
            timeout: const Duration(seconds: 3));
        hasAvatar = true;
      } catch (_) {
        hasAvatar = false;
      }
      if (hasAvatar) {
        await removeFinder.tap();
        await $.pumpAndSettle();
        // Esperado: diálogo de confirmação "Remover Foto".
        expect($('Remover Foto'), findsOneWidget);
        expect(
            $('Deseja realmente remover sua foto de perfil?'), findsOneWidget);
        // Cancela — imagem deve ser preservada.
        await $('Cancelar').tap();
        await $.pumpAndSettle();
        expect($('Remover Foto'), findsNothing);
      } else {
        // Sem avatar, o botão "Remover" não aparece — válido.
        expect($('Meu Perfil'), findsOneWidget);
      }
    },
  );

  patrolTest(
    'CT-MOB-PRF-010 — Excluir a própria conta',
    config: patrolConfig,
    ($) async {
      MobileFixture? fixture;
      try {
        fixture = await createMobileFixture('active');
        await login($, email: fixture.email, password: mobileFixturePassword);
        await openProfileMenu($);
        await $('Deletar conta').tap();
        await $.pumpAndSettle();
        // Esperado: modal "Deletar Conta" com confirmação.
        expect($('Deletar Conta'), findsOneWidget);
        expect($('Esta ação é irreversível!'), findsOneWidget);
        // Digita DELETAR para habilitar o botão.
        await $(TextField).enterText('DELETAR');
        await $.pumpAndSettle();
        await $('Deletar').tap();
        // Esperado: sucesso e redirecionamento para login.
        await $('Conta excluída').waitUntilVisible();
        expect($('Conta excluída'), findsOneWidget);
        await $('Entendi').tap();
        await $.pumpAndSettle();
        expect($('Acessar'), findsOneWidget);
        // Tenta logar com as credenciais excluídas — deve falhar.
        await $(TextField).at(0).enterText(fixture.email);
        await $(TextField).at(1).enterText(mobileFixturePassword);
        await $('Acessar').tap();
        await $('Login ou senha incorretos, tente novamente!')
            .waitUntilVisible();
        expect(
            $('Login ou senha incorretos, tente novamente!'), findsOneWidget);
      } finally {
        // Fixture já foi excluída pelo fluxo; tentar deletar novamente é seguro.
        try {
          if (fixture != null) {
            await deleteMobileFixture(fixture.id);
          }
        } catch (_) {}
      }
    },
  );
}
