// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetListStore on _BudgetListStoreBase, Store {
  late final _$isLoadingAtom =
      Atom(name: '_BudgetListStoreBase.isLoading', context: context);

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
      Atom(name: '_BudgetListStoreBase.error', context: context);

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

  late final _$itemsAtom =
      Atom(name: '_BudgetListStoreBase.items', context: context);

  @override
  ObservableList<BudgetEntity> get items {
    _$itemsAtom.reportRead();
    return super.items;
  }

  @override
  set items(ObservableList<BudgetEntity> value) {
    _$itemsAtom.reportWrite(value, super.items, () {
      super.items = value;
    });
  }

  late final _$allItemsAtom =
      Atom(name: '_BudgetListStoreBase.allItems', context: context);

  @override
  ObservableList<BudgetEntity> get allItems {
    _$allItemsAtom.reportRead();
    return super.allItems;
  }

  @override
  set allItems(ObservableList<BudgetEntity> value) {
    _$allItemsAtom.reportWrite(value, super.allItems, () {
      super.allItems = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_BudgetListStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$selectedFiltersAtom =
      Atom(name: '_BudgetListStoreBase.selectedFilters', context: context);

  @override
  ObservableSet<String> get selectedFilters {
    _$selectedFiltersAtom.reportRead();
    return super.selectedFilters;
  }

  @override
  set selectedFilters(ObservableSet<String> value) {
    _$selectedFiltersAtom.reportWrite(value, super.selectedFilters, () {
      super.selectedFilters = value;
    });
  }

  late final _$fetchAsyncAction =
      AsyncAction('_BudgetListStoreBase.fetch', context: context);

  @override
  Future<void> fetch({String? status}) {
    return _$fetchAsyncAction.run(() => super.fetch(status: status));
  }

  late final _$refreshAsyncAction =
      AsyncAction('_BudgetListStoreBase.refresh', context: context);

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$renameBudgetAsyncAction =
      AsyncAction('_BudgetListStoreBase.renameBudget', context: context);

  @override
  Future<void> renameBudget(int budgetId, String newName) {
    return _$renameBudgetAsyncAction
        .run(() => super.renameBudget(budgetId, newName));
  }

  late final _$deleteBudgetAsyncAction =
      AsyncAction('_BudgetListStoreBase.deleteBudget', context: context);

  @override
  Future<void> deleteBudget(int budgetId) {
    return _$deleteBudgetAsyncAction.run(() => super.deleteBudget(budgetId));
  }

  late final _$_BudgetListStoreBaseActionController =
      ActionController(name: '_BudgetListStoreBase', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_BudgetListStoreBaseActionController.startAction(
        name: '_BudgetListStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_BudgetListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleFilter(String filter) {
    final _$actionInfo = _$_BudgetListStoreBaseActionController.startAction(
        name: '_BudgetListStoreBase.toggleFilter');
    try {
      return super.toggleFilter(filter);
    } finally {
      _$_BudgetListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetFilters() {
    final _$actionInfo = _$_BudgetListStoreBaseActionController.startAction(
        name: '_BudgetListStoreBase.resetFilters');
    try {
      return super.resetFilters();
    } finally {
      _$_BudgetListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void applyFilters() {
    final _$actionInfo = _$_BudgetListStoreBaseActionController.startAction(
        name: '_BudgetListStoreBase.applyFilters');
    try {
      return super.applyFilters();
    } finally {
      _$_BudgetListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
items: ${items},
allItems: ${allItems},
searchQuery: ${searchQuery},
selectedFilters: ${selectedFilters}
    ''';
  }
}
