// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DriveStore on _DriveStore, Store {
  Computed<bool>? _$isAdminComputed;

  @override
  bool get isAdmin => (_$isAdminComputed ??=
          Computed<bool>(() => super.isAdmin, name: '_DriveStore.isAdmin'))
      .value;
  Computed<bool>? _$canSeeMyFilesComputed;

  @override
  bool get canSeeMyFiles =>
      (_$canSeeMyFilesComputed ??= Computed<bool>(() => super.canSeeMyFiles,
              name: '_DriveStore.canSeeMyFiles'))
          .value;
  Computed<int>? _$tabCountComputed;

  @override
  int get tabCount => (_$tabCountComputed ??=
          Computed<int>(() => super.tabCount, name: '_DriveStore.tabCount'))
      .value;

  late final _$isLoadingAtom =
      Atom(name: '_DriveStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_DriveStore.error', context: context);

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

  late final _$viewModeAtom =
      Atom(name: '_DriveStore.viewMode', context: context);

  @override
  String get viewMode {
    _$viewModeAtom.reportRead();
    return super.viewMode;
  }

  @override
  set viewMode(String value) {
    _$viewModeAtom.reportWrite(value, super.viewMode, () {
      super.viewMode = value;
    });
  }

  late final _$selectedTabIndexAtom =
      Atom(name: '_DriveStore.selectedTabIndex', context: context);

  @override
  int get selectedTabIndex {
    _$selectedTabIndexAtom.reportRead();
    return super.selectedTabIndex;
  }

  @override
  set selectedTabIndex(int value) {
    _$selectedTabIndexAtom.reportWrite(value, super.selectedTabIndex, () {
      super.selectedTabIndex = value;
    });
  }

  late final _$initializeAsyncAction =
      AsyncAction('_DriveStore.initialize', context: context);

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  late final _$_DriveStoreActionController =
      ActionController(name: '_DriveStore', context: context);

  @override
  void setViewMode(String mode) {
    final _$actionInfo = _$_DriveStoreActionController.startAction(
        name: '_DriveStore.setViewMode');
    try {
      return super.setViewMode(mode);
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedTab(int index) {
    final _$actionInfo = _$_DriveStoreActionController.startAction(
        name: '_DriveStore.setSelectedTab');
    try {
      return super.setSelectedTab(index);
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(String? errorMessage) {
    final _$actionInfo =
        _$_DriveStoreActionController.startAction(name: '_DriveStore.setError');
    try {
      return super.setError(errorMessage);
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_DriveStoreActionController.startAction(
        name: '_DriveStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo =
        _$_DriveStoreActionController.startAction(name: '_DriveStore.reset');
    try {
      return super.reset();
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
viewMode: ${viewMode},
selectedTabIndex: ${selectedTabIndex},
isAdmin: ${isAdmin},
canSeeMyFiles: ${canSeeMyFiles},
tabCount: ${tabCount}
    ''';
  }
}
