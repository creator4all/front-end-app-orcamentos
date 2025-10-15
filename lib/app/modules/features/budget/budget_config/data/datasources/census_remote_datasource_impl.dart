import 'package:dio/dio.dart';

import '../../../../../../../services/api_service.dart';
import '../models/census_data_dto.dart';
import 'census_remote_datasource.dart';

/// Implementação concreta do CensusRemoteDataSource usando Dio/ApiService
class CensusRemoteDataSourceImpl implements CensusRemoteDataSource {
  final ApiService apiService;

  CensusRemoteDataSourceImpl(this.apiService);

  @override
  Future<CensusDataDto> getCensusData(int cityId) async {
    try {
      print('🌐 [CensusDataSource] GET /api/censo/agregado?cidade_id=$cityId');

      final response =
          await apiService.get('/api/censo/agregado?cidade_id=$cityId');
      print('📡 [CensusDataSource] Response: $response');

      // Extrair dados da resposta
      final data = response is Map<String, dynamic>
          ? (response['dados'] ?? response['data'] ?? response)
          : response;

      print('✅ [CensusDataSource] Censo carregado para cidade: $cityId');

      return CensusDataDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      print('❌ [CensusDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [CensusDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<List<CensusDataDto>> getMultipleCitiesCensusData(
      List<int> cityIds) async {
    try {
      print(
          '🌐 [CensusDataSource] Carregando censo para ${cityIds.length} cidades');

      // Fazer requisições em paralelo para todas as cidades
      final futures = cityIds.map((cityId) => getCensusData(cityId));
      final results = await Future.wait(futures);

      print(
          '✅ [CensusDataSource] ${results.length} censos carregados com sucesso');

      return results;
    } catch (e) {
      print('❌ [CensusDataSource] Erro ao carregar múltiplos censos: $e');
      rethrow;
    }
  }

  /// Trata erros do Dio e lança exceções apropriadas
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Timeout na conexão com o servidor');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Dados do censo não encontrados');
        } else if (statusCode == 401 || statusCode == 403) {
          return Exception('Não autorizado');
        }
        return Exception('Erro no servidor: ${error.response?.data}');
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      case DioExceptionType.connectionError:
        return Exception('Sem conexão com a internet');
      default:
        return Exception('Erro desconhecido: ${error.message}');
    }
  }
}
