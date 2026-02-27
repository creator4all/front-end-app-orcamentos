import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

class GetFolderContentsUseCase {
  final DriveRepository repository;

  GetFolderContentsUseCase(this.repository);

  Future<Either<NewDriveFailure, DriveItem>> call(String folderId) async {
    try {
      return await repository.getFolderContents(folderId);
    } catch (e) {
      return Left(LoadRecentItemsFailure(
        'Erro ao carregar conteúdo da pasta: $e',
      ));
    }
  }
}
