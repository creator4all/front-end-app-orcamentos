import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para carregar todos os arquivos com filtro
///
/// Encapsula a lógica de negócio para buscar todos os arquivos (meus arquivos, todos compartilhados, etc)
class GetAllFilesUseCase {
  final DriveRepository repository;

  GetAllFilesUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Retorna [Either] com:
  /// - Left: Falha ao carregar itens
  /// - Right: Lista de todos os itens
  Future<Either<NewDriveFailure, List<DriveItem>>> call() async {
    try {
      return await repository.getRecentItems();
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }
}
