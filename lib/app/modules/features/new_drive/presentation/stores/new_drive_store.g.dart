// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_drive_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NewDriveStore on _NewDriveStoreBase, Store {
  Computed<List<DriveItem>>? _$recentItemsComputed;

  @override
  List<DriveItem> get recentItems => (_$recentItemsComputed ??=
          Computed<List<DriveItem>>(() => super.recentItems,
              name: '_NewDriveStoreBase.recentItems'))
      .value;
  Computed<List<DriveItem>>? _$selectedCategoryItemsComputed;

  @override
  List<DriveItem> get selectedCategoryItems =>
      (_$selectedCategoryItemsComputed ??= Computed<List<DriveItem>>(
              () => super.selectedCategoryItems,
              name: '_NewDriveStoreBase.selectedCategoryItems'))
          .value;
  Computed<List<DriveItem>>? _$filteredCategoryItemsComputed;

  @override
  List<DriveItem> get filteredCategoryItems =>
      (_$filteredCategoryItemsComputed ??= Computed<List<DriveItem>>(
              () => super.filteredCategoryItems,
              name: '_NewDriveStoreBase.filteredCategoryItems'))
          .value;
  Computed<List<DriveItem>>? _$viewItemsComputed;

  @override
  List<DriveItem> get viewItems =>
      (_$viewItemsComputed ??= Computed<List<DriveItem>>(() => super.viewItems,
              name: '_NewDriveStoreBase.viewItems'))
          .value;
  Computed<List<DriveItem>>? _$filteredViewItemsComputed;

  @override
  List<DriveItem> get filteredViewItems => (_$filteredViewItemsComputed ??=
          Computed<List<DriveItem>>(() => super.filteredViewItems,
              name: '_NewDriveStoreBase.filteredViewItems'))
      .value;

  late final _$allItemsAtom =
      Atom(name: '_NewDriveStoreBase.allItems', context: context);

  @override
  ObservableList<DriveItem> get allItems {
    _$allItemsAtom.reportRead();
    return super.allItems;
  }

  @override
  set allItems(ObservableList<DriveItem> value) {
    _$allItemsAtom.reportWrite(value, super.allItems, () {
      super.allItems = value;
    });
  }

  late final _$categoriesAtom =
      Atom(name: '_NewDriveStoreBase.categories', context: context);

  @override
  ObservableList<DriveCategory> get categories {
    _$categoriesAtom.reportRead();
    return super.categories;
  }

  @override
  set categories(ObservableList<DriveCategory> value) {
    _$categoriesAtom.reportWrite(value, super.categories, () {
      super.categories = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_NewDriveStoreBase.searchQuery', context: context);

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

  late final _$isLoadingAtom =
      Atom(name: '_NewDriveStoreBase.isLoading', context: context);

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
      Atom(name: '_NewDriveStoreBase.errorMessage', context: context);

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

  late final _$selectedCategoryTypeAtom =
      Atom(name: '_NewDriveStoreBase.selectedCategoryType', context: context);

  @override
  DriveItemType? get selectedCategoryType {
    _$selectedCategoryTypeAtom.reportRead();
    return super.selectedCategoryType;
  }

  @override
  set selectedCategoryType(DriveItemType? value) {
    _$selectedCategoryTypeAtom.reportWrite(value, super.selectedCategoryType,
        () {
      super.selectedCategoryType = value;
    });
  }

  late final _$viewModeAtom =
      Atom(name: '_NewDriveStoreBase.viewMode', context: context);

  @override
  String? get viewMode {
    _$viewModeAtom.reportRead();
    return super.viewMode;
  }

  @override
  set viewMode(String? value) {
    _$viewModeAtom.reportWrite(value, super.viewMode, () {
      super.viewMode = value;
    });
  }

  late final _$loadRecentItemsAsyncAction =
      AsyncAction('_NewDriveStoreBase.loadRecentItems', context: context);

  @override
  Future<void> loadRecentItems() {
    return _$loadRecentItemsAsyncAction.run(() => super.loadRecentItems());
  }

  late final _$loadCategoriesAsyncAction =
      AsyncAction('_NewDriveStoreBase.loadCategories', context: context);

  @override
  Future<void> loadCategories() {
    return _$loadCategoriesAsyncAction.run(() => super.loadCategories());
  }

  late final _$initializeAsyncAction =
      AsyncAction('_NewDriveStoreBase.initialize', context: context);

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  late final _$_NewDriveStoreBaseActionController =
      ActionController(name: '_NewDriveStoreBase', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_NewDriveStoreBaseActionController.startAction(
        name: '_NewDriveStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_NewDriveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_NewDriveStoreBaseActionController.startAction(
        name: '_NewDriveStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_NewDriveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectCategory(DriveItemType type) {
    final _$actionInfo = _$_NewDriveStoreBaseActionController.startAction(
        name: '_NewDriveStoreBase.selectCategory');
    try {
      return super.selectCategory(type);
    } finally {
      _$_NewDriveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedCategory() {
    final _$actionInfo = _$_NewDriveStoreBaseActionController.startAction(
        name: '_NewDriveStoreBase.clearSelectedCategory');
    try {
      return super.clearSelectedCategory();
    } finally {
      _$_NewDriveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setViewMode(String mode) {
    final _$actionInfo = _$_NewDriveStoreBaseActionController.startAction(
        name: '_NewDriveStoreBase.setViewMode');
    try {
      return super.setViewMode(mode);
    } finally {
      _$_NewDriveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearViewMode() {
    final _$actionInfo = _$_NewDriveStoreBaseActionController.startAction(
        name: '_NewDriveStoreBase.clearViewMode');
    try {
      return super.clearViewMode();
    } finally {
      _$_NewDriveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
allItems: ${allItems},
categories: ${categories},
searchQuery: ${searchQuery},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
selectedCategoryType: ${selectedCategoryType},
viewMode: ${viewMode},
recentItems: ${recentItems},
selectedCategoryItems: ${selectedCategoryItems},
filteredCategoryItems: ${filteredCategoryItems},
viewItems: ${viewItems},
filteredViewItems: ${filteredViewItems}
    ''';
  }
}
