import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';

abstract class DriveRepository {
  Future<Either<NewDriveFailure, List<DriveItem>>> getRecentItems();

  Future<Either<NewDriveFailure, List<DriveItem>>> getOwnFiles();

  Future<Either<NewDriveFailure, DriveItem>> getFileDetails(String fileId);

  Future<Either<NewDriveFailure, DriveItem>> getFolderContents(String folderId);

  Future<Either<NewDriveFailure, List<int>>> downloadFileBytes(String fileId);
}
