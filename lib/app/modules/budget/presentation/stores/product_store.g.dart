// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductStore on _ProductStore, Store {
  Computed<double>? _$totalComputed;

  @override
  double get total => (_$totalComputed ??=
          Computed<double>(() => super.total, name: '_ProductStore.total'))
      .value;
  Computed<List<ProductDto>>? _$allProductsComputed;

  @override
  List<ProductDto> get allProducts => (_$allProductsComputed ??=
          Computed<List<ProductDto>>(() => super.allProducts,
              name: '_ProductStore.allProducts'))
      .value;
  Computed<int>? _$selectedCountComputed;

  @override
  int get selectedCount =>
      (_$selectedCountComputed ??= Computed<int>(() => super.selectedCount,
              name: '_ProductStore.selectedCount'))
          .value;

  late final _$produtosAtom =
      Atom(name: '_ProductStore.produtos', context: context);

  @override
  List<ProductDto> get produtos {
    _$produtosAtom.reportRead();
    return super.produtos;
  }

  @override
  set produtos(List<ProductDto> value) {
    _$produtosAtom.reportWrite(value, super.produtos, () {
      super.produtos = value;
    });
  }

  late final _$produtosPorSubcategoriaAtom =
      Atom(name: '_ProductStore.produtosPorSubcategoria', context: context);

  @override
  ObservableMap<int, List<ProductDto>> get produtosPorSubcategoria {
    _$produtosPorSubcategoriaAtom.reportRead();
    return super.produtosPorSubcategoria;
  }

  @override
  set produtosPorSubcategoria(ObservableMap<int, List<ProductDto>> value) {
    _$produtosPorSubcategoriaAtom
        .reportWrite(value, super.produtosPorSubcategoria, () {
      super.produtosPorSubcategoria = value;
    });
  }

  late final _$produtosPorIdAtom =
      Atom(name: '_ProductStore.produtosPorId', context: context);

  @override
  ObservableMap<int, ProductDto> get produtosPorId {
    _$produtosPorIdAtom.reportRead();
    return super.produtosPorId;
  }

  @override
  set produtosPorId(ObservableMap<int, ProductDto> value) {
    _$produtosPorIdAtom.reportWrite(value, super.produtosPorId, () {
      super.produtosPorId = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ProductStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_ProductStore.error', context: context);

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

  late final _$lastSubcategoriaIdAtom =
      Atom(name: '_ProductStore.lastSubcategoriaId', context: context);

  @override
  int? get lastSubcategoriaId {
    _$lastSubcategoriaIdAtom.reportRead();
    return super.lastSubcategoriaId;
  }

  @override
  set lastSubcategoriaId(int? value) {
    _$lastSubcategoriaIdAtom.reportWrite(value, super.lastSubcategoriaId, () {
      super.lastSubcategoriaId = value;
    });
  }

  late final _$selectedIdsAtom =
      Atom(name: '_ProductStore.selectedIds', context: context);

  @override
  ObservableSet<int> get selectedIds {
    _$selectedIdsAtom.reportRead();
    return super.selectedIds;
  }

  @override
  set selectedIds(ObservableSet<int> value) {
    _$selectedIdsAtom.reportWrite(value, super.selectedIds, () {
      super.selectedIds = value;
    });
  }

  late final _$fetchProdutosAsyncAction =
      AsyncAction('_ProductStore.fetchProdutos', context: context);

  @override
  Future<void> fetchProdutos(int subcategoriaId) {
    return _$fetchProdutosAsyncAction
        .run(() => super.fetchProdutos(subcategoriaId));
  }

  late final _$_ProductStoreActionController =
      ActionController(name: '_ProductStore', context: context);

  @override
  void setSelected(int productId, bool selected) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setSelected');
    try {
      return super.setSelected(productId, selected);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void unselectAllForSubcategory(int subcategoriaId) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.unselectAllForSubcategory');
    try {
      return super.unselectAllForSubcategory(subcategoriaId);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void unselectAll() {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.unselectAll');
    try {
      return super.unselectAll();
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectAllForSubcategory(int subcategoriaId, bool selected) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.selectAllForSubcategory');
    try {
      return super.selectAllForSubcategory(subcategoriaId, selected);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addProductFromApi(Map<String, dynamic> produtoData) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.addProductFromApi');
    try {
      return super.addProductFromApi(produtoData);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
produtos: ${produtos},
produtosPorSubcategoria: ${produtosPorSubcategoria},
produtosPorId: ${produtosPorId},
isLoading: ${isLoading},
error: ${error},
lastSubcategoriaId: ${lastSubcategoriaId},
selectedIds: ${selectedIds},
total: ${total},
allProducts: ${allProducts},
selectedCount: ${selectedCount}
    ''';
  }
}
