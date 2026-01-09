// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_city_census_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MultiCityCensusStore on _MultiCityCensusStoreBase, Store {
  Computed<CensoEscolarEntity?>? _$currentCensusComputed;

  @override
  CensoEscolarEntity? get currentCensus => (_$currentCensusComputed ??=
          Computed<CensoEscolarEntity?>(() => super.currentCensus,
              name: '_MultiCityCensusStoreBase.currentCensus'))
      .value;
  Computed<Map<int, double>>? _$currentEditedValuesComputed;

  @override
  Map<int, double> get currentEditedValues => (_$currentEditedValuesComputed ??=
          Computed<Map<int, double>>(() => super.currentEditedValues,
              name: '_MultiCityCensusStoreBase.currentEditedValues'))
      .value;
  Computed<List<int>>? _$cidadeIdsComputed;

  @override
  List<int> get cidadeIds =>
      (_$cidadeIdsComputed ??= Computed<List<int>>(() => super.cidadeIds,
              name: '_MultiCityCensusStoreBase.cidadeIds'))
          .value;
  Computed<int>? _$quantidadeCidadesComputed;

  @override
  int get quantidadeCidades => (_$quantidadeCidadesComputed ??= Computed<int>(
          () => super.quantidadeCidades,
          name: '_MultiCityCensusStoreBase.quantidadeCidades'))
      .value;
  Computed<bool>? _$hasCitiesComputed;

  @override
  bool get hasCities =>
      (_$hasCitiesComputed ??= Computed<bool>(() => super.hasCities,
              name: '_MultiCityCensusStoreBase.hasCities'))
          .value;
  Computed<double>? _$valorTotalAgregadoComputed;

  @override
  double get valorTotalAgregado => (_$valorTotalAgregadoComputed ??=
          Computed<double>(() => super.valorTotalAgregado,
              name: '_MultiCityCensusStoreBase.valorTotalAgregado'))
      .value;
  Computed<bool>? _$isAggregateModeComputed;

  @override
  bool get isAggregateMode =>
      (_$isAggregateModeComputed ??= Computed<bool>(() => super.isAggregateMode,
              name: '_MultiCityCensusStoreBase.isAggregateMode'))
          .value;
  Computed<Map<int, double>>? _$aggregatedValuesComputed;

  @override
  Map<int, double> get aggregatedValues => (_$aggregatedValuesComputed ??=
          Computed<Map<int, double>>(() => super.aggregatedValues,
              name: '_MultiCityCensusStoreBase.aggregatedValues'))
      .value;
  Computed<Map<String, double>>? _$displayValuesComputed;

  @override
  Map<String, double> get displayValues => (_$displayValuesComputed ??=
          Computed<Map<String, double>>(() => super.displayValues,
              name: '_MultiCityCensusStoreBase.displayValues'))
      .value;

  late final _$budgetNameAtom =
      Atom(name: '_MultiCityCensusStoreBase.budgetName', context: context);

  @override
  String get budgetName {
    _$budgetNameAtom.reportRead();
    return super.budgetName;
  }

  @override
  set budgetName(String value) {
    _$budgetNameAtom.reportWrite(value, super.budgetName, () {
      super.budgetName = value;
    });
  }

  late final _$selectedCitiesAtom =
      Atom(name: '_MultiCityCensusStoreBase.selectedCities', context: context);

  @override
  ObservableList<Map<String, dynamic>> get selectedCities {
    _$selectedCitiesAtom.reportRead();
    return super.selectedCities;
  }

  @override
  set selectedCities(ObservableList<Map<String, dynamic>> value) {
    _$selectedCitiesAtom.reportWrite(value, super.selectedCities, () {
      super.selectedCities = value;
    });
  }

  late final _$censusPerCityAtom =
      Atom(name: '_MultiCityCensusStoreBase.censusPerCity', context: context);

  @override
  ObservableMap<int, CensoEscolarEntity> get censusPerCity {
    _$censusPerCityAtom.reportRead();
    return super.censusPerCity;
  }

  @override
  set censusPerCity(ObservableMap<int, CensoEscolarEntity> value) {
    _$censusPerCityAtom.reportWrite(value, super.censusPerCity, () {
      super.censusPerCity = value;
    });
  }

  late final _$selectedCityIdAtom =
      Atom(name: '_MultiCityCensusStoreBase.selectedCityId', context: context);

  @override
  int? get selectedCityId {
    _$selectedCityIdAtom.reportRead();
    return super.selectedCityId;
  }

  @override
  set selectedCityId(int? value) {
    _$selectedCityIdAtom.reportWrite(value, super.selectedCityId, () {
      super.selectedCityId = value;
    });
  }

  late final _$editedValuesPerCityAtom = Atom(
      name: '_MultiCityCensusStoreBase.editedValuesPerCity', context: context);

  @override
  ObservableMap<int, ObservableMap<int, double>> get editedValuesPerCity {
    _$editedValuesPerCityAtom.reportRead();
    return super.editedValuesPerCity;
  }

  @override
  set editedValuesPerCity(
      ObservableMap<int, ObservableMap<int, double>> value) {
    _$editedValuesPerCityAtom.reportWrite(value, super.editedValuesPerCity, () {
      super.editedValuesPerCity = value;
    });
  }

  late final _$shouldOpenCityModalAtom = Atom(
      name: '_MultiCityCensusStoreBase.shouldOpenCityModal', context: context);

  @override
  bool get shouldOpenCityModal {
    _$shouldOpenCityModalAtom.reportRead();
    return super.shouldOpenCityModal;
  }

  @override
  set shouldOpenCityModal(bool value) {
    _$shouldOpenCityModalAtom.reportWrite(value, super.shouldOpenCityModal, () {
      super.shouldOpenCityModal = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_MultiCityCensusStoreBase.isLoading', context: context);

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
      Atom(name: '_MultiCityCensusStoreBase.isSaving', context: context);

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
      Atom(name: '_MultiCityCensusStoreBase.error', context: context);

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

  late final _$loadCensusForCitiesAsyncAction = AsyncAction(
      '_MultiCityCensusStoreBase.loadCensusForCities',
      context: context);

  @override
  Future<void> loadCensusForCities() {
    return _$loadCensusForCitiesAsyncAction
        .run(() => super.loadCensusForCities());
  }

  late final _$createBudgetAsyncAction =
      AsyncAction('_MultiCityCensusStoreBase.createBudget', context: context);

  @override
  Future<int?> createBudget() {
    return _$createBudgetAsyncAction.run(() => super.createBudget());
  }

  late final _$_MultiCityCensusStoreBaseActionController =
      ActionController(name: '_MultiCityCensusStoreBase', context: context);

  @override
  void setBudgetName(String name) {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.setBudgetName');
    try {
      return super.setBudgetName(name);
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedCities(List<Map<String, dynamic>> cities) {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.setSelectedCities');
    try {
      return super.setSelectedCities(cities);
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addCity(Map<String, dynamic> city) {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.addCity');
    try {
      return super.addCity(city);
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeCity(int cityId) {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.removeCity');
    try {
      return super.removeCity(cityId);
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectCity(int? cityId) {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.selectCity');
    try {
      return super.selectCity(cityId);
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void markModalOpened() {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.markModalOpened');
    try {
      return super.markModalOpened();
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateValue(int cityId, String nomeEtapa, double value) {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.updateValue');
    try {
      return super.updateValue(cityId, nomeEtapa, value);
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clear() {
    final _$actionInfo = _$_MultiCityCensusStoreBaseActionController
        .startAction(name: '_MultiCityCensusStoreBase.clear');
    try {
      return super.clear();
    } finally {
      _$_MultiCityCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
budgetName: ${budgetName},
selectedCities: ${selectedCities},
censusPerCity: ${censusPerCity},
selectedCityId: ${selectedCityId},
editedValuesPerCity: ${editedValuesPerCity},
shouldOpenCityModal: ${shouldOpenCityModal},
isLoading: ${isLoading},
isSaving: ${isSaving},
error: ${error},
currentCensus: ${currentCensus},
currentEditedValues: ${currentEditedValues},
cidadeIds: ${cidadeIds},
quantidadeCidades: ${quantidadeCidades},
hasCities: ${hasCities},
valorTotalAgregado: ${valorTotalAgregado},
isAggregateMode: ${isAggregateMode},
aggregatedValues: ${aggregatedValues},
displayValues: ${displayValues}
    ''';
  }
}
