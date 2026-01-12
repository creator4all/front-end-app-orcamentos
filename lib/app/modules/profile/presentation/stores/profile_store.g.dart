// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileStore on _ProfileStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_ProfileStore.isLoading', context: context);

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

  late final _$isSavingAtom =
      Atom(name: '_ProfileStore.isSaving', context: context);

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

  late final _$isUploadingAvatarAtom =
      Atom(name: '_ProfileStore.isUploadingAvatar', context: context);

  @override
  bool get isUploadingAvatar {
    _$isUploadingAvatarAtom.reportRead();
    return super.isUploadingAvatar;
  }

  @override
  set isUploadingAvatar(bool value) {
    _$isUploadingAvatarAtom.reportWrite(value, super.isUploadingAvatar, () {
      super.isUploadingAvatar = value;
    });
  }

  late final _$errorAtom = Atom(name: '_ProfileStore.error', context: context);

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

  late final _$profileAtom =
      Atom(name: '_ProfileStore.profile', context: context);

  @override
  UserProfile? get profile {
    _$profileAtom.reportRead();
    return super.profile;
  }

  @override
  set profile(UserProfile? value) {
    _$profileAtom.reportWrite(value, super.profile, () {
      super.profile = value;
    });
  }

  late final _$nameAtom = Atom(name: '_ProfileStore.name', context: context);

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$emailAtom = Atom(name: '_ProfileStore.email', context: context);

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$cargoAtom = Atom(name: '_ProfileStore.cargo', context: context);

  @override
  String get cargo {
    _$cargoAtom.reportRead();
    return super.cargo;
  }

  @override
  set cargo(String value) {
    _$cargoAtom.reportWrite(value, super.cargo, () {
      super.cargo = value;
    });
  }

  late final _$phoneAtom = Atom(name: '_ProfileStore.phone', context: context);

  @override
  String get phone {
    _$phoneAtom.reportRead();
    return super.phone;
  }

  @override
  set phone(String value) {
    _$phoneAtom.reportWrite(value, super.phone, () {
      super.phone = value;
    });
  }

  late final _$selectedAvatarAtom =
      Atom(name: '_ProfileStore.selectedAvatar', context: context);

  @override
  File? get selectedAvatar {
    _$selectedAvatarAtom.reportRead();
    return super.selectedAvatar;
  }

  @override
  set selectedAvatar(File? value) {
    _$selectedAvatarAtom.reportWrite(value, super.selectedAvatar, () {
      super.selectedAvatar = value;
    });
  }

  late final _$fetchAsyncAction =
      AsyncAction('_ProfileStore.fetch', context: context);

  @override
  Future<void> fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  late final _$saveAsyncAction =
      AsyncAction('_ProfileStore.save', context: context);

  @override
  Future<bool> save() {
    return _$saveAsyncAction.run(() => super.save());
  }

  late final _$uploadAvatarAsyncAction =
      AsyncAction('_ProfileStore.uploadAvatar', context: context);

  @override
  Future<bool> uploadAvatar() {
    return _$uploadAvatarAsyncAction.run(() => super.uploadAvatar());
  }

  late final _$removeAvatarAsyncAction =
      AsyncAction('_ProfileStore.removeAvatar', context: context);

  @override
  Future<bool> removeAvatar() {
    return _$removeAvatarAsyncAction.run(() => super.removeAvatar());
  }

  late final _$_ProfileStoreActionController =
      ActionController(name: '_ProfileStore', context: context);

  @override
  void setName(String value) {
    final _$actionInfo = _$_ProfileStoreActionController.startAction(
        name: '_ProfileStore.setName');
    try {
      return super.setName(value);
    } finally {
      _$_ProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String value) {
    final _$actionInfo = _$_ProfileStoreActionController.startAction(
        name: '_ProfileStore.setEmail');
    try {
      return super.setEmail(value);
    } finally {
      _$_ProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCargo(String value) {
    final _$actionInfo = _$_ProfileStoreActionController.startAction(
        name: '_ProfileStore.setCargo');
    try {
      return super.setCargo(value);
    } finally {
      _$_ProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPhone(String value) {
    final _$actionInfo = _$_ProfileStoreActionController.startAction(
        name: '_ProfileStore.setPhone');
    try {
      return super.setPhone(value);
    } finally {
      _$_ProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedAvatar(File? file) {
    final _$actionInfo = _$_ProfileStoreActionController.startAction(
        name: '_ProfileStore.setSelectedAvatar');
    try {
      return super.setSelectedAvatar(file);
    } finally {
      _$_ProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_ProfileStoreActionController.startAction(
        name: '_ProfileStore.reset');
    try {
      return super.reset();
    } finally {
      _$_ProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isSaving: ${isSaving},
isUploadingAvatar: ${isUploadingAvatar},
error: ${error},
profile: ${profile},
name: ${name},
email: ${email},
cargo: ${cargo},
phone: ${phone},
selectedAvatar: ${selectedAvatar}
    ''';
  }
}
