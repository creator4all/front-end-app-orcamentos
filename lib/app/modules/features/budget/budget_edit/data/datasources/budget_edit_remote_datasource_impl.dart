import 'package:dio/dio.dart';

import '../../../../../../../services/api_service.dart';
import '../models/budget_edit_dto.dart';
import 'budget_edit_remote_datasource.dart';

class BudgetEditRemoteDataSourceImpl implements BudgetEditRemoteDataSource {
  final ApiService apiService;

  BudgetEditRemoteDataSourceImpl(this.apiService);

  @override
  Future<BudgetEditDto> getBudgetForEdit(int id) async {
    try {
      print('🌐 [BudgetEditDataSource] GET /api/orcamentos/$id');

      final response = await apiService.get('/api/orcamentos/$id');
      print('📡 [BudgetEditDataSource] Response: $response');

      // ApiService envolve em { success: true, data: {...} }
      // Então precisamos acessar response['data']['dados']
      final data = response['data']?['dados'] ?? response['data'] ?? response;

      print('✅ [BudgetEditDataSource] Orçamento carregado para edição');

      return BudgetEditDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      print('❌ [BudgetEditDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgetProductsComplete(int id) async {
    try {
      print(
          '🌐 [BudgetEditDataSource] GET /api/orcamentos/$id/produtos-completos');

      final response =
          await apiService.get('/api/orcamentos/$id/produtos-completos');

      print('📡 [BudgetEditDataSource] Response completo: $response');
      print('📡 [BudgetEditDataSource] response[data]: ${response['data']}');
      print(
          '📡 [BudgetEditDataSource] response[data][dados]: ${response['data']?['dados']}');

      // ApiService envolve em { success: true, data: {...} }
      // A API retorna: data: { dados: { orcamento_id, total_produtos, produtos: [...] } }
      final data = response['data']?['dados'] ?? response['data'] ?? response;

      print('✅ [BudgetEditDataSource] Dados extraídos: ${data.keys}');
      print(
          '✅ [BudgetEditDataSource] Total de produtos: ${data['total_produtos']}');
      print(
          '✅ [BudgetEditDataSource] Produtos array length: ${(data['produtos'] as List?)?.length}');

      return Map<String, dynamic>.from(data as Map);
    } on DioException catch (e) {
      print('❌ [BudgetEditDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<BudgetEditDto> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  }) async {
    try {
      print('🌐 [BudgetEditDataSource] PUT /api/orcamentos/$id');

      final Map<String, dynamic> body = {};

      if (name != null) body['nome'] = name;
      if (validityDays != null) body['orc_dias_validade'] = validityDays;
      if (validityDate != null) {
        body['orc_data_validade'] = validityDate.toIso8601String();
      }
      if (status != null) body['orc_status'] = status;
      if (selectedProductIds != null) {
        body['produtos_selecionados'] = selectedProductIds;
      }

      print('📋 [BudgetEditDataSource] Body: $body');

      final response = await apiService.put('/api/orcamentos/$id', body);
      print('📡 [BudgetEditDataSource] Response: $response');

      // ApiService envolve em { success: true, data: {...} }
      // Então precisamos acessar response['data']['dados']
      final data = response['data']?['dados'] ?? response['data'] ?? response;

      print('✅ [BudgetEditDataSource] Orçamento atualizado');

      return BudgetEditDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      print('❌ [BudgetEditDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Timeout na conexão com o servidor');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Orçamento não encontrado');
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
