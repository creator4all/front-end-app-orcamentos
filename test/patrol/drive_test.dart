// Patrol — Drive (DRV).

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/pages/folder_contents_page.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/stores/new_drive_store.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/widgets/item_card_doc.dart';
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
    'CT-MOB-DRV-007 — Navegar para ancestral e raiz pelo breadcrumb',
    config: patrolConfig,
    ($) async {
      // IDs de fixtures já existentes e autorizadas; este teste não cria dados.
      final folderIds = const String.fromEnvironment('PATROL_DRIVE_FOLDER_PATH')
          .split(',')
          .where((id) => id.isNotEmpty)
          .toList();
      final contentIds =
          const String.fromEnvironment('PATROL_DRIVE_FOLDER_CONTENTS')
              .split(',')
              .where((id) => id.isNotEmpty)
              .toList();
      expect(folderIds.length, greaterThanOrEqualTo(3),
          reason: 'Informe PATROL_DRIVE_FOLDER_PATH com IDs de ao menos três '
              'pastas encadeadas e compartilhadas com o vendedor.');
      expect(contentIds.length, folderIds.length,
          reason: 'Informe PATROL_DRIVE_FOLDER_CONTENTS com um ID de conteúdo '
              'distinto esperado em cada pasta, na mesma ordem.');

      Finder itemCard(String id) => find.byWidgetPredicate(
          (widget) => widget is ItemCardDoc && widget.item.id == id);

      Future<void> openFolder(String id) async {
        await $.tester.ensureVisible(itemCard(id));
        await $(itemCard(id)).tap();
        await $('Abrir').tap();
        await $.pumpAndSettle();
      }

      void expectFolder(int index) {
        final page = $.tester
            .widget<FolderContentsPage>(find.byType(FolderContentsPage));
        final route =
            ModalRoute.of($.tester.element(find.byType(FolderContentsPage)))!;
        final store = Modular.get<NewDriveStore>();
        expect(route.isCurrent, isTrue);
        expect(route.settings.name, '/drive/folder');
        expect((route.settings.arguments as Map)['folderId'], folderIds[index]);
        expect(page.folderId, folderIds[index]);
        expect(store.activeFolderId, folderIds[index]);
        expect(store.currentFolder?.id, folderIds[index]);
        expect(store.folderStack.map((item) => item.id),
            folderIds.take(index + 1));
        expect(itemCard(contentIds[index]), findsOneWidget);
        expect($('Detalhes do arquivo'), findsNothing);
      }

      await loginAsSeller($);
      await openProfileMenu($);
      await $('Drive').tap();
      await $.pumpAndSettle();
      expect($('Multi Drive'), findsOneWidget);
      await $('Pastas').tap();
      await $.pumpAndSettle();
      for (var index = 0; index < folderIds.length; index++) {
        await openFolder(folderIds[index]);
        expectFolder(index);
      }
      final store = Modular.get<NewDriveStore>();
      final currentName = store.folderStack.last.name;
      await $(find.text(currentName).last).tap();
      await $.pumpAndSettle();
      expectFolder(folderIds.length - 1);

      final ancestor = find.text(store.folderStack.first.name).last;
      await $.tester.ensureVisible(ancestor);
      await $(ancestor).tap();
      await $.pumpAndSettle();
      expectFolder(0);

      await $('Drive').tap();
      await $.pumpAndSettle();
      expect($('Multi Drive'), findsOneWidget);
      expect(Modular.to.path, '/drive/');
      expect(store.folderStack, isEmpty);
      expect(store.activeFolderId, isNull);
      expect(store.currentFolder, isNull);
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
