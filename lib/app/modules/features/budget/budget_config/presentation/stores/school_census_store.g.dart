// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_census_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SchoolCensusStore on _SchoolCensusStoreBase, Store {
  Computed<double>? _$totalStudentsComputed;

  @override
  double get totalStudents =>
      (_$totalStudentsComputed ??= Computed<double>(() => super.totalStudents,
              name: '_SchoolCensusStoreBase.totalStudents'))
          .value;
  Computed<bool>? _$hasChangesComputed;

  @override
  bool get hasChanges =>
      (_$hasChangesComputed ??= Computed<bool>(() => super.hasChanges,
              name: '_SchoolCensusStoreBase.hasChanges'))
          .value;

  late final _$censoEscolarAtom =
      Atom(name: '_SchoolCensusStoreBase.censoEscolar', context: context);

  @override
  CensoEscolarEntity? get censoEscolar {
    _$censoEscolarAtom.reportRead();
    return super.censoEscolar;
  }

  @override
  set censoEscolar(CensoEscolarEntity? value) {
    _$censoEscolarAtom.reportWrite(value, super.censoEscolar, () {
      super.censoEscolar = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_SchoolCensusStoreBase.isLoading', context: context);

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
      Atom(name: '_SchoolCensusStoreBase.isSaving', context: context);

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

  late final _$isEditModeAtom =
      Atom(name: '_SchoolCensusStoreBase.isEditMode', context: context);

  @override
  bool get isEditMode {
    _$isEditModeAtom.reportRead();
    return super.isEditMode;
  }

  @override
  set isEditMode(bool value) {
    _$isEditModeAtom.reportWrite(value, super.isEditMode, () {
      super.isEditMode = value;
    });
  }

  late final _$errorAtom =
      Atom(name: '_SchoolCensusStoreBase.error', context: context);

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

  late final _$editedValuesAtom =
      Atom(name: '_SchoolCensusStoreBase.editedValues', context: context);

  @override
  ObservableMap<int, double> get editedValues {
    _$editedValuesAtom.reportRead();
    return super.editedValues;
  }

  @override
  set editedValues(ObservableMap<int, double> value) {
    _$editedValuesAtom.reportWrite(value, super.editedValues, () {
      super.editedValues = value;
    });
  }

  late final _$loadCensusAsyncAction =
      AsyncAction('_SchoolCensusStoreBase.loadCensus', context: context);

  @override
  Future<void> loadCensus(int cityId) {
    return _$loadCensusAsyncAction.run(() => super.loadCensus(cityId));
  }

  late final _$saveCensusAsyncAction =
      AsyncAction('_SchoolCensusStoreBase.saveCensus', context: context);

  @override
  Future<void> saveCensus() {
    return _$saveCensusAsyncAction.run(() => super.saveCensus());
  }

  late final _$_SchoolCensusStoreBaseActionController =
      ActionController(name: '_SchoolCensusStoreBase', context: context);

  @override
  void toggleEditMode() {
    final _$actionInfo = _$_SchoolCensusStoreBaseActionController.startAction(
        name: '_SchoolCensusStoreBase.toggleEditMode');
    try {
      return super.toggleEditMode();
    } finally {
      _$_SchoolCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateValue(int indiceId, double value) {
    final _$actionInfo = _$_SchoolCensusStoreBaseActionController.startAction(
        name: '_SchoolCensusStoreBase.updateValue');
    try {
      return super.updateValue(indiceId, value);
    } finally {
      _$_SchoolCensusStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
censoEscolar: ${censoEscolar},
isLoading: ${isLoading},
isSaving: ${isSaving},
isEditMode: ${isEditMode},
error: ${error},
editedValues: ${editedValues},
totalStudents: ${totalStudents},
hasChanges: ${hasChanges}
    ''';
  }
}
