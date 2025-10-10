// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DriveStore on _DriveStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_DriveStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_DriveStore.error', context: context);

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

  late final _$filesAtom = Atom(name: '_DriveStore.files', context: context);

  @override
  ObservableList<FileModel> get files {
    _$filesAtom.reportRead();
    return super.files;
  }

  @override
  set files(ObservableList<FileModel> value) {
    _$filesAtom.reportWrite(value, super.files, () {
      super.files = value;
    });
  }

  late final _$loadFilesAsyncAction =
      AsyncAction('_DriveStore.loadFiles', context: context);

  @override
  Future<void> loadFiles() {
    return _$loadFilesAsyncAction.run(() => super.loadFiles());
  }

  late final _$_DriveStoreActionController =
      ActionController(name: '_DriveStore', context: context);

  @override
  void openFile(FileModel file) {
    final _$actionInfo =
        _$_DriveStoreActionController.startAction(name: '_DriveStore.openFile');
    try {
      return super.openFile(file);
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void openFolder(FileModel folder) {
    final _$actionInfo = _$_DriveStoreActionController.startAction(
        name: '_DriveStore.openFolder');
    try {
      return super.openFolder(folder);
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void downloadFile(FileModel file) {
    final _$actionInfo = _$_DriveStoreActionController.startAction(
        name: '_DriveStore.downloadFile');
    try {
      return super.downloadFile(file);
    } finally {
      _$_DriveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
files: ${files}
    ''';
  }
}
