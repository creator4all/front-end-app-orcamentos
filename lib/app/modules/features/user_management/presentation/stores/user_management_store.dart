import 'package:mobx/mobx.dart';

import '../../domain/entities/managed_user.dart';
import '../../domain/usecases/list_users_usecase.dart';
import '../../domain/usecases/update_users_usecase.dart';

part 'user_management_store.g.dart';

/// Store MobX para gerenciamento de estado da tela de gestão de usuários
class UserManagementStore = _UserManagementStoreBase with _$UserManagementStore;

abstract class _UserManagementStoreBase with Store {
  final ListUsersUsecase listUsersUsecase;
  final UpdateUsersUsecase updateUsersUsecase;

  _UserManagementStoreBase({
    required this.listUsersUsecase,
    required this.updateUsersUsecase,
  });

  // ========== OBSERVABLES ==========

  /// Lista de usuários carregados
  @observable
  ObservableList<ManagedUser> users = ObservableList<ManagedUser>();

  /// Mapa de alterações pendentes (userId -> UserUpdate)
  @observable
  ObservableMap<int, UserUpdate> pendingChanges =
      ObservableMap<int, UserUpdate>();

  /// Estado de carregamento inicial
  @observable
  bool isLoading = false;

  /// Estado de carregamento de mais itens (scroll infinito)
  @observable
  bool isLoadingMore = false;

  /// Estado de salvamento
  @observable
  bool isSaving = false;

  /// Mensagem de erro
  @observable
  String? error;

  /// Página atual
  @observable
  int currentPage = 1;

  /// Total de páginas
  @observable
  int lastPage = 1;

  /// Total de usuários
  @observable
  int totalUsers = 0;

  // ========== COMPUTED ==========

  /// Verifica se há alterações pendentes
  @computed
  bool get hasChanges => pendingChanges.isNotEmpty;

  /// Verifica se há mais páginas para carregar
  @computed
  bool get hasMore => currentPage < lastPage;

  /// Quantidade de alterações pendentes
  @computed
  int get changesCount => pendingChanges.length;

  // ========== ACTIONS ==========

  /// Carrega a lista inicial de usuários
  @action
  Future<void> loadUsers() async {
    isLoading = true;
    error = null;
    currentPage = 1;
    users.clear();
    pendingChanges.clear();

    print('📋 [UserManagementStore] Carregando usuários...');

    final result = await listUsersUsecase(page: 1);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [UserManagementStore] Erro: ${failure.message}');
      },
      (paginatedUsers) {
        users.addAll(paginatedUsers.users);
        currentPage = paginatedUsers.currentPage;
        lastPage = paginatedUsers.lastPage;
        totalUsers = paginatedUsers.total;
        print('✅ [UserManagementStore] Carregados ${users.length} usuários');
      },
    );

    isLoading = false;
  }

  /// Carrega mais usuários (scroll infinito)
  @action
  Future<void> loadMoreUsers() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    final nextPage = currentPage + 1;

    print('📋 [UserManagementStore] Carregando página $nextPage...');

    final result = await listUsersUsecase(page: nextPage);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [UserManagementStore] Erro: ${failure.message}');
      },
      (paginatedUsers) {
        users.addAll(paginatedUsers.users);
        currentPage = paginatedUsers.currentPage;
        lastPage = paginatedUsers.lastPage;
        print(
            '✅ [UserManagementStore] Carregados mais ${paginatedUsers.users.length} usuários');
      },
    );

    isLoadingMore = false;
  }

  /// Atualiza o status de um usuário localmente
  @action
  void updateUserStatus(int userId, bool status) {
    // Encontrar o usuário na lista
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    final user = users[index];

    // Atualizar na lista local
    users[index] = user.copyWith(status: status);

    // Adicionar ou atualizar em pendingChanges
    final existing = pendingChanges[userId];
    if (existing != null) {
      pendingChanges[userId] = UserUpdate(
        userId: userId,
        status: status,
        roleId: existing.roleId,
      );
    } else {
      pendingChanges[userId] = UserUpdate(
        userId: userId,
        status: status,
      );
    }

    print(
        '📝 [UserManagementStore] Status do usuário $userId alterado para $status');
  }

  /// Atualiza a role de um usuário localmente
  @action
  void updateUserRole(int userId, int roleId, String roleName) {
    // Encontrar o usuário na lista
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    final user = users[index];

    // Atualizar na lista local
    users[index] = user.copyWith(roleId: roleId, roleName: roleName);

    // Adicionar ou atualizar em pendingChanges
    final existing = pendingChanges[userId];
    if (existing != null) {
      pendingChanges[userId] = UserUpdate(
        userId: userId,
        status: existing.status,
        roleId: roleId,
      );
    } else {
      pendingChanges[userId] = UserUpdate(
        userId: userId,
        roleId: roleId,
      );
    }

    print(
        '📝 [UserManagementStore] Role do usuário $userId alterado para $roleName (ID: $roleId)');
  }

  /// Salva todas as alterações pendentes
  @action
  Future<UpdateUsersResult?> saveChanges() async {
    if (!hasChanges) {
      return const UpdateUsersResult(
        updated: [],
        errors: [],
        message: 'Nenhuma alteração para salvar',
      );
    }

    isSaving = true;
    error = null;

    print('💾 [UserManagementStore] Salvando $changesCount alterações...');

    final updates = pendingChanges.values.toList();
    final result = await updateUsersUsecase(updates);

    UpdateUsersResult? updateResult;

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [UserManagementStore] Erro ao salvar: ${failure.message}');
      },
      (success) {
        updateResult = success;
        pendingChanges.clear();
        print('✅ [UserManagementStore] Salvo com sucesso: ${success.message}');
      },
    );

    isSaving = false;
    return updateResult;
  }

  /// Limpa uma alteração pendente
  @action
  void clearPendingChange(int userId) {
    pendingChanges.remove(userId);
  }

  /// Limpa todas as alterações pendentes e recarrega
  @action
  Future<void> discardChangesAndReload() async {
    pendingChanges.clear();
    await loadUsers();
  }
}
