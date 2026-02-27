import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

class GetRecentItemsUseCase {
  final DriveRepository repository;

  GetRecentItemsUseCase(this.repository);

  Future<Either<NewDriveFailure, List<DriveItem>>> call() async {
    try {
      return await repository.getRecentItems();
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }
}
