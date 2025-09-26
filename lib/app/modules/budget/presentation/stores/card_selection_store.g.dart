// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_selection_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CardSelectionStore on _CardSelectionStore, Store {
  Computed<int>? _$selectedCardsCountComputed;

  @override
  int get selectedCardsCount => (_$selectedCardsCountComputed ??= Computed<int>(
          () => super.selectedCardsCount,
          name: '_CardSelectionStore.selectedCardsCount'))
      .value;

  late final _$mainCardsSelectionAtom =
      Atom(name: '_CardSelectionStore.mainCardsSelection', context: context);

  @override
  ObservableMap<String, bool> get mainCardsSelection {
    _$mainCardsSelectionAtom.reportRead();
    return super.mainCardsSelection;
  }

  @override
  set mainCardsSelection(ObservableMap<String, bool> value) {
    _$mainCardsSelectionAtom.reportWrite(value, super.mainCardsSelection, () {
      super.mainCardsSelection = value;
    });
  }

  late final _$subcategoriesSelectionAtom = Atom(
      name: '_CardSelectionStore.subcategoriesSelection', context: context);

  @override
  ObservableMap<int, bool> get subcategoriesSelection {
    _$subcategoriesSelectionAtom.reportRead();
    return super.subcategoriesSelection;
  }

  @override
  set subcategoriesSelection(ObservableMap<int, bool> value) {
    _$subcategoriesSelectionAtom
        .reportWrite(value, super.subcategoriesSelection, () {
      super.subcategoriesSelection = value;
    });
  }

  late final _$_CardSelectionStoreActionController =
      ActionController(name: '_CardSelectionStore', context: context);

  @override
  void setMainCardSelected(String cardName, bool selected) {
    final _$actionInfo = _$_CardSelectionStoreActionController.startAction(
        name: '_CardSelectionStore.setMainCardSelected');
    try {
      return super.setMainCardSelected(cardName, selected);
    } finally {
      _$_CardSelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSubcategorySelected(int subcategoryId, bool selected) {
    final _$actionInfo = _$_CardSelectionStoreActionController.startAction(
        name: '_CardSelectionStore.setSubcategorySelected');
    try {
      return super.setSubcategorySelected(subcategoryId, selected);
    } finally {
      _$_CardSelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSubcategorySelections() {
    final _$actionInfo = _$_CardSelectionStoreActionController.startAction(
        name: '_CardSelectionStore.clearSubcategorySelections');
    try {
      return super.clearSubcategorySelections();
    } finally {
      _$_CardSelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
mainCardsSelection: ${mainCardsSelection},
subcategoriesSelection: ${subcategoriesSelection},
selectedCardsCount: ${selectedCardsCount}
    ''';
  }
}
