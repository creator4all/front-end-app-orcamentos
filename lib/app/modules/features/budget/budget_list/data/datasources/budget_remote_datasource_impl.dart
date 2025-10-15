import 'package:dio/dio.dart';

import '../../../../../../../services/api_service.dart';
import '../models/budget_dto.dart';
import 'budget_remote_datasource.dart';

/// Implementação concreta do BudgetRemoteDataSource usando Dio/ApiService
class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final ApiService apiService;

  BudgetRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<BudgetDto>> getBudgets({String? status}) async {
    try {
      final url =
          '/api/orcamentos${status != null ? '?orc_status=$status' : ''}';
      print('🌐 [DataSource] Chamando API: $url');

      final response = await apiService.get(url);
      print('📡 [DataSource] Resposta da API: $response');

      // Extrair dados da resposta
      final data = response is Map<String, dynamic>
          ? (response['dados'] ?? response['data'] ?? response)
          : response;

      // Converter para lista
      final List list;
      if (data is Map && data['dados'] is List) {
        list = data['dados'] as List;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      print('📋 [DataSource] Lista processada: ${list.length} itens');

      // Converter para DTOs
      return list
          .map((e) => BudgetDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      print('❌ [DataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [DataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<BudgetDto> getBudgetById(int budgetId) async {
    try {
      print('🔍 [DataSource] Buscando orçamento ID: $budgetId');

      final response = await apiService.get('/api/orcamentos/$budgetId');

      // Extrair dados da resposta
      final data = response is Map<String, dynamic>
          ? (response['dados'] ?? response['data'] ?? response)
          : response;

      print('✅ [DataSource] Orçamento carregado com sucesso');

      return BudgetDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      print('❌ [DataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [DataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<BudgetDto> renameBudget(int budgetId, String newName) async {
    try {
      print(
          '✏️ [DataSource] Renomeando orçamento ID: $budgetId para: $newName');

      final updateData = {'nome': newName};

      final response = await apiService.put(
        '/api/orcamentos/$budgetId',
        updateData,
      );

      // Extrair dados da resposta
      final data = response is Map<String, dynamic>
          ? (response['dados'] ?? response['data'] ?? response)
          : response;

      print('✅ [DataSource] Orçamento renomeado com sucesso');

      return BudgetDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      print('❌ [DataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [DataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(int budgetId) async {
    try {
      print('🗑️ [DataSource] Excluindo orçamento ID: $budgetId');

      await apiService.delete('/api/orcamentos/$budgetId');

      print('✅ [DataSource] Orçamento excluído com sucesso');
    } on DioException catch (e) {
      print('❌ [DataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [DataSource] Erro desconhecido: $e');
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
          return Exception('Recurso não encontrado');
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
