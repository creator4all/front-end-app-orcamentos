import '../models/drive_category_model.dart';
import '../models/drive_item_model.dart';

/// Contrato abstrato para fonte de dados remota do Drive
///
/// Define as operações de comunicação com a API
abstract class DriveRemoteDataSource {
  /// Busca itens recentes da API
  Future<List<DriveItemModel>> getRecentItems();

  /// Busca categorias da API
  Future<List<DriveCategoryModel>> getCategories();

  /// Busca arquivos por query
  Future<List<DriveItemModel>> searchFiles(String query);

  /// Busca arquivos por categoria
  Future<List<DriveItemModel>> getFilesByCategory(String type);

  /// Busca detalhes de um arquivo
  Future<DriveItemModel> getFileDetails(String fileId);
}
