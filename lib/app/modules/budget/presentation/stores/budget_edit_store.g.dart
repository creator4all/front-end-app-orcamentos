// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_edit_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetEditStore on _BudgetEditStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_BudgetEditStore.isLoading', context: context);

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

  late final _$errorAtom =
      Atom(name: '_BudgetEditStore.error', context: context);

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
      Atom(name: '_BudgetEditStore.budgetData', context: context);

  @override
  Map<String, dynamic>? get budgetData {
    _$budgetDataAtom.reportRead();
    return super.budgetData;
  }

  @override
  set budgetData(Map<String, dynamic>? value) {
    _$budgetDataAtom.reportWrite(value, super.budgetData, () {
      super.budgetData = value;
    });
  }

  late final _$censoDataRawAtom =
      Atom(name: '_BudgetEditStore.censoDataRaw', context: context);

  @override
  Map<String, dynamic>? get censoDataRaw {
    _$censoDataRawAtom.reportRead();
    return super.censoDataRaw;
  }

  @override
  set censoDataRaw(Map<String, dynamic>? value) {
    _$censoDataRawAtom.reportWrite(value, super.censoDataRaw, () {
      super.censoDataRaw = value;
    });
  }

  late final _$censoDataAtom =
      Atom(name: '_BudgetEditStore.censoData', context: context);

  @override
  CensoData? get censoData {
    _$censoDataAtom.reportRead();
    return super.censoData;
  }

  @override
  set censoData(CensoData? value) {
    _$censoDataAtom.reportWrite(value, super.censoData, () {
      super.censoData = value;
    });
  }

  late final _$loadBudgetDetailsAsyncAction =
      AsyncAction('_BudgetEditStore.loadBudgetDetails', context: context);

  @override
  Future<void> loadBudgetDetails(int budgetId) {
    return _$loadBudgetDetailsAsyncAction
        .run(() => super.loadBudgetDetails(budgetId));
  }

  late final _$_BudgetEditStoreActionController =
      ActionController(name: '_BudgetEditStore', context: context);

  @override
  void _loadProductsFromApi() {
    final _$actionInfo = _$_BudgetEditStoreActionController.startAction(
        name: '_BudgetEditStore._loadProductsFromApi');
    try {
      return super._loadProductsFromApi();
    } finally {
      _$_BudgetEditStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _loadCensoData() {
    final _$actionInfo = _$_BudgetEditStoreActionController.startAction(
        name: '_BudgetEditStore._loadCensoData');
    try {
      return super._loadCensoData();
    } finally {
      _$_BudgetEditStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_BudgetEditStoreActionController.startAction(
        name: '_BudgetEditStore.reset');
    try {
      return super.reset();
    } finally {
      _$_BudgetEditStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
budgetData: ${budgetData},
censoDataRaw: ${censoDataRaw},
censoData: ${censoData}
    ''';
  }
}
