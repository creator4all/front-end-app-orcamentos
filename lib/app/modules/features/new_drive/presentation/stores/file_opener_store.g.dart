// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_opener_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FileOpenerStore on _FileOpenerStoreBase, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError =>
      (_$hasErrorComputed ??= Computed<bool>(() => super.hasError,
              name: '_FileOpenerStoreBase.hasError'))
          .value;
  Computed<int>? _$progressPercentageComputed;

  @override
  int get progressPercentage => (_$progressPercentageComputed ??= Computed<int>(
          () => super.progressPercentage,
          name: '_FileOpenerStoreBase.progressPercentage'))
      .value;

  late final _$isDownloadingAtom =
      Atom(name: '_FileOpenerStoreBase.isDownloading', context: context);

  @override
  bool get isDownloading {
    _$isDownloadingAtom.reportRead();
    return super.isDownloading;
  }

  @override
  set isDownloading(bool value) {
    _$isDownloadingAtom.reportWrite(value, super.isDownloading, () {
      super.isDownloading = value;
    });
  }

  late final _$downloadProgressAtom =
      Atom(name: '_FileOpenerStoreBase.downloadProgress', context: context);

  @override
  double get downloadProgress {
    _$downloadProgressAtom.reportRead();
    return super.downloadProgress;
  }

  @override
  set downloadProgress(double value) {
    _$downloadProgressAtom.reportWrite(value, super.downloadProgress, () {
      super.downloadProgress = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_FileOpenerStoreBase.errorMessage', context: context);

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

  late final _$currentItemAtom =
      Atom(name: '_FileOpenerStoreBase.currentItem', context: context);

  @override
  DriveItem? get currentItem {
    _$currentItemAtom.reportRead();
    return super.currentItem;
  }

  @override
  set currentItem(DriveItem? value) {
    _$currentItemAtom.reportWrite(value, super.currentItem, () {
      super.currentItem = value;
    });
  }

  late final _$lastFilePathAtom =
      Atom(name: '_FileOpenerStoreBase.lastFilePath', context: context);

  @override
  String? get lastFilePath {
    _$lastFilePathAtom.reportRead();
    return super.lastFilePath;
  }

  @override
  set lastFilePath(String? value) {
    _$lastFilePathAtom.reportWrite(value, super.lastFilePath, () {
      super.lastFilePath = value;
    });
  }

  late final _$openFileAsyncAction =
      AsyncAction('_FileOpenerStoreBase.openFile', context: context);

  @override
  Future<void> openFile(DriveItem item) {
    return _$openFileAsyncAction.run(() => super.openFile(item));
  }

  late final _$_FileOpenerStoreBaseActionController =
      ActionController(name: '_FileOpenerStoreBase', context: context);

  @override
  void setDownloadProgress(double progress) {
    final _$actionInfo = _$_FileOpenerStoreBaseActionController.startAction(
        name: '_FileOpenerStoreBase.setDownloadProgress');
    try {
      return super.setDownloadProgress(progress);
    } finally {
      _$_FileOpenerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_FileOpenerStoreBaseActionController.startAction(
        name: '_FileOpenerStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_FileOpenerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_FileOpenerStoreBaseActionController.startAction(
        name: '_FileOpenerStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_FileOpenerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isDownloading: ${isDownloading},
downloadProgress: ${downloadProgress},
errorMessage: ${errorMessage},
currentItem: ${currentItem},
lastFilePath: ${lastFilePath},
hasError: ${hasError},
progressPercentage: ${progressPercentage}
    ''';
  }
}
