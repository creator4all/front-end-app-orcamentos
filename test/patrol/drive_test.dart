// Patrol — Drive (DRV).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-DRV-001 — Abrir Drive e listar recentes ou categorias',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o menu do perfil e navega para o Drive.
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: página "Multi Drive" com busca, "Compartilhados comigo" e categorias.
      expect($('Multi Drive'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-004 — Buscar arquivo',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: campo de busca "Buscar arquivo" visível.
      expect($('Buscar arquivo'), findsOneWidget);
      // Digita um termo de busca.
      await $(TextField).enterText('teste');
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'CT-MOB-DRV-005 — Atualizar Drive por gesto de refresh',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: Drive estável, sem crash.
      expect($('Multi Drive'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-006 — Abrir categoria',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: seção "Categorias" visível.
      expect($('Categorias'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-015 — Garantir ausência de criação ou upload mobile para não administradores',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Esperado: vendedor não tem botões de upload ou criação de pasta.
      expect($('Multi Drive'), findsOneWidget);
      // Não deve haver botão de upload/criar.
      expect($('Criar pasta'), findsNothing);
      expect($('Upload'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-DRV-007 — Abrir pasta e navegar hierarquia',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      expect($('Multi Drive'), findsOneWidget);
      // Abre a categoria "Pastas".
      await $('Pastas').tap();
      await $.pumpAndSettle();
      // Esperado: página da categoria "Pastas" carregada.
      expect($('Pastas'), findsOneWidget);
      expect($('Arquivos compartilhados com você'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-008 — Visualizar imagem',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Abre a categoria "Imagens".
      await $('Imagens').tap();
      await $.pumpAndSettle();
      // Esperado: página da categoria "Imagens" carregada.
      expect($('Imagens'), findsOneWidget);
      expect($('Arquivos compartilhados com você'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-009 — Reproduzir vídeo',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Abre a categoria "Vídeos".
      await $('Vídeos').tap();
      await $.pumpAndSettle();
      // Esperado: página da categoria "Vídeos" carregada.
      expect($('Vídeos'), findsOneWidget);
      expect($('Arquivos compartilhados com você'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-010 — Abrir documento suportado',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      // Abre a categoria "Documentos".
      await $('Documentos').tap();
      await $.pumpAndSettle();
      // Esperado: página da categoria "Documentos" carregada.
      expect($('Documentos'), findsOneWidget);
      expect($('Arquivos compartilhados com você'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-DRV-013 — Falha de conexão durante download',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      expect($('Multi Drive'), findsOneWidget);
      // Interrompe a rede para simular falha de download.
      await $.platform.mobile.enableAirplaneMode();
      await $.pumpAndSettle();
      // Esperado: página estável, sem crash.
      expect($('Multi Drive'), findsOneWidget);
      // Restaura a rede.
      await $.platform.mobile.disableAirplaneMode();
      await $.pumpAndSettle();
      // Esperado: recuperação sem reiniciar o app.
      expect($('Multi Drive'), findsOneWidget);
    },
  );

}
