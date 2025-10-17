import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para carregar arquivos do próprio usuário
///
/// Encapsula a lógica de negócio para buscar arquivos enviados pelo usuário atual
/// Apenas disponível para administradores
class GetOwnFilesUseCase {
  final DriveRepository repository;

  GetOwnFilesUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Retorna [Either] com:
  /// - Left: Falha ao carregar arquivos
  /// - Right: Lista de arquivos do próprio usuário
  Future<Either<NewDriveFailure, List<DriveItem>>> call() async {
    try {
      return await repository.getOwnFiles();
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }
}
