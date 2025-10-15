import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para carregar itens compartilhados recentemente
///
/// Encapsula a lógica de negócio para buscar arquivos compartilhados recentemente
class GetRecentItemsUseCase {
  final DriveRepository repository;

  GetRecentItemsUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Retorna [Either] com:
  /// - Left: Falha ao carregar itens
  /// - Right: Lista de itens compartilhados recentemente (limitado a 4)
  Future<Either<NewDriveFailure, List<DriveItem>>> call() async {
    try {
      return await repository.getRecentItems();
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }
}
