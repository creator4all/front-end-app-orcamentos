// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_files_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MyFilesStore on _MyFilesStore, Store {
  Computed<List<FileItem>>? _$filteredFilesComputed;

  @override
  List<FileItem> get filteredFiles => (_$filteredFilesComputed ??=
          Computed<List<FileItem>>(() => super.filteredFiles,
              name: '_MyFilesStore.filteredFiles'))
      .value;
  Computed<String>? _$currentPathComputed;

  @override
  String get currentPath =>
      (_$currentPathComputed ??= Computed<String>(() => super.currentPath,
              name: '_MyFilesStore.currentPath'))
          .value;
  Computed<bool>? _$canGoBackComputed;

  @override
  bool get canGoBack =>
      (_$canGoBackComputed ??= Computed<bool>(() => super.canGoBack,
              name: '_MyFilesStore.canGoBack'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_MyFilesStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_MyFilesStore.error', context: context);

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

  late final _$filesAtom = Atom(name: '_MyFilesStore.files', context: context);

  @override
  ObservableList<FileItem> get files {
    _$filesAtom.reportRead();
    return super.files;
  }

  @override
  set files(ObservableList<FileItem> value) {
    _$filesAtom.reportWrite(value, super.files, () {
      super.files = value;
    });
  }

  late final _$allFilesAtom =
      Atom(name: '_MyFilesStore.allFiles', context: context);

  @override
  ObservableList<FileItem> get allFiles {
    _$allFilesAtom.reportRead();
    return super.allFiles;
  }

  @override
  set allFiles(ObservableList<FileItem> value) {
    _$allFilesAtom.reportWrite(value, super.allFiles, () {
      super.allFiles = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_MyFilesStore.searchQuery', context: context);

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

  late final _$filterTypeAtom =
      Atom(name: '_MyFilesStore.filterType', context: context);

  @override
  String get filterType {
    _$filterTypeAtom.reportRead();
    return super.filterType;
  }

  @override
  set filterType(String value) {
    _$filterTypeAtom.reportWrite(value, super.filterType, () {
      super.filterType = value;
    });
  }

  late final _$currentFolderIdAtom =
      Atom(name: '_MyFilesStore.currentFolderId', context: context);

  @override
  int? get currentFolderId {
    _$currentFolderIdAtom.reportRead();
    return super.currentFolderId;
  }

  @override
  set currentFolderId(int? value) {
    _$currentFolderIdAtom.reportWrite(value, super.currentFolderId, () {
      super.currentFolderId = value;
    });
  }

  late final _$breadcrumbAtom =
      Atom(name: '_MyFilesStore.breadcrumb', context: context);

  @override
  ObservableList<BreadcrumbItem> get breadcrumb {
    _$breadcrumbAtom.reportRead();
    return super.breadcrumb;
  }

  @override
  set breadcrumb(ObservableList<BreadcrumbItem> value) {
    _$breadcrumbAtom.reportWrite(value, super.breadcrumb, () {
      super.breadcrumb = value;
    });
  }

  late final _$downloadProgressAtom =
      Atom(name: '_MyFilesStore.downloadProgress', context: context);

  @override
  ObservableMap<int, double> get downloadProgress {
    _$downloadProgressAtom.reportRead();
    return super.downloadProgress;
  }

  @override
  set downloadProgress(ObservableMap<int, double> value) {
    _$downloadProgressAtom.reportWrite(value, super.downloadProgress, () {
      super.downloadProgress = value;
    });
  }

  late final _$downloadingFilesAtom =
      Atom(name: '_MyFilesStore.downloadingFiles', context: context);

  @override
  ObservableSet<int> get downloadingFiles {
    _$downloadingFilesAtom.reportRead();
    return super.downloadingFiles;
  }

  @override
  set downloadingFiles(ObservableSet<int> value) {
    _$downloadingFilesAtom.reportWrite(value, super.downloadingFiles, () {
      super.downloadingFiles = value;
    });
  }

  late final _$loadMyFilesAsyncAction =
      AsyncAction('_MyFilesStore.loadMyFiles', context: context);

  @override
  Future<void> loadMyFiles({int? folderId}) {
    return _$loadMyFilesAsyncAction
        .run(() => super.loadMyFiles(folderId: folderId));
  }

  late final _$refreshAsyncAction =
      AsyncAction('_MyFilesStore.refresh', context: context);

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$navigateToFolderAsyncAction =
      AsyncAction('_MyFilesStore.navigateToFolder', context: context);

  @override
  Future<void> navigateToFolder(FileItem folder) {
    return _$navigateToFolderAsyncAction
        .run(() => super.navigateToFolder(folder));
  }

  late final _$navigateToBreadcrumbAsyncAction =
      AsyncAction('_MyFilesStore.navigateToBreadcrumb', context: context);

  @override
  Future<void> navigateToBreadcrumb(int index) {
    return _$navigateToBreadcrumbAsyncAction
        .run(() => super.navigateToBreadcrumb(index));
  }

  late final _$navigateBackAsyncAction =
      AsyncAction('_MyFilesStore.navigateBack', context: context);

  @override
  Future<void> navigateBack() {
    return _$navigateBackAsyncAction.run(() => super.navigateBack());
  }

  late final _$navigateToRootAsyncAction =
      AsyncAction('_MyFilesStore.navigateToRoot', context: context);

  @override
  Future<void> navigateToRoot() {
    return _$navigateToRootAsyncAction.run(() => super.navigateToRoot());
  }

  late final _$downloadFileAsyncAction =
      AsyncAction('_MyFilesStore.downloadFile', context: context);

  @override
  Future<void> downloadFile(FileItem file) {
    return _$downloadFileAsyncAction.run(() => super.downloadFile(file));
  }

  late final _$openFileWithNativeAppAsyncAction =
      AsyncAction('_MyFilesStore.openFileWithNativeApp', context: context);

  @override
  Future<void> openFileWithNativeApp(FileItem file) {
    return _$openFileWithNativeAppAsyncAction
        .run(() => super.openFileWithNativeApp(file));
  }

  late final _$_MyFilesStoreActionController =
      ActionController(name: '_MyFilesStore', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_MyFilesStoreActionController.startAction(
        name: '_MyFilesStore.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_MyFilesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFilterType(String type) {
    final _$actionInfo = _$_MyFilesStoreActionController.startAction(
        name: '_MyFilesStore.setFilterType');
    try {
      return super.setFilterType(type);
    } finally {
      _$_MyFilesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_MyFilesStoreActionController.startAction(
        name: '_MyFilesStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_MyFilesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_MyFilesStoreActionController.startAction(
        name: '_MyFilesStore.reset');
    try {
      return super.reset();
    } finally {
      _$_MyFilesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
files: ${files},
allFiles: ${allFiles},
searchQuery: ${searchQuery},
filterType: ${filterType},
currentFolderId: ${currentFolderId},
breadcrumb: ${breadcrumb},
downloadProgress: ${downloadProgress},
downloadingFiles: ${downloadingFiles},
filteredFiles: ${filteredFiles},
currentPath: ${currentPath},
canGoBack: ${canGoBack}
    ''';
  }
}
