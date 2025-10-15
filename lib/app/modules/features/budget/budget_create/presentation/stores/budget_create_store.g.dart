// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_create_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetCreateStore on _BudgetCreateStoreBase, Store {
  Computed<bool>? _$isFormValidComputed;

  @override
  bool get isFormValid =>
      (_$isFormValidComputed ??= Computed<bool>(() => super.isFormValid,
              name: '_BudgetCreateStoreBase.isFormValid'))
          .value;
  Computed<bool>? _$isEmailValidComputed;

  @override
  bool get isEmailValid =>
      (_$isEmailValidComputed ??= Computed<bool>(() => super.isEmailValid,
              name: '_BudgetCreateStoreBase.isEmailValid'))
          .value;
  Computed<String?>? _$locationDisplayComputed;

  @override
  String? get locationDisplay => (_$locationDisplayComputed ??=
          Computed<String?>(() => super.locationDisplay,
              name: '_BudgetCreateStoreBase.locationDisplay'))
      .value;
  Computed<bool>? _$hasPartnersComputed;

  @override
  bool get hasPartners =>
      (_$hasPartnersComputed ??= Computed<bool>(() => super.hasPartners,
              name: '_BudgetCreateStoreBase.hasPartners'))
          .value;
  Computed<bool>? _$isLocationCompleteComputed;

  @override
  bool get isLocationComplete => (_$isLocationCompleteComputed ??=
          Computed<bool>(() => super.isLocationComplete,
              name: '_BudgetCreateStoreBase.isLocationComplete'))
      .value;

  late final _$isLoadingAtom =
      Atom(name: '_BudgetCreateStoreBase.isLoading', context: context);

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

  late final _$isLoadingPartnersAtom =
      Atom(name: '_BudgetCreateStoreBase.isLoadingPartners', context: context);

  @override
  bool get isLoadingPartners {
    _$isLoadingPartnersAtom.reportRead();
    return super.isLoadingPartners;
  }

  @override
  set isLoadingPartners(bool value) {
    _$isLoadingPartnersAtom.reportWrite(value, super.isLoadingPartners, () {
      super.isLoadingPartners = value;
    });
  }

  late final _$isCreatingDraftAtom =
      Atom(name: '_BudgetCreateStoreBase.isCreatingDraft', context: context);

  @override
  bool get isCreatingDraft {
    _$isCreatingDraftAtom.reportRead();
    return super.isCreatingDraft;
  }

  @override
  set isCreatingDraft(bool value) {
    _$isCreatingDraftAtom.reportWrite(value, super.isCreatingDraft, () {
      super.isCreatingDraft = value;
    });
  }

  late final _$errorAtom =
      Atom(name: '_BudgetCreateStoreBase.error', context: context);

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

  late final _$partnerErrorAtom =
      Atom(name: '_BudgetCreateStoreBase.partnerError', context: context);

  @override
  String? get partnerError {
    _$partnerErrorAtom.reportRead();
    return super.partnerError;
  }

  @override
  set partnerError(String? value) {
    _$partnerErrorAtom.reportWrite(value, super.partnerError, () {
      super.partnerError = value;
    });
  }

  late final _$validationErrorAtom =
      Atom(name: '_BudgetCreateStoreBase.validationError', context: context);

  @override
  String? get validationError {
    _$validationErrorAtom.reportRead();
    return super.validationError;
  }

  @override
  set validationError(String? value) {
    _$validationErrorAtom.reportWrite(value, super.validationError, () {
      super.validationError = value;
    });
  }

  late final _$partnersAtom =
      Atom(name: '_BudgetCreateStoreBase.partners', context: context);

  @override
  ObservableList<PartnerEntity> get partners {
    _$partnersAtom.reportRead();
    return super.partners;
  }

  @override
  set partners(ObservableList<PartnerEntity> value) {
    _$partnersAtom.reportWrite(value, super.partners, () {
      super.partners = value;
    });
  }

  late final _$selectedPartnerAtom =
      Atom(name: '_BudgetCreateStoreBase.selectedPartner', context: context);

  @override
  PartnerEntity? get selectedPartner {
    _$selectedPartnerAtom.reportRead();
    return super.selectedPartner;
  }

  @override
  set selectedPartner(PartnerEntity? value) {
    _$selectedPartnerAtom.reportWrite(value, super.selectedPartner, () {
      super.selectedPartner = value;
    });
  }

  late final _$selectedStateCodeAtom =
      Atom(name: '_BudgetCreateStoreBase.selectedStateCode', context: context);

  @override
  String? get selectedStateCode {
    _$selectedStateCodeAtom.reportRead();
    return super.selectedStateCode;
  }

  @override
  set selectedStateCode(String? value) {
    _$selectedStateCodeAtom.reportWrite(value, super.selectedStateCode, () {
      super.selectedStateCode = value;
    });
  }

  late final _$selectedStateNameAtom =
      Atom(name: '_BudgetCreateStoreBase.selectedStateName', context: context);

  @override
  String? get selectedStateName {
    _$selectedStateNameAtom.reportRead();
    return super.selectedStateName;
  }

  @override
  set selectedStateName(String? value) {
    _$selectedStateNameAtom.reportWrite(value, super.selectedStateName, () {
      super.selectedStateName = value;
    });
  }

  late final _$selectedCityCodeAtom =
      Atom(name: '_BudgetCreateStoreBase.selectedCityCode', context: context);

  @override
  String? get selectedCityCode {
    _$selectedCityCodeAtom.reportRead();
    return super.selectedCityCode;
  }

  @override
  set selectedCityCode(String? value) {
    _$selectedCityCodeAtom.reportWrite(value, super.selectedCityCode, () {
      super.selectedCityCode = value;
    });
  }

  late final _$selectedCityNameAtom =
      Atom(name: '_BudgetCreateStoreBase.selectedCityName', context: context);

  @override
  String? get selectedCityName {
    _$selectedCityNameAtom.reportRead();
    return super.selectedCityName;
  }

  @override
  set selectedCityName(String? value) {
    _$selectedCityNameAtom.reportWrite(value, super.selectedCityName, () {
      super.selectedCityName = value;
    });
  }

  late final _$responsibleNameAtom =
      Atom(name: '_BudgetCreateStoreBase.responsibleName', context: context);

  @override
  String? get responsibleName {
    _$responsibleNameAtom.reportRead();
    return super.responsibleName;
  }

  @override
  set responsibleName(String? value) {
    _$responsibleNameAtom.reportWrite(value, super.responsibleName, () {
      super.responsibleName = value;
    });
  }

  late final _$responsibleEmailAtom =
      Atom(name: '_BudgetCreateStoreBase.responsibleEmail', context: context);

  @override
  String? get responsibleEmail {
    _$responsibleEmailAtom.reportRead();
    return super.responsibleEmail;
  }

  @override
  set responsibleEmail(String? value) {
    _$responsibleEmailAtom.reportWrite(value, super.responsibleEmail, () {
      super.responsibleEmail = value;
    });
  }

  late final _$validityDateAtom =
      Atom(name: '_BudgetCreateStoreBase.validityDate', context: context);

  @override
  DateTime? get validityDate {
    _$validityDateAtom.reportRead();
    return super.validityDate;
  }

  @override
  set validityDate(DateTime? value) {
    _$validityDateAtom.reportWrite(value, super.validityDate, () {
      super.validityDate = value;
    });
  }

  late final _$createdDraftAtom =
      Atom(name: '_BudgetCreateStoreBase.createdDraft', context: context);

  @override
  BudgetDraftEntity? get createdDraft {
    _$createdDraftAtom.reportRead();
    return super.createdDraft;
  }

  @override
  set createdDraft(BudgetDraftEntity? value) {
    _$createdDraftAtom.reportWrite(value, super.createdDraft, () {
      super.createdDraft = value;
    });
  }

  late final _$loadPartnersAsyncAction =
      AsyncAction('_BudgetCreateStoreBase.loadPartners', context: context);

  @override
  Future<void> loadPartners() {
    return _$loadPartnersAsyncAction.run(() => super.loadPartners());
  }

  late final _$validateFormAsyncAction =
      AsyncAction('_BudgetCreateStoreBase.validateForm', context: context);

  @override
  Future<bool> validateForm(int partnerId) {
    return _$validateFormAsyncAction.run(() => super.validateForm(partnerId));
  }

  late final _$createDraftAsyncAction =
      AsyncAction('_BudgetCreateStoreBase.createDraft', context: context);

  @override
  Future<bool> createDraft(int partnerId) {
    return _$createDraftAsyncAction.run(() => super.createDraft(partnerId));
  }

  late final _$_BudgetCreateStoreBaseActionController =
      ActionController(name: '_BudgetCreateStoreBase', context: context);

  @override
  void selectPartner(PartnerEntity partner) {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.selectPartner');
    try {
      return super.selectPartner(partner);
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPartner() {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.clearPartner');
    try {
      return super.clearPartner();
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedState(String code, String name) {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.setSelectedState');
    try {
      return super.setSelectedState(code, name);
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedCity(String code, String name) {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.setSelectedCity');
    try {
      return super.setSelectedCity(code, name);
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearLocation() {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.clearLocation');
    try {
      return super.clearLocation();
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setResponsibleName(String? name) {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.setResponsibleName');
    try {
      return super.setResponsibleName(name);
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setResponsibleEmail(String? email) {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.setResponsibleEmail');
    try {
      return super.setResponsibleEmail(email);
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValidityDate(DateTime? date) {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.setValidityDate');
    try {
      return super.setValidityDate(date);
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearForm() {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.clearForm');
    try {
      return super.clearForm();
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearErrors() {
    final _$actionInfo = _$_BudgetCreateStoreBaseActionController.startAction(
        name: '_BudgetCreateStoreBase.clearErrors');
    try {
      return super.clearErrors();
    } finally {
      _$_BudgetCreateStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isLoadingPartners: ${isLoadingPartners},
isCreatingDraft: ${isCreatingDraft},
error: ${error},
partnerError: ${partnerError},
validationError: ${validationError},
partners: ${partners},
selectedPartner: ${selectedPartner},
selectedStateCode: ${selectedStateCode},
selectedStateName: ${selectedStateName},
selectedCityCode: ${selectedCityCode},
selectedCityName: ${selectedCityName},
responsibleName: ${responsibleName},
responsibleEmail: ${responsibleEmail},
validityDate: ${validityDate},
createdDraft: ${createdDraft},
isFormValid: ${isFormValid},
isEmailValid: ${isEmailValid},
locationDisplay: ${locationDisplay},
hasPartners: ${hasPartners},
isLocationComplete: ${isLocationComplete}
    ''';
  }
}
