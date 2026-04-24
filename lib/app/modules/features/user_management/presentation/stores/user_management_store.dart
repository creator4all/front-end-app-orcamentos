import 'package:mobx/mobx.dart';

import '../../domain/entities/managed_user.dart';
import '../../domain/usecases/list_users_usecase.dart';
import '../../domain/usecases/update_users_usecase.dart';

part 'user_management_store.g.dart';

// ignore: library_private_types_in_public_api
class UserManagementStore = _UserManagementStoreBase with _$UserManagementStore;

abstract class _UserManagementStoreBase with Store {
  final ListUsersUsecase listUsersUsecase;
  final UpdateUsersUsecase updateUsersUsecase;

  _UserManagementStoreBase({
    required this.listUsersUsecase,
    required this.updateUsersUsecase,
  });

  final Map<int, _OriginalUserState> _originalStates = {};

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
  int? currentUserId;

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
    final baseList = currentUserId != null
        ? users.where((user) => user.id != currentUserId).toList()
        : users.toList();
    if (searchQuery.isEmpty) {
      return baseList;
    }
    final query = searchQuery.toLowerCase();
    return baseList.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  @action
  void setPartnerId(int? id) {
    partnerId = id;
  }

  @action
  void setCurrentUserId(int? id) {
    currentUserId = id;
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
    _originalStates.clear();

    final result = await listUsersUsecase(page: 1, partnerId: partnerId);

    result.fold(
      (failure) {
        error = failure.message;
      },
      (paginatedUsers) {
        users.addAll(paginatedUsers.users);
        for (final u in paginatedUsers.users) {
          _originalStates[u.id] =
              _OriginalUserState(status: u.status, roleId: u.roleId);
        }
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
        for (final u in paginatedUsers.users) {
          _originalStates[u.id] =
              _OriginalUserState(status: u.status, roleId: u.roleId);
        }
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

    final original = _originalStates[userId];
    final currentRoleId = pendingChanges[userId]?.roleId ?? user.roleId;

    if (original != null &&
        status == original.status &&
        currentRoleId == original.roleId) {
      pendingChanges.remove(userId);
      return;
    }

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

    final original = _originalStates[userId];
    final currentStatus = pendingChanges[userId]?.status ?? user.status;

    if (original != null &&
        roleId == original.roleId &&
        currentStatus == original.status) {
      pendingChanges.remove(userId);
      return;
    }

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
    final submittedUpdates = {
      for (final update in updates) update.userId: update,
    };
    UpdateUsersResult? updateResult;

    try {
      final result = await updateUsersUsecase(updates);

      result.fold(
        (failure) {
          error = failure.message;
        },
        (success) {
          updateResult = success;
          _commitSuccessfulUpdates(success.updated, submittedUpdates);
          if (success.errors.isNotEmpty) {
            error = success.errors.join('\n');
          }
        },
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isSaving = false;
    }

    return updateResult;
  }

  void _commitSuccessfulUpdates(
    List<int> updatedUserIds,
    Map<int, UserUpdate> submittedUpdates,
  ) {
    for (final userId in updatedUserIds) {
      final submittedUpdate = submittedUpdates[userId];
      if (submittedUpdate == null) continue;

      final userIndex = users.indexWhere((u) => u.id == userId);
      if (userIndex == -1) continue;

      final user = users[userIndex];
      final previousOriginal = _originalStates[userId];
      final committedStatus =
          submittedUpdate.status ?? previousOriginal?.status ?? user.status;
      final committedRoleId =
          submittedUpdate.roleId ?? previousOriginal?.roleId ?? user.roleId;

      _originalStates[userId] = _OriginalUserState(
        status: committedStatus,
        roleId: committedRoleId,
      );

      final pendingUpdate = pendingChanges[userId];
      if (pendingUpdate == null || pendingUpdate == submittedUpdate) {
        users[userIndex] = user.copyWith(
          status: committedStatus,
          roleId: committedRoleId,
        );
        pendingChanges.remove(userId);
        continue;
      }

      final pendingStatus = pendingUpdate.status ?? users[userIndex].status;
      final pendingRoleId = pendingUpdate.roleId ?? users[userIndex].roleId;
      if (pendingStatus == committedStatus &&
          pendingRoleId == committedRoleId) {
        pendingChanges.remove(userId);
      }
    }
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

class _OriginalUserState {
  final bool status;
  final int roleId;
  const _OriginalUserState({required this.status, required this.roleId});
}
