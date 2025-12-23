// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegistrationStore on _RegistrationStoreBase, Store {
  Computed<bool>? _$hasFoundCompanyComputed;

  @override
  bool get hasFoundCompany =>
      (_$hasFoundCompanyComputed ??= Computed<bool>(() => super.hasFoundCompany,
              name: '_RegistrationStoreBase.hasFoundCompany'))
          .value;
  Computed<bool>? _$canProceedToRegistrationComputed;

  @override
  bool get canProceedToRegistration => (_$canProceedToRegistrationComputed ??=
          Computed<bool>(() => super.canProceedToRegistration,
              name: '_RegistrationStoreBase.canProceedToRegistration'))
      .value;

  late final _$isVerifyingDocumentAtom = Atom(
      name: '_RegistrationStoreBase.isVerifyingDocument', context: context);

  @override
  bool get isVerifyingDocument {
    _$isVerifyingDocumentAtom.reportRead();
    return super.isVerifyingDocument;
  }

  @override
  set isVerifyingDocument(bool value) {
    _$isVerifyingDocumentAtom.reportWrite(value, super.isVerifyingDocument, () {
      super.isVerifyingDocument = value;
    });
  }

  late final _$foundCompanyAtom =
      Atom(name: '_RegistrationStoreBase.foundCompany', context: context);

  @override
  Company? get foundCompany {
    _$foundCompanyAtom.reportRead();
    return super.foundCompany;
  }

  @override
  set foundCompany(Company? value) {
    _$foundCompanyAtom.reportWrite(value, super.foundCompany, () {
      super.foundCompany = value;
    });
  }

  late final _$verifyErrorAtom =
      Atom(name: '_RegistrationStoreBase.verifyError', context: context);

  @override
  String? get verifyError {
    _$verifyErrorAtom.reportRead();
    return super.verifyError;
  }

  @override
  set verifyError(String? value) {
    _$verifyErrorAtom.reportWrite(value, super.verifyError, () {
      super.verifyError = value;
    });
  }

  late final _$isRegisteringUserAtom =
      Atom(name: '_RegistrationStoreBase.isRegisteringUser', context: context);

  @override
  bool get isRegisteringUser {
    _$isRegisteringUserAtom.reportRead();
    return super.isRegisteringUser;
  }

  @override
  set isRegisteringUser(bool value) {
    _$isRegisteringUserAtom.reportWrite(value, super.isRegisteringUser, () {
      super.isRegisteringUser = value;
    });
  }

  late final _$registerUserErrorAtom =
      Atom(name: '_RegistrationStoreBase.registerUserError', context: context);

  @override
  String? get registerUserError {
    _$registerUserErrorAtom.reportRead();
    return super.registerUserError;
  }

  @override
  set registerUserError(String? value) {
    _$registerUserErrorAtom.reportWrite(value, super.registerUserError, () {
      super.registerUserError = value;
    });
  }

  late final _$registerUserSuccessAtom = Atom(
      name: '_RegistrationStoreBase.registerUserSuccess', context: context);

  @override
  bool get registerUserSuccess {
    _$registerUserSuccessAtom.reportRead();
    return super.registerUserSuccess;
  }

  @override
  set registerUserSuccess(bool value) {
    _$registerUserSuccessAtom.reportWrite(value, super.registerUserSuccess, () {
      super.registerUserSuccess = value;
    });
  }

  late final _$isRequestingPartnerAtom = Atom(
      name: '_RegistrationStoreBase.isRequestingPartner', context: context);

  @override
  bool get isRequestingPartner {
    _$isRequestingPartnerAtom.reportRead();
    return super.isRequestingPartner;
  }

  @override
  set isRequestingPartner(bool value) {
    _$isRequestingPartnerAtom.reportWrite(value, super.isRequestingPartner, () {
      super.isRequestingPartner = value;
    });
  }

  late final _$requestPartnerErrorAtom = Atom(
      name: '_RegistrationStoreBase.requestPartnerError', context: context);

  @override
  String? get requestPartnerError {
    _$requestPartnerErrorAtom.reportRead();
    return super.requestPartnerError;
  }

  @override
  set requestPartnerError(String? value) {
    _$requestPartnerErrorAtom.reportWrite(value, super.requestPartnerError, () {
      super.requestPartnerError = value;
    });
  }

  late final _$requestPartnerSuccessAtom = Atom(
      name: '_RegistrationStoreBase.requestPartnerSuccess', context: context);

  @override
  bool get requestPartnerSuccess {
    _$requestPartnerSuccessAtom.reportRead();
    return super.requestPartnerSuccess;
  }

  @override
  set requestPartnerSuccess(bool value) {
    _$requestPartnerSuccessAtom.reportWrite(value, super.requestPartnerSuccess,
        () {
      super.requestPartnerSuccess = value;
    });
  }

  late final _$verifyDocumentAsyncAction =
      AsyncAction('_RegistrationStoreBase.verifyDocument', context: context);

  @override
  Future<void> verifyDocument(String documento) {
    return _$verifyDocumentAsyncAction
        .run(() => super.verifyDocument(documento));
  }

  late final _$registerUserAsyncAction =
      AsyncAction('_RegistrationStoreBase.registerUser', context: context);

  @override
  Future<void> registerUser(UserRegistration registration) {
    return _$registerUserAsyncAction
        .run(() => super.registerUser(registration));
  }

  late final _$requestPartnerAsyncAction =
      AsyncAction('_RegistrationStoreBase.requestPartner', context: context);

  @override
  Future<void> requestPartner(PartnerRequest request) {
    return _$requestPartnerAsyncAction.run(() => super.requestPartner(request));
  }

  late final _$_RegistrationStoreBaseActionController =
      ActionController(name: '_RegistrationStoreBase', context: context);

  @override
  void clearVerifyState() {
    final _$actionInfo = _$_RegistrationStoreBaseActionController.startAction(
        name: '_RegistrationStoreBase.clearVerifyState');
    try {
      return super.clearVerifyState();
    } finally {
      _$_RegistrationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearRegisterUserState() {
    final _$actionInfo = _$_RegistrationStoreBaseActionController.startAction(
        name: '_RegistrationStoreBase.clearRegisterUserState');
    try {
      return super.clearRegisterUserState();
    } finally {
      _$_RegistrationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearRequestPartnerState() {
    final _$actionInfo = _$_RegistrationStoreBaseActionController.startAction(
        name: '_RegistrationStoreBase.clearRequestPartnerState');
    try {
      return super.clearRequestPartnerState();
    } finally {
      _$_RegistrationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetAllState() {
    final _$actionInfo = _$_RegistrationStoreBaseActionController.startAction(
        name: '_RegistrationStoreBase.resetAllState');
    try {
      return super.resetAllState();
    } finally {
      _$_RegistrationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isVerifyingDocument: ${isVerifyingDocument},
foundCompany: ${foundCompany},
verifyError: ${verifyError},
isRegisteringUser: ${isRegisteringUser},
registerUserError: ${registerUserError},
registerUserSuccess: ${registerUserSuccess},
isRequestingPartner: ${isRequestingPartner},
requestPartnerError: ${requestPartnerError},
requestPartnerSuccess: ${requestPartnerSuccess},
hasFoundCompany: ${hasFoundCompany},
canProceedToRegistration: ${canProceedToRegistration}
    ''';
  }
}
