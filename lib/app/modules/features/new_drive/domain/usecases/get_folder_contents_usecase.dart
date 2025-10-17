import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para carregar o conteúdo de uma pasta
///
/// Encapsula a lógica de negócio para buscar todos os itens dentro de uma pasta específica
/// Usa o endpoint /api/files/{id}/hierarchy que retorna a pasta com seus filhos
class GetFolderContentsUseCase {
  final DriveRepository repository;

  GetFolderContentsUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Parâmetro: [folderId] - ID da pasta a ser carregada
  ///
  /// Retorna [Either] com:
  /// - Left: Falha ao carregar conteúdo
  /// - Right: Item da pasta com seus filhos preenchidos
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
