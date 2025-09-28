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

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
items: ${items}
    ''';
  }
}
