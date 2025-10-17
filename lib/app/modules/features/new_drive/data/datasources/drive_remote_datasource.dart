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

  /// Busca arquivos do próprio usuário (apenas admin)
  Future<List<DriveItemModel>> getOwnFiles();

  /// Busca detalhes de um arquivo
  Future<DriveItemModel> getFileDetails(String fileId);

  /// Busca a hierarquia de um item (pasta e seu conteúdo)
  /// Retorna o item com seus filhos (children)
  Future<DriveItemModel> getItemHierarchy(String itemId);

  /// Faz o download dos bytes de um arquivo
  /// Retorna os bytes brutos para serem processados posteriormente
  Future<List<int>> downloadFileBytes(String fileId);
}
