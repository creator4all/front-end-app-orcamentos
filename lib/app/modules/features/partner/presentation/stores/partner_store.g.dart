// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PartnerStore on _PartnerStoreBase, Store {
  late final _$partnerAtom =
      Atom(name: '_PartnerStoreBase.partner', context: context);

  @override
  PartnerProfile? get partner {
    _$partnerAtom.reportRead();
    return super.partner;
  }

  @override
  set partner(PartnerProfile? value) {
    _$partnerAtom.reportWrite(value, super.partner, () {
      super.partner = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_PartnerStoreBase.isLoading', context: context);

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
      Atom(name: '_PartnerStoreBase.isSaving', context: context);

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
      Atom(name: '_PartnerStoreBase.error', context: context);

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

  late final _$tradeNameAtom =
      Atom(name: '_PartnerStoreBase.tradeName', context: context);

  @override
  String get tradeName {
    _$tradeNameAtom.reportRead();
    return super.tradeName;
  }

  @override
  set tradeName(String value) {
    _$tradeNameAtom.reportWrite(value, super.tradeName, () {
      super.tradeName = value;
    });
  }

  late final _$emailAtom =
      Atom(name: '_PartnerStoreBase.email', context: context);

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

  late final _$phoneAtom =
      Atom(name: '_PartnerStoreBase.phone', context: context);

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

  late final _$selectedLogoAtom =
      Atom(name: '_PartnerStoreBase.selectedLogo', context: context);

  @override
  File? get selectedLogo {
    _$selectedLogoAtom.reportRead();
    return super.selectedLogo;
  }

  @override
  set selectedLogo(File? value) {
    _$selectedLogoAtom.reportWrite(value, super.selectedLogo, () {
      super.selectedLogo = value;
    });
  }

  late final _$fetchAsyncAction =
      AsyncAction('_PartnerStoreBase.fetch', context: context);

  @override
  Future<void> fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  late final _$saveAsyncAction =
      AsyncAction('_PartnerStoreBase.save', context: context);

  @override
  Future<bool> save() {
    return _$saveAsyncAction.run(() => super.save());
  }

  late final _$uploadLogoAsyncAction =
      AsyncAction('_PartnerStoreBase.uploadLogo', context: context);

  @override
  Future<bool> uploadLogo() {
    return _$uploadLogoAsyncAction.run(() => super.uploadLogo());
  }

  late final _$_PartnerStoreBaseActionController =
      ActionController(name: '_PartnerStoreBase', context: context);

  @override
  void setTradeName(String value) {
    final _$actionInfo = _$_PartnerStoreBaseActionController.startAction(
        name: '_PartnerStoreBase.setTradeName');
    try {
      return super.setTradeName(value);
    } finally {
      _$_PartnerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String value) {
    final _$actionInfo = _$_PartnerStoreBaseActionController.startAction(
        name: '_PartnerStoreBase.setEmail');
    try {
      return super.setEmail(value);
    } finally {
      _$_PartnerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPhone(String value) {
    final _$actionInfo = _$_PartnerStoreBaseActionController.startAction(
        name: '_PartnerStoreBase.setPhone');
    try {
      return super.setPhone(value);
    } finally {
      _$_PartnerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedLogo(File? file) {
    final _$actionInfo = _$_PartnerStoreBaseActionController.startAction(
        name: '_PartnerStoreBase.setSelectedLogo');
    try {
      return super.setSelectedLogo(file);
    } finally {
      _$_PartnerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_PartnerStoreBaseActionController.startAction(
        name: '_PartnerStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_PartnerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
partner: ${partner},
isLoading: ${isLoading},
isSaving: ${isSaving},
error: ${error},
tradeName: ${tradeName},
email: ${email},
phone: ${phone},
selectedLogo: ${selectedLogo}
    ''';
  }
}
