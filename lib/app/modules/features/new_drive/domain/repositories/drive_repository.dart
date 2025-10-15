import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_category.dart';
import '../entities/drive_item.dart';

/// Contrato abstrato do repositório de Drive
///
/// Define as operações disponíveis sem especificar a implementação
/// Segue o princípio de inversão de dependência da Clean Architecture
abstract class DriveRepository {
  /// Busca os itens recentemente visualizados
  Future<Either<NewDriveFailure, List<DriveItem>>> getRecentItems();

  /// Busca as categorias de arquivos com estatísticas
  Future<Either<NewDriveFailure, List<DriveCategory>>> getCategories();

  /// Busca arquivos por query de texto
  Future<Either<NewDriveFailure, List<DriveItem>>> searchFiles(String query);

  /// Busca arquivos de uma categoria específica
  Future<Either<NewDriveFailure, List<DriveItem>>> getFilesByCategory(
    DriveItemType type,
  );

  /// Busca detalhes de um arquivo específico
  Future<Either<NewDriveFailure, DriveItem>> getFileDetails(String fileId);
}
