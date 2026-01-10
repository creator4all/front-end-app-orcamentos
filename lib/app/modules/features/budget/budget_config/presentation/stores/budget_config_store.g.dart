// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_config_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BudgetConfigStore on _BudgetConfigStoreBase, Store {
  Computed<bool>? _$canFinalizeComputed;

  @override
  bool get canFinalize =>
      (_$canFinalizeComputed ??= Computed<bool>(() => super.canFinalize,
              name: '_BudgetConfigStoreBase.canFinalize'))
          .value;
  Computed<int>? _$selectedCategoriesCountComputed;

  @override
  int get selectedCategoriesCount => (_$selectedCategoriesCountComputed ??=
          Computed<int>(() => super.selectedCategoriesCount,
              name: '_BudgetConfigStoreBase.selectedCategoriesCount'))
      .value;
  Computed<double>? _$totalValueComputed;

  @override
  double get totalValue =>
      (_$totalValueComputed ??= Computed<double>(() => super.totalValue,
              name: '_BudgetConfigStoreBase.totalValue'))
          .value;
  Computed<int>? _$selectedProductsCountComputed;

  @override
  int get selectedProductsCount => (_$selectedProductsCountComputed ??=
          Computed<int>(() => super.selectedProductsCount,
              name: '_BudgetConfigStoreBase.selectedProductsCount'))
      .value;
  Computed<int>? _$totalActiveProductsComputed;

  @override
  int get totalActiveProducts => (_$totalActiveProductsComputed ??=
          Computed<int>(() => super.totalActiveProducts,
              name: '_BudgetConfigStoreBase.totalActiveProducts'))
      .value;
  Computed<int>? _$totalSelectedProductsComputed;

  @override
  int get totalSelectedProducts => (_$totalSelectedProductsComputed ??=
          Computed<int>(() => super.totalSelectedProducts,
              name: '_BudgetConfigStoreBase.totalSelectedProducts'))
      .value;
  Computed<int>? _$selectedItemsCountComputed;

  @override
  int get selectedItemsCount => (_$selectedItemsCountComputed ??= Computed<int>(
          () => super.selectedItemsCount,
          name: '_BudgetConfigStoreBase.selectedItemsCount'))
      .value;
  Computed<bool>? _$hasDataComputed;

  @override
  bool get hasData => (_$hasDataComputed ??= Computed<bool>(() => super.hasData,
          name: '_BudgetConfigStoreBase.hasData'))
      .value;
  Computed<bool>? _$hasCensusDataComputed;

  @override
  bool get hasCensusData =>
      (_$hasCensusDataComputed ??= Computed<bool>(() => super.hasCensusData,
              name: '_BudgetConfigStoreBase.hasCensusData'))
          .value;
  Computed<bool>? _$hasCategoriesComputed;

  @override
  bool get hasCategories =>
      (_$hasCategoriesComputed ??= Computed<bool>(() => super.hasCategories,
              name: '_BudgetConfigStoreBase.hasCategories'))
          .value;
  Computed<bool>? _$isFullyLoadedComputed;

  @override
  bool get isFullyLoaded =>
      (_$isFullyLoadedComputed ??= Computed<bool>(() => super.isFullyLoaded,
              name: '_BudgetConfigStoreBase.isFullyLoaded'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_BudgetConfigStoreBase.isLoading', context: context);

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

  late final _$isLoadingProductsAtom =
      Atom(name: '_BudgetConfigStoreBase.isLoadingProducts', context: context);

  @override
  bool get isLoadingProducts {
    _$isLoadingProductsAtom.reportRead();
    return super.isLoadingProducts;
  }

  @override
  set isLoadingProducts(bool value) {
    _$isLoadingProductsAtom.reportWrite(value, super.isLoadingProducts, () {
      super.isLoadingProducts = value;
    });
  }

  late final _$isLoadingCensusAtom =
      Atom(name: '_BudgetConfigStoreBase.isLoadingCensus', context: context);

  @override
  bool get isLoadingCensus {
    _$isLoadingCensusAtom.reportRead();
    return super.isLoadingCensus;
  }

  @override
  set isLoadingCensus(bool value) {
    _$isLoadingCensusAtom.reportWrite(value, super.isLoadingCensus, () {
      super.isLoadingCensus = value;
    });
  }

  late final _$isSavingAtom =
      Atom(name: '_BudgetConfigStoreBase.isSaving', context: context);

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
      Atom(name: '_BudgetConfigStoreBase.error', context: context);

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

  late final _$budgetDetailAtom =
      Atom(name: '_BudgetConfigStoreBase.budgetDetail', context: context);

  @override
  BudgetDetailEntity? get budgetDetail {
    _$budgetDetailAtom.reportRead();
    return super.budgetDetail;
  }

  @override
  set budgetDetail(BudgetDetailEntity? value) {
    _$budgetDetailAtom.reportWrite(value, super.budgetDetail, () {
      super.budgetDetail = value;
    });
  }

  late final _$censusDataAtom =
      Atom(name: '_BudgetConfigStoreBase.censusData', context: context);

  @override
  CensusDataEntity? get censusData {
    _$censusDataAtom.reportRead();
    return super.censusData;
  }

  @override
  set censusData(CensusDataEntity? value) {
    _$censusDataAtom.reportWrite(value, super.censusData, () {
      super.censusData = value;
    });
  }

  late final _$censoEscolarAtom =
      Atom(name: '_BudgetConfigStoreBase.censoEscolar', context: context);

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

  late final _$categoryStatesAtom =
      Atom(name: '_BudgetConfigStoreBase.categoryStates', context: context);

  @override
  ObservableMap<String, bool> get categoryStates {
    _$categoryStatesAtom.reportRead();
    return super.categoryStates;
  }

  @override
  set categoryStates(ObservableMap<String, bool> value) {
    _$categoryStatesAtom.reportWrite(value, super.categoryStates, () {
      super.categoryStates = value;
    });
  }

  late final _$validityDateAtom =
      Atom(name: '_BudgetConfigStoreBase.validityDate', context: context);

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

  late final _$budgetNameAtom =
      Atom(name: '_BudgetConfigStoreBase.budgetName', context: context);

  @override
  String? get budgetName {
    _$budgetNameAtom.reportRead();
    return super.budgetName;
  }

  @override
  set budgetName(String? value) {
    _$budgetNameAtom.reportWrite(value, super.budgetName, () {
      super.budgetName = value;
    });
  }

  late final _$categoriesAtom =
      Atom(name: '_BudgetConfigStoreBase.categories', context: context);

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

  late final _$selectedCategoryAtom =
      Atom(name: '_BudgetConfigStoreBase.selectedCategory', context: context);

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
      name: '_BudgetConfigStoreBase.selectedSubcategory', context: context);

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

  late final _$productsNeedingRemarkAtom = Atom(
      name: '_BudgetConfigStoreBase.productsNeedingRemark', context: context);

  @override
  List<ProductEntity> get productsNeedingRemark {
    _$productsNeedingRemarkAtom.reportRead();
    return super.productsNeedingRemark;
  }

  @override
  set productsNeedingRemark(List<ProductEntity> value) {
    _$productsNeedingRemarkAtom.reportWrite(value, super.productsNeedingRemark,
        () {
      super.productsNeedingRemark = value;
    });
  }

  late final _$initializeAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.initialize', context: context);

  @override
  Future<void> initialize(int budgetId) {
    return _$initializeAsyncAction.run(() => super.initialize(budgetId));
  }

  late final _$initializeWithDraftAsyncAction = AsyncAction(
      '_BudgetConfigStoreBase.initializeWithDraft',
      context: context);

  @override
  Future<void> initializeWithDraft(BudgetDraftEntity draft) {
    return _$initializeWithDraftAsyncAction
        .run(() => super.initializeWithDraft(draft));
  }

  late final _$initializeWithMultiCityResponseAsyncAction = AsyncAction(
      '_BudgetConfigStoreBase.initializeWithMultiCityResponse',
      context: context);

  @override
  Future<void> initializeWithMultiCityResponse(Map<String, dynamic> response) {
    return _$initializeWithMultiCityResponseAsyncAction
        .run(() => super.initializeWithMultiCityResponse(response));
  }

  late final _$loadBudgetDetailAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.loadBudgetDetail', context: context);

  @override
  Future<void> loadBudgetDetail(int budgetId) {
    return _$loadBudgetDetailAsyncAction
        .run(() => super.loadBudgetDetail(budgetId));
  }

  late final _$_loadAllProductsAsyncAction =
      AsyncAction('_BudgetConfigStoreBase._loadAllProducts', context: context);

  @override
  Future<void> _loadAllProducts(int budgetId) {
    return _$_loadAllProductsAsyncAction
        .run(() => super._loadAllProducts(budgetId));
  }

  late final _$loadCensusDataAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.loadCensusData', context: context);

  @override
  Future<void> loadCensusData(int cityId) {
    return _$loadCensusDataAsyncAction.run(() => super.loadCensusData(cityId));
  }

  late final _$finalizeBudgetAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.finalizeBudget', context: context);

  @override
  Future<Either<BudgetFailure, BudgetDetailEntity>> finalizeBudget() {
    return _$finalizeBudgetAsyncAction.run(() => super.finalizeBudget());
  }

  late final _$reloadProductsAfterCensusEditAsyncAction = AsyncAction(
      '_BudgetConfigStoreBase.reloadProductsAfterCensusEdit',
      context: context);

  @override
  Future<void> reloadProductsAfterCensusEdit() {
    return _$reloadProductsAfterCensusEditAsyncAction
        .run(() => super.reloadProductsAfterCensusEdit());
  }

  late final _$saveBudgetAsyncAction =
      AsyncAction('_BudgetConfigStoreBase.saveBudget', context: context);

  @override
  Future<Either<BudgetFailure, BudgetDetailEntity>> saveBudget() {
    return _$saveBudgetAsyncAction.run(() => super.saveBudget());
  }

  late final _$_BudgetConfigStoreBaseActionController =
      ActionController(name: '_BudgetConfigStoreBase', context: context);

  @override
  void _checkForProductsToRemark(
      CensoEscolarEntity oldCenso, CensoEscolarEntity newCenso) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase._checkForProductsToRemark');
    try {
      return super._checkForProductsToRemark(oldCenso, newCenso);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void confirmProductRemark() {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.confirmProductRemark');
    try {
      return super.confirmProductRemark();
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void rejectProductRemark() {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.rejectProductRemark');
    try {
      return super.rejectProductRemark();
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCensoEscolar(CensoEscolarEntity updatedCenso) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.updateCensoEscolar');
    try {
      return super.updateCensoEscolar(updatedCenso);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _remarkProducts(List<ProductEntity> productsToRemark) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase._remarkProducts');
    try {
      return super._remarkProducts(productsToRemark);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleCategory(String categoryKey) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.toggleCategory');
    try {
      return super.toggleCategory(categoryKey);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValidityDate(DateTime? date) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.setValidityDate');
    try {
      return super.setValidityDate(date);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBudgetName(String? name) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.setBudgetName');
    try {
      return super.setBudgetName(name);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectCategory(CategoryEntity? category) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.selectCategory');
    try {
      return super.selectCategory(category);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectSubcategory(SubcategoryEntity? subcategory) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.selectSubcategory');
    try {
      return super.selectSubcategory(subcategory);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleProduct(int productId, bool selected) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.toggleProduct');
    try {
      return super.toggleProduct(productId, selected);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleSubcategoryWithCascade(
      int categoryId, int subcategoryId, bool selected) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.toggleSubcategoryWithCascade');
    try {
      return super
          .toggleSubcategoryWithCascade(categoryId, subcategoryId, selected);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleCategoryWithCascade(int categoryId, bool selected) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.toggleCategoryWithCascade');
    try {
      return super.toggleCategoryWithCascade(categoryId, selected);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProductFromModal(ProductEntity updatedProduct) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.updateProductFromModal');
    try {
      return super.updateProductFromModal(updatedProduct);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProductQuantity(int productId, int quantity) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.updateProductQuantity');
    try {
      return super.updateProductQuantity(productId, quantity);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProductValue(int productId, double value) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.updateProductValue');
    try {
      return super.updateProductValue(productId, value);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProductObservations(int productId, String? observations) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.updateProductObservations');
    try {
      return super.updateProductObservations(productId, observations);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleProductIndicator(int productId, int indicatorId) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.toggleProductIndicator');
    try {
      return super.toggleProductIndicator(productId, indicatorId);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProductIndicators(
      int productId, Map<String, List<String>> selectedIndicators) {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.updateProductIndicators');
    try {
      return super.updateProductIndicators(productId, selectedIndicators);
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_BudgetConfigStoreBaseActionController.startAction(
        name: '_BudgetConfigStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_BudgetConfigStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isLoadingProducts: ${isLoadingProducts},
isLoadingCensus: ${isLoadingCensus},
isSaving: ${isSaving},
error: ${error},
budgetDetail: ${budgetDetail},
censusData: ${censusData},
censoEscolar: ${censoEscolar},
categoryStates: ${categoryStates},
validityDate: ${validityDate},
budgetName: ${budgetName},
categories: ${categories},
selectedCategory: ${selectedCategory},
selectedSubcategory: ${selectedSubcategory},
productsNeedingRemark: ${productsNeedingRemark},
canFinalize: ${canFinalize},
selectedCategoriesCount: ${selectedCategoriesCount},
totalValue: ${totalValue},
selectedProductsCount: ${selectedProductsCount},
totalActiveProducts: ${totalActiveProducts},
totalSelectedProducts: ${totalSelectedProducts},
selectedItemsCount: ${selectedItemsCount},
hasData: ${hasData},
hasCensusData: ${hasCensusData},
hasCategories: ${hasCategories},
isFullyLoaded: ${isFullyLoaded}
    ''';
  }
}
