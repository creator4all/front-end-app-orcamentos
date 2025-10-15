import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para buscar arquivos
///
/// Encapsula a lógica de negócio para buscar arquivos por query de texto
class SearchFilesUseCase {
  final DriveRepository repository;

  SearchFilesUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// [query] - Texto de busca
  ///
  /// Retorna [Either] com:
  /// - Left: Falha na busca
  /// - Right: Lista de arquivos encontrados
  Future<Either<NewDriveFailure, List<DriveItem>>> call(String query) async {
    // Validação: query não pode ser vazia
    if (query.trim().isEmpty) {
      return const Left(
          SearchFilesFailure('Query de busca não pode ser vazia'));
    }

    try {
      return await repository.searchFiles(query);
    } catch (e) {
      return Left(SearchFilesFailure(e.toString()));
    }
  }
}
