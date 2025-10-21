import 'package:dio/dio.dart';

import '../../../../../../../services/api_service.dart';
import '../../domain/entities/partner_entity.dart';
import '../models/partner_dto.dart';
import 'partner_remote_datasource.dart';

/// Implementação concreta do PartnerRemoteDataSource usando Dio/ApiService
class PartnerRemoteDataSourceImpl implements PartnerRemoteDataSource {
  final ApiService apiService;

  PartnerRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<PartnerEntity>> getStandardPartners() async {
    try {
      const url = '/api/partners/parceiros-standard';
      print('🌐 [PartnerDataSource] Chamando API: $url');

      final response = await apiService.get(url);
      print('📡 [PartnerDataSource] Resposta da API: $response');

      // Extrair dados da resposta
      final data = response['dados'] ?? response['data'] ?? response;

      // Converter para lista
      final List list;
      if (data is Map && data['dados'] is List) {
        list = data['dados'] as List;
      } else if (data is List) {
        list = data;
      } else if (data is Map && data['parceiros'] is List) {
        list = data['parceiros'] as List;
      } else {
        list = [];
      }

      print(
          '📋 [PartnerDataSource] Lista processada: ${list.length} parceiros');

      // Debug: mostrar primeiro item da lista
      if (list.isNotEmpty) {
        print('🔍 [PartnerDataSource] Primeiro item: ${list[0]}');
      }

      // Converter para Entities usando DTO
      final entities = PartnerDto.listFromJson(list);

      print('✅ [PartnerDataSource] Entities criadas: ${entities.length}');
      if (entities.isNotEmpty) {
        print(
            '🔍 [PartnerDataSource] Primeira entity: ${entities[0].displayName}');
      }

      return entities;
    } on DioException catch (e) {
      print('❌ [PartnerDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [PartnerDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<PartnerEntity> getPartnerById(int partnerId) async {
    try {
      final url = '/api/partners/$partnerId';
      print('🔍 [PartnerDataSource] Buscando parceiro ID: $partnerId');

      final response = await apiService.get(url);

      // Extrair dados da resposta
      final data = response['dados'] ?? response['data'] ?? response;

      print('✅ [PartnerDataSource] Parceiro carregado com sucesso');

      // Converter para Entity usando DTO
      final dto = PartnerDto.fromJson(Map<String, dynamic>.from(data as Map));
      return dto.toEntity();
    } on DioException catch (e) {
      print('❌ [PartnerDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [PartnerDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  /// Trata erros do Dio e lança exceções apropriadas
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tempo de conexão excedido');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Parceiro não encontrado');
        } else if (statusCode == 401) {
          return Exception('Não autorizado');
        } else if (statusCode == 403) {
          return Exception('Acesso negado');
        }
        return Exception(
          'Erro no servidor: ${error.response?.data?['message'] ?? 'Erro desconhecido'}',
        );

      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');

      case DioExceptionType.connectionError:
        return Exception('Sem conexão com a internet');

      default:
        return Exception('Erro desconhecido: ${error.message}');
    }
  }
}
