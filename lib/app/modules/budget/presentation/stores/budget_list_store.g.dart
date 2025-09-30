// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetListStore on _BudgetListStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_BudgetListStore.isLoading', context: context);

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
      Atom(name: '_BudgetListStore.error', context: context);

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
      Atom(name: '_BudgetListStore.items', context: context);

  @override
  List<BudgetSummaryDto> get items {
    _$itemsAtom.reportRead();
    return super.items;
  }

  @override
  set items(List<BudgetSummaryDto> value) {
    _$itemsAtom.reportWrite(value, super.items, () {
      super.items = value;
    });
  }

  late final _$allItemsAtom =
      Atom(name: '_BudgetListStore.allItems', context: context);

  @override
  List<BudgetSummaryDto> get allItems {
    _$allItemsAtom.reportRead();
    return super.allItems;
  }

  @override
  set allItems(List<BudgetSummaryDto> value) {
    _$allItemsAtom.reportWrite(value, super.allItems, () {
      super.allItems = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_BudgetListStore.searchQuery', context: context);

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
      Atom(name: '_BudgetListStore.selectedFilters', context: context);

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
      AsyncAction('_BudgetListStore.fetch', context: context);

  @override
  Future<void> fetch({String? status}) {
    return _$fetchAsyncAction.run(() => super.fetch(status: status));
  }

  late final _$refreshAsyncAction =
      AsyncAction('_BudgetListStore.refresh', context: context);

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$_BudgetListStoreActionController =
      ActionController(name: '_BudgetListStore', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_BudgetListStoreActionController.startAction(
        name: '_BudgetListStore.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_BudgetListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleFilter(String filter) {
    final _$actionInfo = _$_BudgetListStoreActionController.startAction(
        name: '_BudgetListStore.toggleFilter');
    try {
      return super.toggleFilter(filter);
    } finally {
      _$_BudgetListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetFilters() {
    final _$actionInfo = _$_BudgetListStoreActionController.startAction(
        name: '_BudgetListStore.resetFilters');
    try {
      return super.resetFilters();
    } finally {
      _$_BudgetListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void applyFilters() {
    final _$actionInfo = _$_BudgetListStoreActionController.startAction(
        name: '_BudgetListStore.applyFilters');
    try {
      return super.applyFilters();
    } finally {
      _$_BudgetListStoreActionController.endAction(_$actionInfo);
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
