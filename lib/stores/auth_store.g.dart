// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  Computed<bool>? _$isAuthenticatedComputed;

  @override
  bool get isAuthenticated =>
      (_$isAuthenticatedComputed ??= Computed<bool>(() => super.isAuthenticated,
              name: '_AuthStore.isAuthenticated'))
          .value;
  Computed<bool>? _$isManagerComputed;

  @override
  bool get isManager => (_$isManagerComputed ??=
          Computed<bool>(() => super.isManager, name: '_AuthStore.isManager'))
      .value;
  Computed<bool>? _$isSellerComputed;

  @override
  bool get isSeller => (_$isSellerComputed ??=
          Computed<bool>(() => super.isSeller, name: '_AuthStore.isSeller'))
      .value;
  Computed<bool>? _$isAdminComputed;

  @override
  bool get isAdmin => (_$isAdminComputed ??=
          Computed<bool>(() => super.isAdmin, name: '_AuthStore.isAdmin'))
      .value;

  late final _$userAtom = Atom(name: '_AuthStore.user', context: context);

  @override
  UserEntity? get user {
    _$userAtom.reportRead();
    return super.user;
  }

  @override
  set user(UserEntity? value) {
    _$userAtom.reportWrite(value, super.user, () {
      super.user = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AuthStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_AuthStore.error', context: context);

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

  late final _$logoutAsyncAction =
      AsyncAction('_AuthStore.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$_AuthStoreActionController =
      ActionController(name: '_AuthStore', context: context);

  @override
  void setUser(UserEntity newUser) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setUser');
    try {
      return super.setUser(newUser);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearUser() {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.clearUser');
    try {
      return super.clearUser();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool loading) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setLoading');
    try {
      return super.setLoading(loading);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(String? errorMessage) {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.setError');
    try {
      return super.setError(errorMessage);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo =
        _$_AuthStoreActionController.startAction(name: '_AuthStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
user: ${user},
isLoading: ${isLoading},
error: ${error},
isAuthenticated: ${isAuthenticated},
isManager: ${isManager},
isSeller: ${isSeller},
isAdmin: ${isAdmin}
    ''';
  }
}
