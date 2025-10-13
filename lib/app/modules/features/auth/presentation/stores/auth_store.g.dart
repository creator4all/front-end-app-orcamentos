// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStoreBase, Store {
  Computed<String?>? _$userRoleComputed;

  @override
  String? get userRole =>
      (_$userRoleComputed ??= Computed<String?>(() => super.userRole,
              name: '_AuthStoreBase.userRole'))
          .value;
  Computed<String?>? _$partnerNameComputed;

  @override
  String? get partnerName =>
      (_$partnerNameComputed ??= Computed<String?>(() => super.partnerName,
              name: '_AuthStoreBase.partnerName'))
          .value;
  Computed<bool>? _$isAdminComputed;

  @override
  bool get isAdmin => (_$isAdminComputed ??=
          Computed<bool>(() => super.isAdmin, name: '_AuthStoreBase.isAdmin'))
      .value;
  Computed<bool>? _$hasPartnerComputed;

  @override
  bool get hasPartner =>
      (_$hasPartnerComputed ??= Computed<bool>(() => super.hasPartner,
              name: '_AuthStoreBase.hasPartner'))
          .value;
  Computed<int?>? _$partnerIdComputed;

  @override
  int? get partnerId =>
      (_$partnerIdComputed ??= Computed<int?>(() => super.partnerId,
              name: '_AuthStoreBase.partnerId'))
          .value;
  Computed<String>? _$partnerInfoComputed;

  @override
  String get partnerInfo =>
      (_$partnerInfoComputed ??= Computed<String>(() => super.partnerInfo,
              name: '_AuthStoreBase.partnerInfo'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_AuthStoreBase.isLoading', context: context);

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

  late final _$currentUserAtom =
      Atom(name: '_AuthStoreBase.currentUser', context: context);

  @override
  User? get currentUser {
    _$currentUserAtom.reportRead();
    return super.currentUser;
  }

  @override
  set currentUser(User? value) {
    _$currentUserAtom.reportWrite(value, super.currentUser, () {
      super.currentUser = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_AuthStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$isLoggedInAtom =
      Atom(name: '_AuthStoreBase.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$loginAsyncAction =
      AsyncAction('_AuthStoreBase.login', context: context);

  @override
  Future<void> login(String email, String password) {
    return _$loginAsyncAction.run(() => super.login(email, password));
  }

  late final _$logoutAsyncAction =
      AsyncAction('_AuthStoreBase.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$loadCurrentUserAsyncAction =
      AsyncAction('_AuthStoreBase.loadCurrentUser', context: context);

  @override
  Future<void> loadCurrentUser() {
    return _$loadCurrentUserAsyncAction.run(() => super.loadCurrentUser());
  }

  late final _$_AuthStoreBaseActionController =
      ActionController(name: '_AuthStoreBase', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_AuthStoreBaseActionController.startAction(
        name: '_AuthStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_AuthStoreBaseActionController.startAction(
        name: '_AuthStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
currentUser: ${currentUser},
errorMessage: ${errorMessage},
isLoggedIn: ${isLoggedIn},
userRole: ${userRole},
partnerName: ${partnerName},
isAdmin: ${isAdmin},
hasPartner: ${hasPartner},
partnerId: ${partnerId},
partnerInfo: ${partnerInfo}
    ''';
  }
}
