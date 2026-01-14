// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_management_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductManagementStore on _ProductManagementStoreBase, Store {
  Computed<String>? _$pageTitleComputed;

  @override
  String get pageTitle =>
      (_$pageTitleComputed ??= Computed<String>(() => super.pageTitle,
              name: '_ProductManagementStoreBase.pageTitle'))
          .value;
  Computed<bool>? _$canGoBackComputed;

  @override
  bool get canGoBack =>
      (_$canGoBackComputed ??= Computed<bool>(() => super.canGoBack,
              name: '_ProductManagementStoreBase.canGoBack'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_ProductManagementStoreBase.isLoading', context: context);

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

  late final _$errorMessageAtom =
      Atom(name: '_ProductManagementStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$currentLevelAtom =
      Atom(name: '_ProductManagementStoreBase.currentLevel', context: context);

  @override
  NavigationLevel get currentLevel {
    _$currentLevelAtom.reportRead();
    return super.currentLevel;
  }

  @override
  set currentLevel(NavigationLevel value) {
    _$currentLevelAtom.reportWrite(value, super.currentLevel, () {
      super.currentLevel = value;
    });
  }

  late final _$categoriesAtom =
      Atom(name: '_ProductManagementStoreBase.categories', context: context);

  @override
  ObservableList<CategoryEntity> get categories {
    _$categoriesAtom.reportRead();
    return super.categories;
  }

  @override
  set categories(ObservableList<CategoryEntity> value) {
    _$categoriesAtom.reportWrite(value, super.categories, () {
      super.categories = value;
    });
  }

  late final _$subcategoriesAtom =
      Atom(name: '_ProductManagementStoreBase.subcategories', context: context);

  @override
  ObservableList<SubcategoryEntity> get subcategories {
    _$subcategoriesAtom.reportRead();
    return super.subcategories;
  }

  @override
  set subcategories(ObservableList<SubcategoryEntity> value) {
    _$subcategoriesAtom.reportWrite(value, super.subcategories, () {
      super.subcategories = value;
    });
  }

  late final _$productsAtom =
      Atom(name: '_ProductManagementStoreBase.products', context: context);

  @override
  ObservableList<ProductConfigEntity> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(ObservableList<ProductConfigEntity> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  late final _$selectedCategoryAtom = Atom(
      name: '_ProductManagementStoreBase.selectedCategory', context: context);

  @override
  CategoryEntity? get selectedCategory {
    _$selectedCategoryAtom.reportRead();
    return super.selectedCategory;
  }

  @override
  set selectedCategory(CategoryEntity? value) {
    _$selectedCategoryAtom.reportWrite(value, super.selectedCategory, () {
      super.selectedCategory = value;
    });
  }

  late final _$selectedSubcategoryAtom = Atom(
      name: '_ProductManagementStoreBase.selectedSubcategory',
      context: context);

  @override
  SubcategoryEntity? get selectedSubcategory {
    _$selectedSubcategoryAtom.reportRead();
    return super.selectedSubcategory;
  }

  @override
  set selectedSubcategory(SubcategoryEntity? value) {
    _$selectedSubcategoryAtom.reportWrite(value, super.selectedSubcategory, () {
      super.selectedSubcategory = value;
    });
  }

  late final _$selectedProductAtom = Atom(
      name: '_ProductManagementStoreBase.selectedProduct', context: context);

  @override
  ProductConfigEntity? get selectedProduct {
    _$selectedProductAtom.reportRead();
    return super.selectedProduct;
  }

  @override
  set selectedProduct(ProductConfigEntity? value) {
    _$selectedProductAtom.reportWrite(value, super.selectedProduct, () {
      super.selectedProduct = value;
    });
  }

  late final _$indicatorGroupsAtom = Atom(
      name: '_ProductManagementStoreBase.indicatorGroups', context: context);

  @override
  ObservableList<IndicatorGroupEntity> get indicatorGroups {
    _$indicatorGroupsAtom.reportRead();
    return super.indicatorGroups;
  }

  @override
  set indicatorGroups(ObservableList<IndicatorGroupEntity> value) {
    _$indicatorGroupsAtom.reportWrite(value, super.indicatorGroups, () {
      super.indicatorGroups = value;
    });
  }

  late final _$isSavingAtom =
      Atom(name: '_ProductManagementStoreBase.isSaving', context: context);

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

  late final _$isLoadingProductDetailsAtom = Atom(
      name: '_ProductManagementStoreBase.isLoadingProductDetails',
      context: context);

  @override
  bool get isLoadingProductDetails {
    _$isLoadingProductDetailsAtom.reportRead();
    return super.isLoadingProductDetails;
  }

  @override
  set isLoadingProductDetails(bool value) {
    _$isLoadingProductDetailsAtom
        .reportWrite(value, super.isLoadingProductDetails, () {
      super.isLoadingProductDetails = value;
    });
  }

  late final _$loadCategoriesAsyncAction = AsyncAction(
      '_ProductManagementStoreBase.loadCategories',
      context: context);

  @override
  Future<void> loadCategories() {
    return _$loadCategoriesAsyncAction.run(() => super.loadCategories());
  }

  late final _$selectCategoryAsyncAction = AsyncAction(
      '_ProductManagementStoreBase.selectCategory',
      context: context);

  @override
  Future<void> selectCategory(CategoryEntity category) {
    return _$selectCategoryAsyncAction
        .run(() => super.selectCategory(category));
  }

  late final _$selectSubcategoryAsyncAction = AsyncAction(
      '_ProductManagementStoreBase.selectSubcategory',
      context: context);

  @override
  Future<void> selectSubcategory(SubcategoryEntity subcategory) {
    return _$selectSubcategoryAsyncAction
        .run(() => super.selectSubcategory(subcategory));
  }

  late final _$loadProductDetailsAsyncAction = AsyncAction(
      '_ProductManagementStoreBase.loadProductDetails',
      context: context);

  @override
  Future<void> loadProductDetails(int productId) {
    return _$loadProductDetailsAsyncAction
        .run(() => super.loadProductDetails(productId));
  }

  late final _$loadIndicatorsAsyncAction = AsyncAction(
      '_ProductManagementStoreBase.loadIndicators',
      context: context);

  @override
  Future<void> loadIndicators() {
    return _$loadIndicatorsAsyncAction.run(() => super.loadIndicators());
  }

  late final _$updateProductAsyncAction = AsyncAction(
      '_ProductManagementStoreBase.updateProduct',
      context: context);

  @override
  Future<bool> updateProduct(ProductConfigEntity product) {
    return _$updateProductAsyncAction.run(() => super.updateProduct(product));
  }

  late final _$updateProductStatusAsyncAction = AsyncAction(
      '_ProductManagementStoreBase.updateProductStatus',
      context: context);

  @override
  Future<bool> updateProductStatus(int productId, bool status) {
    return _$updateProductStatusAsyncAction
        .run(() => super.updateProductStatus(productId, status));
  }

  late final _$_ProductManagementStoreBaseActionController =
      ActionController(name: '_ProductManagementStoreBase', context: context);

  @override
  void goBack() {
    final _$actionInfo = _$_ProductManagementStoreBaseActionController
        .startAction(name: '_ProductManagementStoreBase.goBack');
    try {
      return super.goBack();
    } finally {
      _$_ProductManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedProduct() {
    final _$actionInfo = _$_ProductManagementStoreBaseActionController
        .startAction(name: '_ProductManagementStoreBase.clearSelectedProduct');
    try {
      return super.clearSelectedProduct();
    } finally {
      _$_ProductManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_ProductManagementStoreBaseActionController
        .startAction(name: '_ProductManagementStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_ProductManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
currentLevel: ${currentLevel},
categories: ${categories},
subcategories: ${subcategories},
products: ${products},
selectedCategory: ${selectedCategory},
selectedSubcategory: ${selectedSubcategory},
selectedProduct: ${selectedProduct},
indicatorGroups: ${indicatorGroups},
isSaving: ${isSaving},
isLoadingProductDetails: ${isLoadingProductDetails},
pageTitle: ${pageTitle},
canGoBack: ${canGoBack}
    ''';
  }
}
