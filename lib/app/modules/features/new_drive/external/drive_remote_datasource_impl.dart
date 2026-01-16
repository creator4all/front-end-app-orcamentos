import 'package:dio/dio.dart';

import '../data/datasources/drive_remote_datasource.dart';
import '../data/models/drive_category_model.dart';
import '../data/models/drive_item_model.dart';

/// Implementação do datasource remoto usando Dio
///
/// Realiza chamadas HTTP para a API do Drive
class DriveRemoteDataSourceImpl implements DriveRemoteDataSource {
  final Dio dio;

  DriveRemoteDataSourceImpl(this.dio);

  @override
  Future<List<DriveItemModel>> getRecentItems() async {
    try {
      // Rota: GET /api/files?filter=shared
      // ⚠️ IMPORTANTE: Usar filter=shared para buscar APENAS arquivos compartilhados
      // Não usar filter=own (arquivos próprios) nem filter=all (todos)
      final response = await dio.get(
        '/api/files',
        queryParameters: {
          'filter': 'shared', // ✅ Apenas arquivos compartilhados COM o usuário
        },
      );

      if (response.statusCode == 200) {
        // A API retorna {"dados": [...]}
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final List<dynamic> data = responseData['dados'] as List<dynamic>;
        return data.map((json) => DriveItemModel.fromJson(json)).toList();
      }

      throw Exception('Falha ao carregar itens recentes');
    } catch (e) {
      throw Exception('Erro na comunicação com servidor: $e');
    }
  }

  @override
  Future<List<DriveCategoryModel>> getCategories() async {
    try {
      // TODO: Substituir por endpoint real
      final response = await dio.get('/api/drive/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['categories'] as List<dynamic>;
        return data.map((json) => DriveCategoryModel.fromJson(json)).toList();
      }

      throw Exception('Falha ao carregar categorias');
    } catch (e) {
      throw Exception('Erro na comunicação com servidor: $e');
    }
  }

  @override
  Future<List<DriveItemModel>> searchFiles(String query) async {
    try {
      // TODO: Substituir por endpoint real
      final response = await dio.get(
        '/api/drive/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] as List<dynamic>;
        return data.map((json) => DriveItemModel.fromJson(json)).toList();
      }

      throw Exception('Falha na busca de arquivos');
    } catch (e) {
      throw Exception('Erro na comunicação com servidor: $e');
    }
  }

  @override
  Future<List<DriveItemModel>> getFilesByCategory(String type) async {
    try {
      // TODO: Substituir por endpoint real
      final response = await dio.get(
        '/api/drive/files',
        queryParameters: {'type': type},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] as List<dynamic>;
        return data.map((json) => DriveItemModel.fromJson(json)).toList();
      }

      throw Exception('Falha ao carregar arquivos da categoria');
    } catch (e) {
      throw Exception('Erro na comunicação com servidor: $e');
    }
  }

  @override
  Future<List<DriveItemModel>> getOwnFiles() async {
    try {
      // Rota: GET /api/files?filter=own
      // ⚠️ IMPORTANTE: Retorna APENAS arquivos enviados pelo próprio usuário
      final response = await dio.get(
        '/api/files',
        queryParameters: {
          'filter': 'own', // ✅ Apenas arquivos do próprio usuário
        },
      );

      if (response.statusCode == 200) {
        // A API retorna {"dados": [...]}
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final List<dynamic> data = responseData['dados'] as List<dynamic>;
        return data.map((json) => DriveItemModel.fromJson(json)).toList();
      }

      throw Exception('Falha ao carregar arquivos do usuário');
    } catch (e) {
      throw Exception('Erro na comunicação com servidor: $e');
    }
  }

  @override
  Future<DriveItemModel> getFileDetails(String fileId) async {
    try {
      // Endpoint: GET /api/files/{id}
      // Retorna detalhes do arquivo incluindo sharedBy e downloadUrl
      final response = await dio.get('/api/files/$fileId');

      if (response.statusCode == 200) {
        // A API retorna {dados: {...}}
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final data = responseData['dados'] as Map<String, dynamic>;
        return DriveItemModel.fromJson(data);
      }

      throw Exception('Falha ao carregar detalhes do arquivo');
    } catch (e) {
      throw Exception('Erro na comunicação com servidor: $e');
    }
  }

  @override
  Future<DriveItemModel> getItemHierarchy(String itemId) async {
    try {
      // Endpoint: GET /api/files/{id}/hierarchy
      // Retorna o item com suas relações (parent, children, fileData, etc)
      final response = await dio.get(
        '/api/files/$itemId/hierarchy',
      );

      if (response.statusCode == 200) {
        // A API retorna {"dados": {...}}
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final Map<String, dynamic> data =
            responseData['dados'] as Map<String, dynamic>;
        return DriveItemModel.fromJson(data);
      }

      throw Exception('Falha ao carregar hierarquia do item');
    } catch (e) {
      throw Exception('Erro ao buscar hierarquia: $e');
    }
  }

  @override
  Future<List<int>> downloadFileBytes(String fileId) async {
    try {
      // Endpoint real: /api/files/{id}/view
      final response = await dio.get(
        '/api/files/$fileId/view',
        options: Options(
          responseType: ResponseType.bytes, // ⚠️ IMPORTANTE: recebe bytes
          receiveTimeout:
              const Duration(minutes: 5), // Timeout maior para arquivos grandes
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      }

      throw Exception('Falha ao fazer download do arquivo');
    } catch (e) {
      throw Exception('Erro ao baixar arquivo: $e');
    }
  }
}
