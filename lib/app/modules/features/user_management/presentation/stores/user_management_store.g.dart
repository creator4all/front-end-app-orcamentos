// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserManagementStore on _UserManagementStoreBase, Store {
  Computed<bool>? _$hasChangesComputed;

  @override
  bool get hasChanges =>
      (_$hasChangesComputed ??= Computed<bool>(() => super.hasChanges,
              name: '_UserManagementStoreBase.hasChanges'))
          .value;
  Computed<bool>? _$hasMoreComputed;

  @override
  bool get hasMore => (_$hasMoreComputed ??= Computed<bool>(() => super.hasMore,
          name: '_UserManagementStoreBase.hasMore'))
      .value;
  Computed<int>? _$changesCountComputed;

  @override
  int get changesCount =>
      (_$changesCountComputed ??= Computed<int>(() => super.changesCount,
              name: '_UserManagementStoreBase.changesCount'))
          .value;
  Computed<List<ManagedUser>>? _$filteredUsersComputed;

  @override
  List<ManagedUser> get filteredUsers => (_$filteredUsersComputed ??=
          Computed<List<ManagedUser>>(() => super.filteredUsers,
              name: '_UserManagementStoreBase.filteredUsers'))
      .value;

  late final _$usersAtom =
      Atom(name: '_UserManagementStoreBase.users', context: context);

  @override
  ObservableList<ManagedUser> get users {
    _$usersAtom.reportRead();
    return super.users;
  }

  @override
  set users(ObservableList<ManagedUser> value) {
    _$usersAtom.reportWrite(value, super.users, () {
      super.users = value;
    });
  }

  late final _$pendingChangesAtom =
      Atom(name: '_UserManagementStoreBase.pendingChanges', context: context);

  @override
  ObservableMap<int, UserUpdate> get pendingChanges {
    _$pendingChangesAtom.reportRead();
    return super.pendingChanges;
  }

  @override
  set pendingChanges(ObservableMap<int, UserUpdate> value) {
    _$pendingChangesAtom.reportWrite(value, super.pendingChanges, () {
      super.pendingChanges = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_UserManagementStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isLoadingMoreAtom =
      Atom(name: '_UserManagementStoreBase.isLoadingMore', context: context);

  @override
  bool get isLoadingMore {
    _$isLoadingMoreAtom.reportRead();
    return super.isLoadingMore;
  }

  @override
  set isLoadingMore(bool value) {
    _$isLoadingMoreAtom.reportWrite(value, super.isLoadingMore, () {
      super.isLoadingMore = value;
    });
  }

  late final _$isSavingAtom =
      Atom(name: '_UserManagementStoreBase.isSaving', context: context);

  @override
  bool get isSaving {
    _$isSavingAtom.reportRead();
    return super.isSaving;
  }

  @override
  set isSaving(bool value) {
    _$isSavingAtom.reportWrite(value, super.isSaving, () {
      super.isSaving = value;
    });
  }

  late final _$errorAtom =
      Atom(name: '_UserManagementStoreBase.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: '_UserManagementStoreBase.currentPage', context: context);

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$lastPageAtom =
      Atom(name: '_UserManagementStoreBase.lastPage', context: context);

  @override
  int get lastPage {
    _$lastPageAtom.reportRead();
    return super.lastPage;
  }

  @override
  set lastPage(int value) {
    _$lastPageAtom.reportWrite(value, super.lastPage, () {
      super.lastPage = value;
    });
  }

  late final _$totalUsersAtom =
      Atom(name: '_UserManagementStoreBase.totalUsers', context: context);

  @override
  int get totalUsers {
    _$totalUsersAtom.reportRead();
    return super.totalUsers;
  }

  @override
  set totalUsers(int value) {
    _$totalUsersAtom.reportWrite(value, super.totalUsers, () {
      super.totalUsers = value;
    });
  }

  late final _$partnerIdAtom =
      Atom(name: '_UserManagementStoreBase.partnerId', context: context);

  @override
  int? get partnerId {
    _$partnerIdAtom.reportRead();
    return super.partnerId;
  }

  @override
  set partnerId(int? value) {
    _$partnerIdAtom.reportWrite(value, super.partnerId, () {
      super.partnerId = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_UserManagementStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$loadUsersAsyncAction =
      AsyncAction('_UserManagementStoreBase.loadUsers', context: context);

  @override
  Future<void> loadUsers() {
    return _$loadUsersAsyncAction.run(() => super.loadUsers());
  }

  late final _$loadMoreUsersAsyncAction =
      AsyncAction('_UserManagementStoreBase.loadMoreUsers', context: context);

  @override
  Future<void> loadMoreUsers() {
    return _$loadMoreUsersAsyncAction.run(() => super.loadMoreUsers());
  }

  late final _$saveChangesAsyncAction =
      AsyncAction('_UserManagementStoreBase.saveChanges', context: context);

  @override
  Future<UpdateUsersResult?> saveChanges() {
    return _$saveChangesAsyncAction.run(() => super.saveChanges());
  }

  late final _$discardChangesAndReloadAsyncAction = AsyncAction(
      '_UserManagementStoreBase.discardChangesAndReload',
      context: context);

  @override
  Future<void> discardChangesAndReload() {
    return _$discardChangesAndReloadAsyncAction
        .run(() => super.discardChangesAndReload());
  }

  late final _$_UserManagementStoreBaseActionController =
      ActionController(name: '_UserManagementStoreBase', context: context);

  @override
  void setPartnerId(int? id) {
    final _$actionInfo = _$_UserManagementStoreBaseActionController.startAction(
        name: '_UserManagementStoreBase.setPartnerId');
    try {
      return super.setPartnerId(id);
    } finally {
      _$_UserManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_UserManagementStoreBaseActionController.startAction(
        name: '_UserManagementStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_UserManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateUserStatus(int userId, bool status) {
    final _$actionInfo = _$_UserManagementStoreBaseActionController.startAction(
        name: '_UserManagementStoreBase.updateUserStatus');
    try {
      return super.updateUserStatus(userId, status);
    } finally {
      _$_UserManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateUserRole(int userId, int roleId, String roleName) {
    final _$actionInfo = _$_UserManagementStoreBaseActionController.startAction(
        name: '_UserManagementStoreBase.updateUserRole');
    try {
      return super.updateUserRole(userId, roleId, roleName);
    } finally {
      _$_UserManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPendingChange(int userId) {
    final _$actionInfo = _$_UserManagementStoreBaseActionController.startAction(
        name: '_UserManagementStoreBase.clearPendingChange');
    try {
      return super.clearPendingChange(userId);
    } finally {
      _$_UserManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
users: ${users},
pendingChanges: ${pendingChanges},
isLoading: ${isLoading},
isLoadingMore: ${isLoadingMore},
isSaving: ${isSaving},
error: ${error},
currentPage: ${currentPage},
lastPage: ${lastPage},
totalUsers: ${totalUsers},
partnerId: ${partnerId},
searchQuery: ${searchQuery},
hasChanges: ${hasChanges},
hasMore: ${hasMore},
changesCount: ${changesCount},
filteredUsers: ${filteredUsers}
    ''';
  }
}
