import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dartz/dartz.dart' show Either, Right;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/entities/drive_item.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/usecases/download_and_open_file_usecase.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/usecases/download_file_to_cache_usecase.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/usecases/download_file_usecase.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/new_drive_failure.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/new_drive_module.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/pages/folder_contents_page.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/pages/new_drive_page.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/stores/file_opener_store.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/stores/new_drive_store.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/widgets/item_card_doc.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../drive_test_fakes.dart';

class _AuthStore extends Fake implements AuthStore {
  @override
  bool get isAdmin => true;
}

class _OpenFile extends Fake implements DownloadAndOpenFileUsecase {}

class _DownloadFile extends Fake implements DownloadFileUsecase {}

class _DownloadCache extends Fake implements DownloadFileToCacheUsecase {}

class _DriveModule extends NewDriveModule {
  final NewDriveStore store;
  _DriveModule(this.store);

  @override
  List<Bind> get binds => [
        Bind.singleton<NewDriveStore>((_) => store),
        Bind.singleton<AuthStore>((_) => _AuthStore()),
        Bind.singleton<FileOpenerStore>((_) =>
            FileOpenerStore(_OpenFile(), _DownloadFile(), _DownloadCache())),
      ];
}

class _AppModule extends Module {
  final NewDriveStore store;
  _AppModule(this.store);

  @override
  List<ModularRoute> get routes => [
        RedirectRoute('/', to: '/drive/'),
        ModuleRoute('/drive', module: _DriveModule(store)),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeDriveRepository repository;
  late NewDriveStore store;
  final screenshotKey = GlobalKey();

  setUpAll(() async {
    // Ahem usa blocos de largura fixa e não representa o layout de texto do app.
    final configFile = File('.dart_tool/package_config.json');
    final packages =
        jsonDecode(await configFile.readAsString())['packages'] as List;
    final flutterPackage =
        packages.firstWhere((item) => item['name'] == 'flutter');
    final flutterRoot = configFile.uri.resolve('${flutterPackage['rootUri']}/');
    final font = File.fromUri(flutterRoot.resolve(
        '../../bin/cache/artifacts/material_fonts/roboto-regular.ttf'));
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.sublistView(await font.readAsBytes())));
    await loader.load();
    final icons = File.fromUri(flutterRoot.resolve(
        '../../bin/cache/artifacts/material_fonts/materialicons-regular.otf'));
    await (FontLoader('MaterialIcons')
          ..addFont(
              Future.value(ByteData.sublistView(await icons.readAsBytes()))))
        .load();
  });

  setUp(() {
    repository = FakeDriveRepository();
    store = repository.createStore();
  });

  Future<void> start(WidgetTester tester, {String? entry}) async {
    tester.view.physicalSize = const Size(500, 690);
    tester.view.devicePixelRatio = 1;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      Modular.destroy();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(ModularApp(
      module: _AppModule(store),
      child: RepaintBoundary(
        key: screenshotKey,
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            routerDelegate: Modular.routerDelegate,
            routeInformationParser: Modular.routeInformationParser,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    if (entry != null) {
      unawaited(Modular.to.pushNamed('/drive/$entry',
          arguments: entry == 'category' ? DriveItemType.folder : null));
      await tester.pumpAndSettle();
    }
  }

  Finder card(String id) => find.byWidgetPredicate(
      (widget) => widget is ItemCardDoc && widget.item.id == id);

  Future<void> open(WidgetTester tester, String id,
      {bool settle = true}) async {
    await tester.ensureVisible(card(id));
    await tester.tap(card(id));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  void expectFolder(WidgetTester tester, String id, List<String> stack) {
    final page =
        tester.widget<FolderContentsPage>(find.byType(FolderContentsPage));
    final route =
        ModalRoute.of(tester.element(find.byType(FolderContentsPage)))!;
    expect(route.isCurrent, isTrue);
    expect(route.settings.name, '/drive/folder');
    expect((route.settings.arguments as Map)['folderId'], id);
    expect(page.folderId, id);
    expect(page.folderName, 'Pasta $id');
    expect(store.activeFolderId, id);
    expect(store.currentFolder?.id, id);
    expect(store.folderStack.map((item) => item.id), stack);
    expect(find.text('Documento $id'), findsOneWidget);
    expect(find.text('Detalhes do arquivo'), findsNothing);
  }

  Future<void> breadcrumb(WidgetTester tester, String label) async {
    final target = find.text(label).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  for (final entry in [null, 'category', 'my-files', 'shared-files']) {
    testWidgets('breadcrumb real, raiz e reentrada via ${entry ?? 'recentes'}',
        (tester) async {
      await start(tester, entry: entry);
      await open(tester, '1');
      await open(tester, '2');
      await open(tester, '3');
      await open(tester, '4');
      expectFolder(tester, '4', ['1', '2', '3', '4']);
      final requests = repository.folderRequests.length;
      await breadcrumb(tester, 'Pasta 4');
      expectFolder(tester, '4', ['1', '2', '3', '4']);
      expect(repository.folderRequests, hasLength(requests));
      await breadcrumb(tester, 'Pasta 3');
      expectFolder(tester, '3', ['1', '2', '3']);
      await open(tester, '4');
      await breadcrumb(tester, 'Pasta 1');
      expectFolder(tester, '1', ['1']);
      expect(
          find.byType(FolderContentsPage, skipOffstage: false), findsOneWidget);
      expect(repository.folderRequests, hasLength(requests));
      final screenshotPath = Platform.environment['DRIVE_TEST_SCREENSHOT'];
      if (entry == null && screenshotPath != null) {
        await tester.runAsync(() async {
          final boundary = screenshotKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(screenshotPath);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await breadcrumb(tester, 'Drive');
      expect(find.byType(NewDrivePage), findsOneWidget);
      expect(Modular.to.path, '/drive/');
      expect(store.folderStack, isEmpty);
      expect(store.folderCache, isEmpty);
      expect(store.activeFolderId, isNull);
      await open(tester, '9');
      expect(
          tester
              .widget<FolderContentsPage>(find.byType(FolderContentsPage))
              .folderId,
          '9');
      expect(store.folderStack.map((item) => item.id), ['9']);
      expect(find.text('Pasta vazia'), findsOneWidget);
      expect(find.text('Documento 1'), findsNothing);
    });
  }

  testWidgets('cabeçalho e sistema após breadcrumb removem apenas uma pasta',
      (tester) async {
    await start(tester, entry: 'category');
    for (final id in ['1', '2', '3', '4']) {
      await open(tester, id);
    }
    await breadcrumb(tester, 'Pasta 3');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expectFolder(tester, '2', ['1', '2']);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expectFolder(tester, '1', ['1']);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(Modular.to.path, '/drive/category');
    expect(store.folderStack, isEmpty);
    expect(store.currentFolder, isNull);
  });

  testWidgets('entrada em pasta interna não inventa páginas ancestrais',
      (tester) async {
    repository.entryItems = [repository.folders['3']!];
    await start(tester, entry: 'shared-files');
    await open(tester, '3');
    await open(tester, '4');
    await breadcrumb(tester, 'Pasta 3');
    expectFolder(tester, '3', ['3']);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(Modular.to.path, '/drive/shared-files');
    expect(store.activeFolderId, isNull);
  });

  testWidgets(
      'toques repetidos no ancestral fecham somente as páginas do filho',
      (tester) async {
    await start(tester, entry: 'shared-files');
    for (final id in ['1', '2', '3']) {
      await open(tester, id);
    }
    final tap = tester
        .widget<GestureDetector>(find
            .ancestor(
              of: find.text('Pasta 1'),
              matching: find.byType(GestureDetector),
            )
            .first)
        .onTap!;
    tap();
    tap();
    await tester.pumpAndSettle();
    expectFolder(tester, '1', ['1']);
    expect(
        find.byType(FolderContentsPage, skipOffstage: false), findsOneWidget);
  });

  testWidgets(
      'resposta tardia e toques repetidos não restauram filho abandonado',
      (tester) async {
    await start(tester);
    await open(tester, '1');
    final response = Completer<Either<NewDriveFailure, DriveItem>>();
    repository.pending['2'] = response;
    await open(tester, '2', settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final back =
        tester.widget<CustomTopBar>(find.byType(CustomTopBar)).onBackPressed!;
    back();
    back();
    await tester.pumpAndSettle();
    expectFolder(tester, '1', ['1']);
    response.complete(Right(repository.folders['2']!));
    await tester.pumpAndSettle();
    expectFolder(tester, '1', ['1']);
    expect(store.folderCache.containsKey('2'), isFalse);
    expect(find.text('Documento 2'), findsNothing);
  });

  testWidgets(
      'destino sem cache publica seu conteúdo e falha mantém ID correto',
      (tester) async {
    await start(tester);
    await open(tester, '1');
    await open(tester, '2');
    store.folderCache.remove('1');
    await breadcrumb(tester, 'Pasta 1');
    expectFolder(tester, '1', ['1']);
    expect(repository.folderRequests, ['1', '2', '1']);
    repository.failures['3'] =
        const PermissionDeniedFailure('Sem acesso à pasta');
    await open(tester, '2');
    await open(tester, '3');
    expect(store.activeFolderId, '3');
    expect(store.currentFolder, isNull);
    expect(
        tester
            .widget<FolderContentsPage>(find.byType(FolderContentsPage))
            .folderId,
        '3');
    expect(find.text('Sem acesso à pasta'), findsOneWidget);
    expect(find.text('Documento 2'), findsNothing);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expectFolder(tester, '2', ['1', '2']);
  });
}
