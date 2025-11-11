import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobx/mobx.dart';

import '../../../../../shared/core/utils/token_cache.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_store.g.dart';

/// Store MobX para gerenciamento de estado de autenticação
/// Segue o padrão Presentation → Use Cases → Repository
class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final FlutterSecureStorage secureStorage;

  _AuthStoreBase({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
    required this.secureStorage,
  });

  /// Estado de carregamento
  @observable
  bool isLoading = false;

  /// Usuário atual logado
  @observable
  User? currentUser;

  /// Mensagem de erro
  @observable
  String? errorMessage;

  /// Status de autenticação
  @observable
  bool isLoggedIn = false;

  // ========== GETTERS ÚTEIS ==========

  /// Retorna o nome da role do usuário
  @computed
  String? get userRole => currentUser?.role?.name;

  /// Retorna o nome do parceiro
  @computed
  String? get partnerName => currentUser?.partner?.tradeName;

  /// Verifica se o usuário é administrador
  @computed
  bool get isAdmin => currentUser?.role?.name.toLowerCase() == 'administrador';

  /// Verifica se o usuário tem um parceiro associado
  @computed
  bool get hasPartner => currentUser?.partner != null;

  /// Retorna o ID do parceiro
  @computed
  int? get partnerId => currentUser?.partner?.id;

  /// Retorna informações completas do parceiro
  @computed
  String get partnerInfo {
    if (currentUser?.partner == null) return 'Sem parceiro';
    final partner = currentUser!.partner!;
    return '${partner.tradeName} (${partner.cnpj})';
  }

  // ========== GETTERS PARA CUSTOM TOP BAR ==========

  /// Retorna o nome do usuário para exibição no perfil
  @computed
  String get userDisplayName => currentUser?.name ?? 'Usuário';

  /// Retorna o email do usuário para exibição no perfil
  @computed
  String get userDisplayEmail => currentUser?.email ?? 'Sem email';

  /// Retorna o documento (CNPJ) do parceiro para exibição no perfil
  @computed
  String get userDisplayDocument =>
      currentUser?.partner?.cnpj ?? 'Sem documento';

  /// Retorna a URL do avatar do usuário
  @computed
  String? get userDisplayAvatar => currentUser?.avatar;

  /// Retorna true se o usuário tem um parceiro vinculado
  @computed
  bool get hasPartnerData => currentUser?.partner != null;

  /// Action para realizar login
  @action
  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;

    print('🔐 [AuthStore] Iniciando login...');
    final result = await loginUsecase(email: email, password: password);

    await result.fold(
      (failure) async {
        // Em caso de erro
        print('❌ [AuthStore] Login falhou: ${failure.message}');
        errorMessage = failure.message;
        isLoggedIn = false;
        currentUser = null;
        isLoading = false;
      },
      (user) async {
        // Em caso de sucesso - token foi salvo
        print('✅ [AuthStore] Login bem-sucedido - Token salvo');
        print('📥 [AuthStore] Usuário retornado: ${user.name} (${user.email})');

        // === IMPORTANTE: Buscar dados completos via /api/perfil/me ===
        print('🔍 [AuthStore] Buscando dados completos via /api/perfil/me...');
        await loadCurrentUser();

        // Se loadCurrentUser() foi bem-sucedido, navegar
        if (isLoggedIn && currentUser != null) {
          print('✅ [AuthStore] Dados completos carregados - Navegando...');

          // === DEBUG: Informações do usuário após buscar /me ===
          print(
              '╔════════════════════════════════════════════════════════════════╗');
          print(
              '║            LOGIN COMPLETO - DADOS DO USUÁRIO                  ║');
          print(
              '╠════════════════════════════════════════════════════════════════╣');
          print('║ ID:          ${currentUser!.id.toString().padRight(48)}║');
          print('║ Nome:        ${currentUser!.name.padRight(48)}║');
          print('║ Email:       ${currentUser!.email.padRight(48)}║');
          print(
              '║ Role:        ${(currentUser!.role?.name ?? 'NÃO DEFINIDA').padRight(48)}║');
          print(
              '║ Partner:     ${(currentUser!.partner?.tradeName ?? 'N/A').padRight(48)}║');
          print(
              '║ Status:      ${(currentUser!.status ? 'ATIVO' : 'INATIVO').padRight(48)}║');
          print(
              '║ Avatar:      ${(currentUser!.avatar ?? 'N/A').padRight(48)}║');
          print(
              '║ Telefone:    ${(currentUser!.phone ?? 'N/A').padRight(48)}║');
          print(
              '╚════════════════════════════════════════════════════════════════╝');

          // Navegar para a tela principal
          Modular.to.pushReplacementNamed('/budget/');
        } else {
          print('❌ [AuthStore] Falha ao carregar dados completos');
          errorMessage = 'Erro ao carregar dados do usuário';
        }

        isLoading = false;
      },
    );
  }

  /// Action para realizar logout
  @action
  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;

    final result = await logoutUsecase();

    result.fold(
      (failure) {
        // Em caso de erro, ainda assim limpar dados locais
        errorMessage = failure.message;
        currentUser = null;
        isLoggedIn = false;
        isLoading = false;

        // Navegar para login mesmo em caso de erro
        Modular.to.pushReplacementNamed('/auth/login');
      },
      (_) {
        // Em caso de sucesso
        currentUser = null;
        isLoggedIn = false;
        errorMessage = null;
        isLoading = false;

        // Navegar para login
        Modular.to.pushReplacementNamed('/auth/login');
      },
    );
  }

  /// Action para carregar usuário atual
  @action
  Future<void> loadCurrentUser() async {
    isLoading = true;
    errorMessage = null;

    // Tentar carregar token do SecureStorage e cachear
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        TokenCache.instance.setToken(token);
        print('✅ [AuthStore] Token carregado do SecureStorage e cacheado');
      }
    } catch (e) {
      print('⚠️ [AuthStore] Erro ao carregar token: $e');
    }

    final result = await getCurrentUserUsecase();

    result.fold(
      (failure) {
        errorMessage = failure.message;
        isLoggedIn = false;
        currentUser = null;
        isLoading = false;

        print('⚠️ Falha ao carregar usuário atual: ${failure.message}');
      },
      (user) {
        currentUser = user;
        isLoggedIn = true;
        errorMessage = null;
        isLoading = false;

        // === DEBUG: Usuário carregado do cache/storage ===
        print(
            '╔════════════════════════════════════════════════════════════════╗');
        print(
            '║        USUÁRIO CARREGADO DO CACHE - DADOS DO USUÁRIO         ║');
        print(
            '╠════════════════════════════════════════════════════════════════╣');
        print('║ ID:          ${user.id.toString().padRight(48)}║');
        print('║ Nome:        ${user.name.padRight(48)}║');
        print('║ Email:       ${user.email.padRight(48)}║');
        print(
            '║ Role:        ${(user.role?.name ?? 'NÃO DEFINIDA').padRight(48)}║');
        print(
            '║ Partner:     ${(user.partner?.tradeName ?? 'N/A').padRight(48)}║');
        print(
            '║ Status:      ${(user.status ? 'ATIVO' : 'INATIVO').padRight(48)}║');
        print(
            '╚════════════════════════════════════════════════════════════════╝');
      },
    );
  }

  /// Action para limpar mensagem de erro
  @action
  void clearError() {
    errorMessage = null;
  }

  /// Action para resetar o estado
  @action
  void reset() {
    isLoading = false;
    currentUser = null;
    errorMessage = null;
    isLoggedIn = false;
  }
}
