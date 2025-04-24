// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetStore on _BudgetStore, Store {
  Computed<List<Map<String, dynamic>>>? _$filteredBudgetsComputed;

  @override
  List<Map<String, dynamic>> get filteredBudgets =>
      (_$filteredBudgetsComputed ??= Computed<List<Map<String, dynamic>>>(
              () => super.filteredBudgets,
              name: '_BudgetStore.filteredBudgets'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_BudgetStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_BudgetStore.error', context: context);

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

  late final _$searchQueryAtom =
      Atom(name: '_BudgetStore.searchQuery', context: context);

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

  late final _$allBudgetsAtom =
      Atom(name: '_BudgetStore.allBudgets', context: context);

  @override
  ObservableList<Map<String, dynamic>> get allBudgets {
    _$allBudgetsAtom.reportRead();
    return super.allBudgets;
  }

  @override
  set allBudgets(ObservableList<Map<String, dynamic>> value) {
    _$allBudgetsAtom.reportWrite(value, super.allBudgets, () {
      super.allBudgets = value;
    });
  }

  late final _$selectedFilterAtom =
      Atom(name: '_BudgetStore.selectedFilter', context: context);

  @override
  String get selectedFilter {
    _$selectedFilterAtom.reportRead();
    return super.selectedFilter;
  }

  @override
  set selectedFilter(String value) {
    _$selectedFilterAtom.reportWrite(value, super.selectedFilter, () {
      super.selectedFilter = value;
    });
  }

  late final _$fetchBudgetsAsyncAction =
      AsyncAction('_BudgetStore.fetchBudgets', context: context);

  @override
  Future<void> fetchBudgets() {
    return _$fetchBudgetsAsyncAction.run(() => super.fetchBudgets());
  }

  late final _$_BudgetStoreActionController =
      ActionController(name: '_BudgetStore', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_BudgetStoreActionController.startAction(
        name: '_BudgetStore.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_BudgetStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedFilter(String filter) {
    final _$actionInfo = _$_BudgetStoreActionController.startAction(
        name: '_BudgetStore.setSelectedFilter');
    try {
      return super.setSelectedFilter(filter);
    } finally {
      _$_BudgetStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
searchQuery: ${searchQuery},
allBudgets: ${allBudgets},
selectedFilter: ${selectedFilter},
filteredBudgets: ${filteredBudgets}
    ''';
  }
}
