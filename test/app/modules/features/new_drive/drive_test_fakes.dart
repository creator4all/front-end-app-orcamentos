import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/entities/drive_item.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/repositories/drive_repository.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/usecases/get_folder_contents_usecase.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/usecases/get_own_files_usecase.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/usecases/get_recent_items_usecase.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/new_drive_failure.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/stores/new_drive_store.dart';

DriveItem folder(String id, {List<DriveItem> children = const []}) => DriveItem(
      id: id,
      name: 'Pasta $id',
      type: DriveItemType.folder,
      size: '0 B',
      lastViewed: DateTime(2026),
      children: children,
    );

DriveItem document(String id) => DriveItem(
      id: 'doc-$id',
      name: 'Documento $id',
      type: DriveItemType.document,
      size: '1 KB',
      lastViewed: DateTime(2026),
    );

class FakeDriveRepository extends Fake implements DriveRepository {
  final folders = <String, DriveItem>{};
  final pending = <String, Completer<Either<NewDriveFailure, DriveItem>>>{};
  final failures = <String, NewDriveFailure>{};
  final folderRequests = <String>[];
  List<DriveItem>? entryItems;

  FakeDriveRepository() {
    for (var level = 4; level >= 1; level--) {
      folders['$level'] = folder('$level', children: [
        if (level < 4) folders['${level + 1}']!,
        document('$level'),
      ]);
    }
    folders['9'] = folder('9');
  }

  NewDriveStore createStore() => NewDriveStore(
        getRecentItemsUseCase: GetRecentItemsUseCase(this),
        getOwnFilesUseCase: GetOwnFilesUseCase(this),
        getFolderContentsUseCase: GetFolderContentsUseCase(this),
        driveRepository: this,
      );

  @override
  Future<Either<NewDriveFailure, List<DriveItem>>> getRecentItems() async =>
      Right(entryItems ?? [folders['1']!, folders['9']!]);

  @override
  Future<Either<NewDriveFailure, List<DriveItem>>> getOwnFiles() =>
      getRecentItems();

  @override
  Future<Either<NewDriveFailure, DriveItem>> getFileDetails(
          String fileId) async =>
      Right(folders[fileId]!);

  @override
  Future<Either<NewDriveFailure, DriveItem>> getFolderContents(
      String folderId) {
    folderRequests.add(folderId);
    final controlled = pending[folderId];
    if (controlled != null) return controlled.future;
    final failure = failures[folderId];
    return Future.value(
        failure == null ? Right(folders[folderId]!) : Left(failure));
  }
}
