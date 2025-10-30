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
  Computed<int>? _$totalActiveProductsComputed;

  @override
  int get totalActiveProducts => (_$totalActiveProductsComputed ??=
          Computed<int>(() => super.totalActiveProducts,
              name: '_BudgetEditStoreBase.totalActiveProducts'))
      .value;
  Computed<int>? _$totalSelectedProductsComputed;

  @override
  int get totalSelectedProducts => (_$totalSelectedProductsComputed ??=
          Computed<int>(() => super.totalSelectedProducts,
              name: '_BudgetEditStoreBase.totalSelectedProducts'))
      .value;
  Computed<int>? _$selectedCategoriesCountComputed;

  @override
  int get selectedCategoriesCount => (_$selectedCategoriesCountComputed ??=
          Computed<int>(() => super.selectedCategoriesCount,
              name: '_BudgetEditStoreBase.selectedCategoriesCount'))
      .value;
  Computed<bool>? _$hasCategoriesComputed;

  @override
  bool get hasCategories =>
      (_$hasCategoriesComputed ??= Computed<bool>(() => super.hasCategories,
              name: '_BudgetEditStoreBase.hasCategories'))
          .value;
  Computed<bool>? _$hasCensusDataComputed;

  @override
  bool get hasCensusData =>
      (_$hasCensusDataComputed ??= Computed<bool>(() => super.hasCensusData,
              name: '_BudgetEditStoreBase.hasCensusData'))
          .value;
  Computed<bool>? _$isFullyLoadedComputed;

  @override
  bool get isFullyLoaded =>
      (_$isFullyLoadedComputed ??= Computed<bool>(() => super.isFullyLoaded,
              name: '_BudgetEditStoreBase.isFullyLoaded'))
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

  late final _$isLoadingProductsAtom =
      Atom(name: '_BudgetEditStoreBase.isLoadingProducts', context: context);

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
      Atom(name: '_BudgetEditStoreBase.isLoadingCensus', context: context);

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

  late final _$budgetNameAtom =
      Atom(name: '_BudgetEditStoreBase.budgetName', context: context);

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

  late final _$categoriesAtom =
      Atom(name: '_BudgetEditStoreBase.categories', context: context);

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
      Atom(name: '_BudgetEditStoreBase.selectedCategory', context: context);

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

  late final _$selectedSubcategoryAtom =
      Atom(name: '_BudgetEditStoreBase.selectedSubcategory', context: context);

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

  late final _$censusDataAtom =
      Atom(name: '_BudgetEditStoreBase.censusData', context: context);

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

  late final _$initializeAsyncAction =
      AsyncAction('_BudgetEditStoreBase.initialize', context: context);

  @override
  Future<void> initialize(int budgetId) {
    return _$initializeAsyncAction.run(() => super.initialize(budgetId));
  }

  late final _$loadBudgetForEditAsyncAction =
      AsyncAction('_BudgetEditStoreBase.loadBudgetForEdit', context: context);

  @override
  Future<void> loadBudgetForEdit(int budgetId) {
    return _$loadBudgetForEditAsyncAction
        .run(() => super.loadBudgetForEdit(budgetId));
  }

  late final _$_loadAllProductsAsyncAction =
      AsyncAction('_BudgetEditStoreBase._loadAllProducts', context: context);

  @override
  Future<void> _loadAllProducts(int budgetId) {
    return _$_loadAllProductsAsyncAction
        .run(() => super._loadAllProducts(budgetId));
  }

  late final _$loadCensusDataAsyncAction =
      AsyncAction('_BudgetEditStoreBase.loadCensusData', context: context);

  @override
  Future<void> loadCensusData(int cityId) {
    return _$loadCensusDataAsyncAction.run(() => super.loadCensusData(cityId));
  }

  late final _$updateBudgetAsyncAction =
      AsyncAction('_BudgetEditStoreBase.updateBudget', context: context);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudget() {
    return _$updateBudgetAsyncAction.run(() => super.updateBudget());
  }

  late final _$saveBudgetAsyncAction =
      AsyncAction('_BudgetEditStoreBase.saveBudget', context: context);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudget() {
    return _$saveBudgetAsyncAction.run(() => super.saveBudget());
  }

  late final _$saveBudgetWithDtoAsyncAction =
      AsyncAction('_BudgetEditStoreBase.saveBudgetWithDto', context: context);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudgetWithDto() {
    return _$saveBudgetWithDtoAsyncAction.run(() => super.saveBudgetWithDto());
  }

  late final _$_BudgetEditStoreBaseActionController =
      ActionController(name: '_BudgetEditStoreBase', context: context);

  @override
  void toggleCategory(int categoryId) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.toggleCategory');
    try {
      return super.toggleCategory(categoryId);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectCategory(CategoryEntity category) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.selectCategory');
    try {
      return super.selectCategory(category);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectSubcategory(SubcategoryEntity subcategory) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.selectSubcategory');
    try {
      return super.selectSubcategory(subcategory);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleProductInCategory(int categoryId, int productId, bool selected) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.toggleProductInCategory');
    try {
      return super.toggleProductInCategory(categoryId, productId, selected);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

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
  void toggleCategoryWithCascade(int categoryId, bool selected) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.toggleCategoryWithCascade');
    try {
      return super.toggleCategoryWithCascade(categoryId, selected);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleSubcategoryWithCascade(
      int categoryId, int subcategoryId, bool selected) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.toggleSubcategoryWithCascade');
    try {
      return super
          .toggleSubcategoryWithCascade(categoryId, subcategoryId, selected);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleProduct(int productId, bool selected) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.toggleProduct');
    try {
      return super.toggleProduct(productId, selected);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProductQuantity(int productId, int quantity) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.updateProductQuantity');
    try {
      return super.updateProductQuantity(productId, quantity);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProductObservations(int productId, String observations) {
    final _$actionInfo = _$_BudgetEditStoreBaseActionController.startAction(
        name: '_BudgetEditStoreBase.updateProductObservations');
    try {
      return super.updateProductObservations(productId, observations);
    } finally {
      _$_BudgetEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isSaving: ${isSaving},
isLoadingProducts: ${isLoadingProducts},
isLoadingCensus: ${isLoadingCensus},
error: ${error},
budgetData: ${budgetData},
selectedStatus: ${selectedStatus},
isArchived: ${isArchived},
validityDate: ${validityDate},
budgetName: ${budgetName},
selectedProductIds: ${selectedProductIds},
categories: ${categories},
selectedCategory: ${selectedCategory},
selectedSubcategory: ${selectedSubcategory},
censusData: ${censusData},
hasData: ${hasData},
canSave: ${canSave},
selectedProductsCount: ${selectedProductsCount},
totalValue: ${totalValue},
totalActiveProducts: ${totalActiveProducts},
totalSelectedProducts: ${totalSelectedProducts},
selectedCategoriesCount: ${selectedCategoriesCount},
hasCategories: ${hasCategories},
hasCensusData: ${hasCensusData},
isFullyLoaded: ${isFullyLoaded}
    ''';
  }
}
