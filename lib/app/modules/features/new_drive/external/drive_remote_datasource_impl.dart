import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';
import 'package:multimidiaapp/config/api_config.dart';

import '../data/datasources/drive_remote_datasource.dart';
import '../data/models/drive_item_model.dart';

class DriveRemoteDataSourceImpl implements DriveRemoteDataSource {
  final AppHttpClient _client;

  DriveRemoteDataSourceImpl(this._client);

  HttpRequestConfig get _config => HttpRequestConfig(
        token: TokenCache.instance.getTokenOrEmpty(),
        baseUrl: ApiConfig.baseUrl,
      );

  @override
  Future<List<DriveItemModel>> getRecentItems() async {
    try {
      final response = await _client.get(
        '/api/files',
        config: _config.copyWith(queryParameters: {'filter': 'shared'}),
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.body['dados'] as List<dynamic>;
        return data.map((json) => DriveItemModel.fromJson(json)).toList();
      }

      throw Exception('Falha ao carregar itens recentes');
    } catch (e) {
      throw Exception('Erro na comunicação com servidor: $e');
    }
  }

  @override
  Future<List<DriveItemModel>> getOwnFiles() async {
    try {
      final response = await _client.get(
        '/api/files',
        config: _config.copyWith(queryParameters: {'filter': 'own'}),
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.body['dados'] as List<dynamic>;
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
      final response = await _client.get(
        '/api/files/$fileId',
        config: _config,
      );

      if (response.isSuccess) {
        final data = response.body['dados'] as Map<String, dynamic>;
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
      final response = await _client.get(
        '/api/files/$itemId/hierarchy',
        config: _config,
      );

      if (response.isSuccess) {
        final data = response.body['dados'] as Map<String, dynamic>;
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
      final bytes = await _client.getBytes(
        '${ApiConfig.baseUrl}/api/files/$fileId/download',
        config: HttpRequestConfig(
          token: TokenCache.instance.getTokenOrEmpty(),
          timeout: const Duration(minutes: 5),
        ),
      );

      return bytes;
    } catch (e) {
      throw Exception('Erro ao baixar arquivo: $e');
    }
  }
}
