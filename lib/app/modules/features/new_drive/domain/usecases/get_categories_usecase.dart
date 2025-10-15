import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_category.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para carregar categorias do drive
///
/// Encapsula a lógica de negócio para buscar categorias de arquivos
class GetCategoriesUseCase {
  final DriveRepository repository;

  GetCategoriesUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Retorna [Either] com:
  /// - Left: Falha ao carregar categorias
  /// - Right: Lista de categorias
  Future<Either<NewDriveFailure, List<DriveCategory>>> call() async {
    try {
      return await repository.getCategories();
    } catch (e) {
      return Left(LoadCategoriesFailure(e.toString()));
    }
  }
}
