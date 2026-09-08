import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/repositories/auth_repository.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/usecases/login_usecase.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/profile/data/datasources/profile_api_datasource.dart';
import 'package:multimidiaapp/app/modules/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:multimidiaapp/app/modules/features/profile/presentation/pages/profile_page.dart';
import 'package:multimidiaapp/app/modules/features/profile/presentation/stores/profile_store.dart';
import 'package:multimidiaapp/app/shared/core/errors/http_exceptions.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/http/http_response.dart';

class _ProfileClient implements AppHttpClient {
  final int? partnerId;
  final bool rejectUpdate;
  final List<Map<String, dynamic>> updates = [];

  _ProfileClient({this.partnerId = 27, this.rejectUpdate = false});

  Map<String, dynamic> get profile => {
        'usr_userId': 1,
        'usr_name': 'Pessoa de Teste',
        'usr_email': 'pessoa@example.com',
        'usr_cargo': 'Administradora',
        'usr_phone': '11987654321',
        'usr_status': true,
        'partners_par_partnerId': partnerId,
        'role': {'rol_name': 'Administrador'},
      };

  @override
  Future<HttpResponse> get(String url, {HttpRequestConfig? config}) async {
    expect(url, '/api/perfil/me');
    return HttpResponse(body: {'dados': profile}, headers: {}, statusCode: 200);
  }

  @override
  Future<HttpResponse> put(String url,
      {dynamic data, HttpRequestConfig? config}) async {
    expect(url, '/api/perfil/me');
    updates.add(Map<String, dynamic>.from(data as Map));
    if (rejectUpdate) {
      throw const UnprocessableEntityException(message: 'E-mail já cadastrado');
    }
    return HttpResponse(body: {
      'dados': {...profile, ...updates.last}
    }, headers: {}, statusCode: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProfileAuthStore extends AuthStore {
  int refreshes = 0;

  _ProfileAuthStore()
      : super(
          loginUsecase: LoginUsecase(_UnusedAuthRepository()),
          authRepository: _UnusedAuthRepository(),
          secureStorage: const FlutterSecureStorage(),
        );

  @override
  Future<void> loadCurrentUser({bool forceRefresh = false}) async {
    expect(forceRefresh, isTrue);
    refreshes++;
  }
}

class _ProfileTestModule extends Module {
  final ProfileStore profile;
  final AuthStore auth;
  _ProfileTestModule(this.profile, this.auth);

  @override
  List<Bind> get binds => [
        Bind.instance<ProfileStore>(profile),
        Bind.instance<AuthStore>(auth),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProfileStore store;
  late _ProfileAuthStore auth;

  Future<void> openProfile(WidgetTester tester, _ProfileClient client) async {
    FlutterSecureStorage.setMockInitialValues({});
    store = ProfileStore(ProfileRepositoryImpl(ProfileApiDatasource(client)));
    auth = _ProfileAuthStore();
    Modular.init(_ProfileTestModule(store, auth));
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => const MaterialApp(home: ProfilePage()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(4));
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.text('Salvar Alterações');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  tearDown(() => Modular.destroy());

  for (final entry
      in {2: 'Cargo é obrigatório', 3: 'Telefone é obrigatório'}.entries) {
    testWidgets('${entry.value}: bloqueia PUT', (tester) async {
      final client = _ProfileClient();
      await openProfile(tester, client);
      await tester.enterText(find.byType(TextField).at(entry.key), '');
      await save(tester);
      expect(find.text(entry.value), findsOneWidget);
      expect(client.updates, isEmpty);
      expect(auth.refreshes, 0);
    });
  }

  testWidgets('telefone incompleto não chama a API', (tester) async {
    final client = _ProfileClient();
    await openProfile(tester, client);
    await tester.enterText(find.byType(TextField).at(3), '11987');
    await save(tester);
    expect(find.text('Telefone inválido'), findsOneWidget);
    expect(client.updates, isEmpty);
  });

  for (final partnerId in <int?>[27, null]) {
    testWidgets('perfil válido preserva vínculo $partnerId no PUT',
        (tester) async {
      final client = _ProfileClient(partnerId: partnerId);
      await openProfile(tester, client);
      await tester.enterText(find.byType(TextField).at(0), 'Nome atualizado');
      await save(tester);
      expect(client.updates, hasLength(1));
      expect(client.updates.single, {
        'usr_name': 'Nome atualizado',
        'usr_email': 'pessoa@example.com',
        'usr_cargo': 'Administradora',
        'usr_phone': '11987654321',
        'partners_par_partnerId': partnerId,
      });
      expect(store.profile!.partnerId, partnerId);
      expect(store.isSaving, isFalse);
      expect(auth.refreshes, 1);
      expect(find.text('Perfil atualizado com sucesso!'), findsOneWidget);
    });
  }

  testWidgets('422 aparece como erro sem confirmar salvamento', (tester) async {
    final client = _ProfileClient(rejectUpdate: true);
    await openProfile(tester, client);
    await save(tester);
    expect(client.updates, hasLength(1));
    expect(find.text('E-mail já cadastrado'), findsOneWidget);
    expect(find.text('Perfil atualizado com sucesso!'), findsNothing);
    expect(store.isSaving, isFalse);
    expect(store.profile!.partnerId, 27);
    expect(auth.refreshes, 0);
  });
}
