import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/entities/user.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/repositories/auth_repository.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/usecases/login_usecase.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/shared/core/errors/failures.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  String? token;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return key == 'auth_token' ? token : null;
  }
}

class _FakeAuthRepository implements AuthRepository {
  Either<Failure, User>? currentUserResult;
  int getCurrentUserCalls = 0;
  bool? lastForceRefresh;

  @override
  Future<Either<Failure, User>> getCurrentUser({bool forceRefresh = false}) async {
    getCurrentUserCalls++;
    lastForceRefresh = forceRefresh;
    return currentUserResult ?? const Left(AuthFailure('Sessão expirada. Faça login novamente.'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

User _user() {
  return const User(
    id: 1,
    name: 'Parceiro',
    email: 'parceiro@example.test',
    status: true,
    delete: false,
  );
}

void main() {
  late _FakeSecureStorage storage;
  late _FakeAuthRepository repository;
  late AuthStore store;

  setUp(() {
    storage = _FakeSecureStorage();
    repository = _FakeAuthRepository();
    store = AuthStore(
      loginUsecase: LoginUsecase(repository),
      authRepository: repository,
      secureStorage: storage,
    );
    TokenCache.instance.clearToken();
  });

  test('restoreSession does not accept cache as proof of a valid session', () async {
    storage.token = 'cached-token';
    repository.currentUserResult = Right(_user());

    await store.restoreSession();

    expect(repository.lastForceRefresh, isTrue);
    expect(store.isLoggedIn, isTrue);
    expect(store.currentUser?.email, 'parceiro@example.test');
  });

  test('restoreSession does not keep authenticated state after auth failure', () async {
    storage.token = 'stale-token';
    repository.currentUserResult = const Left(AuthFailure('Sessão expirada. Faça login novamente.'));

    await store.restoreSession();

    expect(store.isLoggedIn, isFalse);
    expect(store.currentUser, isNull);
  });

  test('network failure on restore does not mark the session as validated', () async {
    storage.token = 'cached-token';
    repository.currentUserResult = const Left(NetworkFailure('Falha na conexão com o servidor'));

    await store.restoreSession();

    expect(store.isLoggedIn, isFalse);
    expect(store.currentUser, isNull);
    expect(storage.token, 'cached-token');
  });

  test('reset clears authenticated memory of the previous session', () async {
    storage.token = 'old-token';
    repository.currentUserResult = Right(_user());

    await store.restoreSession();
    expect(store.isLoggedIn, isTrue);

    store.reset();

    expect(store.isLoggedIn, isFalse);
    expect(store.currentUser, isNull);
  });
}
