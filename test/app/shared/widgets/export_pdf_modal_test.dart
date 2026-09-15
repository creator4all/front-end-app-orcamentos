import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart' hide Bind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/entities/user.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/repositories/auth_repository.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/usecases/login_usecase.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/repositories/budget_pdf_repository.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/usecases/generate_pdf_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';
import 'package:multimidiaapp/app/modules/features/partner/data/services/partner_service.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/http/http_response.dart';
import 'package:multimidiaapp/app/shared/widgets/export_pdf_modal.dart';

class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PartnerClient implements AppHttpClient {
  @override
  Future<HttpResponse> get(String url, {HttpRequestConfig? config}) async =>
      HttpResponse(
          body: {'dados': <String, dynamic>{}}, headers: {}, statusCode: 200);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PdfRepository implements BudgetPdfRepository {
  Either<BudgetFailure, PdfResult> result = Right(
    PdfResult(pdfBase64: base64Encode(utf8.encode('%PDF-1.4 fake'))),
  );
  int calls = 0;

  @override
  Future<Either<BudgetFailure, PdfResult>> generatePdf(
      GeneratePdfParams params) async {
    calls++;
    return result;
  }
}

class _TestModule extends Module {
  final AuthStore auth;
  _TestModule(this.auth);

  @override
  List<Bind> get binds => [
        Bind.instance<AuthStore>(auth),
        Bind.instance<PartnerService>(
            PartnerService(_PartnerClient(), const FlutterSecureStorage())),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
  late _PdfRepository repository;
  late Directory temporary;
  late List<String> events;
  late Completer<void> shared;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    temporary = Directory.systemTemp.createTempSync('pdf-renewal-test-');
    events = [];
    shared = Completer<void>();
    repository = _PdfRepository();
    final auth = AuthStore(
      loginUsecase: LoginUsecase(_UnusedAuthRepository()),
      authRepository: _UnusedAuthRepository(),
      secureStorage: const FlutterSecureStorage(),
    )..currentUser = const User(
        id: 1,
        name: 'Vendedor Teste',
        email: 'vendedor@example.com',
        status: true,
        delete: false,
        cargo: 'Vendedor',
        phone: '11987654321',
      );
    Modular.init(_TestModule(auth));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => temporary.path);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, (call) async {
      events.add('share');
      final paths = (call.arguments as Map)['paths'] as List;
      expect(File(paths.single as String).readAsStringSync(), '%PDF-1.4 fake');
      shared.complete();
      return ''; // Usuário cancelou o compartilhamento; a geração já ocorreu.
    });
  });

  tearDown(() {
    Modular.destroy();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, null);
    temporary.deleteSync(recursive: true);
  });

  Future<void> openModal(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) =>
          MaterialApp(home: Scaffold(body: Builder(builder: (context) {
        return TextButton(
            onPressed: () => ExportPdfModal.show(
                  context: context,
                  orcamentoId: 42,
                  generatePdfUseCase: GeneratePdfUseCase(repository),
                  onGenerated: () => events.add('generated'),
                ),
            child: const Text('Abrir'));
      }))),
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> generate(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Compartilhar PDF'));
    await tester.tap(find.text('Compartilhar PDF'));
    await tester.pump();
    expect(repository.calls, 1);
  }

  testWidgets('gera antes do share e notifica mesmo quando share e cancelado',
      (tester) async {
    await openModal(tester);
    await tester.ensureVisible(find.text('Compartilhar PDF'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Compartilhar PDF'));
      await shared.future.timeout(const Duration(seconds: 5));
    });
    await tester.pumpAndSettle();
    expect(events, ['generated', 'share']);
    expect(find.text('Exportar PDF'), findsNothing);
  });

  testWidgets('falha de geracao nao notifica renovacao nem compartilha',
      (tester) async {
    await openModal(tester);
    repository.result = const Left(ServerFailure('Falha na geração'));
    await generate(tester);
    await tester.pumpAndSettle();
    expect(events, isEmpty);
    expect(find.textContaining('Falha na geração'), findsOneWidget);
    expect(find.text('Exportar PDF'), findsOneWidget);
  });

  testWidgets('fechar modal sem gerar nao notifica renovacao', (tester) async {
    await openModal(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(repository.calls, 0);
    expect(events, isEmpty);
  });
}
