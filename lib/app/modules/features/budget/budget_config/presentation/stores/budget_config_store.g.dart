// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_config_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetConfigStore on _BudgetConfigStoreBase, Store {
  Computed<bool>? _$canFinalizeComputed;

  @override
  bool get canFinalize =>
      (_$canFinalizeComputed ??= Computed<bool>(() => super.canFinalize,
              name: '_BudgetConfigStoreBase.canFinalize'))
          .value;
  Computed<int>? _$selectedCategoriesCountComputed;

  @override
  int get selectedCategoriesCount => (_$selectedCategoriesCountComputed ??=
          Computed<int>(() => super.selectedCategoriesCount,
              name: '_BudgetConfigStoreBase.selectedCategoriesCount'))
      .value;
  Computed<double>? _$totalValueComputed;

  @override
  double get totalValue =>
      (_$totalValueComputed ??= Computed<double>(() => super.totalValue,
              name: '_BudgetConfigStoreBase.totalValue'))
          .value;
  Computed<int>? _$selectedProductsCountComputed;

  @override
  int get selectedProductsCount => (_$selectedProductsCountComputed ??=
          Computed<int>(() => super.selectedProductsCount,
              name: '_BudgetConfigStoreBase.selectedProductsCount'))
      .value;
  Computed<bool>? _$hasDataComputed;

  @override
  bool get hasData => (_$hasDataComputed ??= Computed<bool>(() => super.hasData,
          name: '_BudgetConfigStoreBase.hasData'))
      .value;
  Computed<bool>? _$hasCensusDataComputed;

  @override
  bool get hasCensusData =>
      (_$hasCensusDataComputed ??= Computed<bool>(() => super.hasCensusData,
              name: '_BudgetConfigStoreBase.hasCensusData'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_BudgetConfigStoreBase.isLoading', context: context);

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

  late final _$isLoadingCensusAtom =
      Atom(name: '_BudgetConfigStoreBase.isLoadingCensus', context: context);

  @override
  bool get isLoadingCensus {
    _$isLoadingCensusAtom.reportRead();
    return super.isLoadingCensus;
  }

  @override
  set isLoadingCensus(bool value) {
    _$isLoadingCensusAtom.reportWrite(value, super.isLoadingCensus, () {
      super.isLoadingCensus = value;
    });
  }

  late final _$isSavingAtom =
      Atom(name: '_BudgetConfigStoreBase.isSaving', context: context);

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
      Atom(name: '_BudgetConfigStoreBase.error', context: context);

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

  late final _$budgetDetailAtom =
      Atom(name: '_BudgetConfigStoreBase.budgetDetail', context: context);

  @override
  BudgetDetailEntity? get budgetDetail {
    _$budgetDetailAtom.reportRead();
    return super.budgetDetail;
  }

  @override
  set budgetDetail(BudgetDetailEntity? value) {
    _$budgetDetailAtom.reportWrite(value, super.budgetDetail, () {
      super.budgetDetail = value;
    });
  }

  late final _$censusDataAtom =
      Atom(name: '_BudgetConfigStoreBase.censusData', context: context);

  @override
  CensusDataEntity? get censusData {
    _$censusDataAtom.reportRead();
    return super.censusData;
  }

  @override
  set censusData(CensusDataEntity? value) {
    _$censusDataAtom.reportWrite(value, super.censusData, () {
      super.censusData = value;
    });
  }

  late final _$categoryStatesAtom =
      Atom(name: '_BudgetConfigStoreBase.categoryStates', context: context);

  @override
  ObservableMap<String, bool> get categoryStates {
    _$categoryStatesAtom.reportRead();
    return super.categoryStates;
  }

  @override
  set categoryStates(ObservableMap<String, bool> value) {
    _$categoryStatesAtom.reportWrite(value, super.categoryStates, () {
      super.categoryStates = value;
    });
  }

  late final _$validityDateAtom =
      Atom(name: '_BudgetConfigStoreBase.validityDate', context: context);

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

  late final _$budgetNameAtom =
      Atom(name: '_BudgetConfigStoreBase.budgetName', context: context);

  @override
  String? get budgetName {
    _$budgetNameAtom.reportRead();
    return super.budgetName;
  }

  @override
  set budgetName(String? value) {
    _$budgetNameAtom.reportWrite(value, super.budgetName, () {
      super.budgetName = value;
    });
  }

  late final _$initializeAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.initialize', context: context);

  @override
  Future<void> initialize(int budgetId) {
    return _$initializeAsyncAction.run(() => super.initialize(budgetId));
  }

  late final _$loadBudgetDetailAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.loadBudgetDetail', context: context);

  @override
  Future<void> loadBudgetDetail(int budgetId) {
    return _$loadBudgetDetailAsyncAction
        .run(() => super.loadBudgetDetail(budgetId));
  }

  late final _$loadCensusDataAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.loadCensusData', context: context);

  @override
  Future<void> loadCensusData(int cityId) {
    return _$loadCensusDataAsyncAction.run(() => super.loadCensusData(cityId));
  }

  late final _$finalizeBudgetAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.finalizeBudget', context: context);

  @override
  Future<Either<BudgetFailure, BudgetDetailEntity>> finalizeBudget() {
    return _$finalizeBudgetAsyncAction.run(() => super.finalizeBudget());
  }

  late final _$_BudgetConfigStoreBaseActionController =
      ActionController(name: '_BudgetConfigStoreBase', context: context);

  @override
  void toggleCategory(String categoryKey) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.toggleCategory');
    try {
      return super.toggleCategory(categoryKey);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValidityDate(DateTime? date) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.setValidityDate');
    try {
      return super.setValidityDate(date);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBudgetName(String? name) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.setBudgetName');
    try {
      return super.setBudgetName(name);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isLoadingCensus: ${isLoadingCensus},
isSaving: ${isSaving},
error: ${error},
budgetDetail: ${budgetDetail},
censusData: ${censusData},
categoryStates: ${categoryStates},
validityDate: ${validityDate},
budgetName: ${budgetName},
canFinalize: ${canFinalize},
selectedCategoriesCount: ${selectedCategoriesCount},
totalValue: ${totalValue},
selectedProductsCount: ${selectedProductsCount},
hasData: ${hasData},
hasCensusData: ${hasCensusData}
    ''';
  }
}
