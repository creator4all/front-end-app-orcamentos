// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_edit_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetEditStore on _BudgetEditStoreBase, Store {
  Computed<bool>? _$hasDataComputed;

  @override
  bool get hasData => (_$hasDataComputed ??= Computed<bool>(() => super.hasData,
          name: '_BudgetEditStoreBase.hasData'))
      .value;
  Computed<bool>? _$canSaveComputed;

  @override
  bool get canSave => (_$canSaveComputed ??= Computed<bool>(() => super.canSave,
          name: '_BudgetEditStoreBase.canSave'))
      .value;
  Computed<int>? _$selectedProductsCountComputed;

  @override
  int get selectedProductsCount => (_$selectedProductsCountComputed ??=
          Computed<int>(() => super.selectedProductsCount,
              name: '_BudgetEditStoreBase.selectedProductsCount'))
      .value;
  Computed<double>? _$totalValueComputed;

  @override
  double get totalValue =>
      (_$totalValueComputed ??= Computed<double>(() => super.totalValue,
              name: '_BudgetEditStoreBase.totalValue'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_BudgetEditStoreBase.isLoading', context: context);

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
      Atom(name: '_BudgetEditStoreBase.isSaving', context: context);

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
      Atom(name: '_BudgetEditStoreBase.error', context: context);

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

  late final _$budgetDataAtom =
      Atom(name: '_BudgetEditStoreBase.budgetData', context: context);

  @override
  BudgetEditEntity? get budgetData {
    _$budgetDataAtom.reportRead();
    return super.budgetData;
  }

  @override
  set budgetData(BudgetEditEntity? value) {
    _$budgetDataAtom.reportWrite(value, super.budgetData, () {
      super.budgetData = value;
    });
  }

  late final _$selectedStatusAtom =
      Atom(name: '_BudgetEditStoreBase.selectedStatus', context: context);

  @override
  String get selectedStatus {
    _$selectedStatusAtom.reportRead();
    return super.selectedStatus;
  }

  @override
  set selectedStatus(String value) {
    _$selectedStatusAtom.reportWrite(value, super.selectedStatus, () {
      super.selectedStatus = value;
    });
  }

  late final _$isArchivedAtom =
      Atom(name: '_BudgetEditStoreBase.isArchived', context: context);

  @override
  bool get isArchived {
    _$isArchivedAtom.reportRead();
    return super.isArchived;
  }

  @override
  set isArchived(bool value) {
    _$isArchivedAtom.reportWrite(value, super.isArchived, () {
      super.isArchived = value;
    });
  }

  late final _$validityDateAtom =
      Atom(name: '_BudgetEditStoreBase.validityDate', context: context);

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

  late final _$selectedProductIdsAtom =
      Atom(name: '_BudgetEditStoreBase.selectedProductIds', context: context);

  @override
  ObservableSet<int> get selectedProductIds {
    _$selectedProductIdsAtom.reportRead();
    return super.selectedProductIds;
  }

  @override
  set selectedProductIds(ObservableSet<int> value) {
    _$selectedProductIdsAtom.reportWrite(value, super.selectedProductIds, () {
      super.selectedProductIds = value;
    });
  }

  late final _$loadBudgetForEditAsyncAction =
      AsyncAction('_BudgetEditStoreBase.loadBudgetForEdit', context: context);

  @override
  Future<void> loadBudgetForEdit(int budgetId) {
    return _$loadBudgetForEditAsyncAction
        .run(() => super.loadBudgetForEdit(budgetId));
  }

  late final _$saveBudgetAsyncAction =
      AsyncAction('_BudgetEditStoreBase.saveBudget', context: context);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudget() {
    return _$saveBudgetAsyncAction.run(() => super.saveBudget());
  }

  late final _$_BudgetEditStoreBaseActionController =
      ActionController(name: '_BudgetEditStoreBase', context: context);

  @override
  void toggleProductSelection(int productId) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.toggleProductSelection');
    try {
      return super.toggleProductSelection(productId);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectAllProductsForSubcategory(int subcategoryId, bool selected) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.selectAllProductsForSubcategory');
    try {
      return super.selectAllProductsForSubcategory(subcategoryId, selected);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStatus(String status) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.setStatus');
    try {
      return super.setStatus(status);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setArchived(bool archived) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.setArchived');
    try {
      return super.setArchived(archived);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValidityDate(DateTime? date) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.setValidityDate');
    try {
      return super.setValidityDate(date);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isSaving: ${isSaving},
error: ${error},
budgetData: ${budgetData},
selectedStatus: ${selectedStatus},
isArchived: ${isArchived},
validityDate: ${validityDate},
selectedProductIds: ${selectedProductIds},
hasData: ${hasData},
canSave: ${canSave},
selectedProductsCount: ${selectedProductsCount},
totalValue: ${totalValue}
    ''';
  }
}
