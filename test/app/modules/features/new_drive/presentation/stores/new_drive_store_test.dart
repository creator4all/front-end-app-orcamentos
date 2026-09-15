import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/entities/drive_item.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/new_drive_failure.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/stores/new_drive_store.dart';

import '../../drive_test_fakes.dart';

void main() {
  late FakeDriveRepository repository;
  late NewDriveStore store;

  setUp(() {
    repository = FakeDriveRepository();
    store = repository.createStore();
  });

  Future<void> enter(String id) async {
    store.navigateToFolder(id, 'Pasta $id');
    await store.loadFolderContents(id);
  }

  test('ancestral restaura seu cache e pasta atual é no-op', () async {
    await enter('1');
    await enter('2');
    await enter('3');
    store.navigateToStackIndex(0);
    expect(store.folderStack.map((item) => item.id), ['1']);
    expect(store.currentFolder, repository.folders['1']);
    expect(store.activeFolderId, '1');
    store.navigateToStackIndex(0);
    store.navigateToFolder('1', 'Pasta 1');
    expect(repository.folderRequests, ['1', '2', '3']);
    expect(store.folderStack, hasLength(1));
  });

  test('ancestral sem cache carrega o destino e publica falha controlada',
      () async {
    await enter('1');
    await enter('2');
    store.folderCache.remove('1');
    final response = Completer<Either<NewDriveFailure, DriveItem>>();
    repository.pending['1'] = response;
    store.navigateBack();
    expect(store.activeFolderId, '1');
    expect(store.currentFolder, isNull);
    expect(store.isLoadingFolder, isTrue);
    response.complete(const Left(PermissionDeniedFailure('Acesso negado')));
    await pumpEventQueue();
    expect(store.isLoadingFolder, isFalse);
    expect(store.errorMessage, 'Acesso negado');
    expect(store.activeFolderId, '1');
  });

  test('resposta de filho abandonado não publica dados nem erro', () async {
    await enter('1');
    final response = Completer<Either<NewDriveFailure, DriveItem>>();
    repository.pending['2'] = response;
    store.navigateToFolder('2', 'Pasta 2');
    final loading = store.loadFolderContents('2');
    store.navigateBack();
    response.complete(const Left(ConnectionFailure('Falha antiga')));
    await loading;
    expect(store.activeFolderId, '1');
    expect(store.currentFolder, repository.folders['1']);
    expect(store.errorMessage, isNull);
    expect(store.isLoadingFolder, isFalse);
  });

  test('raiz invalida resposta antiga mesmo ao reentrar na mesma pasta',
      () async {
    final response = Completer<Either<NewDriveFailure, DriveItem>>();
    repository.pending['1'] = response;
    store.navigateToFolder('1', 'Pasta 1');
    final oldLoading = store.loadFolderContents('1');
    store.clearFolderNavigation();
    repository.pending.remove('1');
    await enter('1');
    response.complete(Right(folder('1', children: [document('antigo')])));
    await oldLoading;
    expect(store.currentFolder, repository.folders['1']);
    expect(store.folderCache['1'], repository.folders['1']);
    expect(store.folderStack, hasLength(1));
    store.navigateBack();
    expect(store.folderStack, isEmpty);
    expect(store.folderCache, isEmpty);
    expect(store.currentFolder, isNull);
    expect(store.activeFolderId, isNull);
  });

  test('carregamentos concorrentes da mesma pasta mantêm resposta mais nova',
      () async {
    final oldResponse = Completer<Either<NewDriveFailure, DriveItem>>();
    repository.pending['1'] = oldResponse;
    store.navigateToFolder('1', 'Pasta 1');
    final oldLoading = store.loadFolderContents('1');
    final newResponse = Completer<Either<NewDriveFailure, DriveItem>>();
    repository.pending['1'] = newResponse;
    final newLoading = store.loadFolderContents('1');
    oldResponse.complete(Right(folder('1', children: [document('antigo')])));
    await oldLoading;
    expect(store.isLoadingFolder, isTrue);
    newResponse.complete(Right(repository.folders['1']!));
    await newLoading;
    expect(store.currentFolder, repository.folders['1']);
    expect(store.isLoadingFolder, isFalse);
  });
}
