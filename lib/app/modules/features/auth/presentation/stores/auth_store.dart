import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobx/mobx.dart';

import '../../../../../shared/core/auth/session_expiration_handler.dart';
import '../../../../../shared/core/utils/token_cache.dart';
import '../../../../../shared/utils/document_validators.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final LoginUsecase loginUsecase;
  final AuthRepository authRepository;
  final FlutterSecureStorage secureStorage;
  int _sessionGeneration = 0;

  _AuthStoreBase({
    required this.loginUsecase,
    required this.authRepository,
    required this.secureStorage,
  });

  @observable
  bool isLoading = false;

  @observable
  User? currentUser;

  @observable
  String? errorMessage;

  @observable
  bool isLoggedIn = false;

  @computed
  String? get userRole => currentUser?.role?.name;

  @computed
  String? get partnerName => currentUser?.partner?.tradeName;

  @computed
  bool get isAdmin => currentUser?.role?.name.toLowerCase() == 'administrador';

  @computed
  bool get isManager => currentUser?.role?.name.toLowerCase() == 'gestor';

  @computed
  bool get hasPartner => currentUser?.partner != null;
  @computed
  int? get partnerId => currentUser?.partner?.id;

  @computed
  String get partnerInfo {
    if (currentUser?.partner == null) return 'Sem parceiro';
    final partner = currentUser!.partner!;
    return '${partner.tradeName} (${DocumentValidators.formatDocument(partner.cnpj)})';
  }

  @computed
  String get userDisplayName => currentUser?.name ?? 'Usuário';

  @computed
  String get userDisplayEmail => currentUser?.email ?? 'Sem email';

  @computed
  String get userDisplayDocument => currentUser?.partner?.cnpj != null
      ? DocumentValidators.formatDocument(currentUser!.partner!.cnpj)
      : 'Sem documento';
  @computed
  String? get userDisplayAvatar => currentUser?.avatarBase64;

  @computed
  bool get hasPartnerData => currentUser?.partner != null;

  @action
  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;

    final result = await loginUsecase(email: email, password: password);

    await result.fold(
      (failure) async {
        errorMessage = failure.message;
        isLoggedIn = false;
        currentUser = null;
        isLoading = false;
      },
      (user) async {
        await loadCurrentUser(forceRefresh: true);

        if (isLoggedIn && currentUser != null) {
          Modular.to.pushReplacementNamed('/budget/');
        } else {
          errorMessage = 'Erro ao carregar dados do usuário';
        }

        isLoading = false;
      },
    );
  }

  @action
  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;

    final result = await authRepository.logout();

    result.fold(
      (failure) {
        errorMessage = failure.message;
        currentUser = null;
        isLoggedIn = false;
        isLoading = false;
        Modular.to.pushReplacementNamed('/auth/login');
      },
      (_) {
        currentUser = null;
        isLoggedIn = false;
        errorMessage = null;
        isLoading = false;
        Modular.to.pushReplacementNamed('/auth/login');
      },
    );
  }

  @action
  Future<void> loadCurrentUser({bool forceRefresh = false}) async {
    final generation = _sessionGeneration;
    isLoading = true;
    errorMessage = null;

    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        if (generation != _sessionGeneration) return;
        isLoggedIn = false;
        currentUser = null;
        isLoading = false;
        return;
      }
      TokenCache.instance.setToken(token);
      SessionExpirationHandler.arm();
    } catch (_) {
      if (generation != _sessionGeneration) return;
      isLoggedIn = false;
      currentUser = null;
      isLoading = false;
      return;
    }

    final result =
        await authRepository.getCurrentUser(forceRefresh: forceRefresh);

    if (generation != _sessionGeneration) return;

    result.fold(
      (failure) {
        errorMessage = failure.message;
        isLoggedIn = false;
        currentUser = null;
        isLoading = false;
      },
      (user) {
        currentUser = user;
        isLoggedIn = true;
        errorMessage = null;
        isLoading = false;
      },
    );
  }

  @action
  Future<void> restoreSession() async {
    await loadCurrentUser(forceRefresh: true);
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void reset() {
    _sessionGeneration++;
    isLoading = false;
    currentUser = null;
    errorMessage = null;
    isLoggedIn = false;
  }
}
