import 'package:mobx/mobx.dart';

import '../../domain/entities/managed_user.dart';
import '../../domain/usecases/list_users_usecase.dart';
import '../../domain/usecases/update_users_usecase.dart';

part 'user_management_store.g.dart';

class UserManagementStore = _UserManagementStoreBase with _$UserManagementStore;

abstract class _UserManagementStoreBase with Store {
  final ListUsersUsecase listUsersUsecase;
  final UpdateUsersUsecase updateUsersUsecase;

  _UserManagementStoreBase({
    required this.listUsersUsecase,
    required this.updateUsersUsecase,
  });


  @observable
  ObservableList<ManagedUser> users = ObservableList<ManagedUser>();

  @observable
  ObservableMap<int, UserUpdate> pendingChanges =
      ObservableMap<int, UserUpdate>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  bool isSaving = false;

  @observable
  String? error;

  @observable
  int currentPage = 1;

  @observable
  int lastPage = 1;

  @observable
  int totalUsers = 0;

  @observable
  int? partnerId;

  @observable
  String searchQuery = '';
  @computed
  bool get hasChanges => pendingChanges.isNotEmpty;

  @computed
  bool get hasMore => currentPage < lastPage;

  @computed
  int get changesCount => pendingChanges.length;

  @computed
  List<ManagedUser> get filteredUsers {
    if (searchQuery.isEmpty) {
      return users.toList();
    }
    final query = searchQuery.toLowerCase();
    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }


  @action
  void setPartnerId(int? id) {
    partnerId = id;
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  Future<void> loadUsers() async {
    isLoading = true;
    error = null;
    currentPage = 1;
    users.clear();
    pendingChanges.clear();

    final result = await listUsersUsecase(page: 1, partnerId: partnerId);

    result.fold(
      (failure) {
        error = failure.message;
      },
      (paginatedUsers) {
        users.addAll(paginatedUsers.users);
        currentPage = paginatedUsers.currentPage;
        lastPage = paginatedUsers.lastPage;
        totalUsers = paginatedUsers.total;
      },
    );

    isLoading = false;
  }

  @action
  Future<void> loadMoreUsers() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    final nextPage = currentPage + 1;

    final result = await listUsersUsecase(page: nextPage, partnerId: partnerId);

    result.fold(
      (failure) {
        error = failure.message;
      },
      (paginatedUsers) {
        users.addAll(paginatedUsers.users);
        currentPage = paginatedUsers.currentPage;
        lastPage = paginatedUsers.lastPage;
      },
    );

    isLoadingMore = false;
  }

  @action
  void updateUserStatus(int userId, bool status) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    final user = users[index];

    users[index] = user.copyWith(status: status);

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
  }

  @action
  void updateUserRole(int userId, int roleId, String roleName) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    final user = users[index];

    users[index] = user.copyWith(roleId: roleId, roleName: roleName);

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
  }

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

    final updates = pendingChanges.values.toList();
    final result = await updateUsersUsecase(updates);

    UpdateUsersResult? updateResult;

    result.fold(
      (failure) {
        error = failure.message;
      },
      (success) {
        updateResult = success;
        pendingChanges.clear();
      },
    );

    isSaving = false;
    return updateResult;
  }

  @action
  void clearPendingChange(int userId) {
    pendingChanges.remove(userId);
  }
  @action
  Future<void> discardChangesAndReload() async {
    pendingChanges.clear();
    await loadUsers();
  }
}