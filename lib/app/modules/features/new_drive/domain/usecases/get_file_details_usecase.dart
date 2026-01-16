import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para buscar detalhes de um arquivo específico
class GetFileDetailsUseCase {
  final DriveRepository repository;

  GetFileDetailsUseCase(this.repository);

  Future<Either<NewDriveFailure, DriveItem>> call(String fileId) async {
    return repository.getFileDetails(fileId);
  }
}
