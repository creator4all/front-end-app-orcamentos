import 'package:dio/dio.dart';

import '../../../../../../../services/api_service.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';
import 'budget_edit_remote_datasource.dart';

class BudgetEditRemoteDataSourceImpl implements BudgetEditRemoteDataSource {
  final ApiService apiService;

  BudgetEditRemoteDataSourceImpl(this.apiService);

  @override
  Future<BudgetEditDto> getBudgetForEdit(int id) async {
    try {
      final response = await apiService.get('/api/orcamentos/$id');

      // ApiService envolve em { success: true, data: {...} }
      // Então precisamos acessar response['data']['dados']
      final data = response['data']?['dados'] ?? response['data'] ?? response;

      return BudgetEditDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgetProductsComplete(int id) async {
    try {
      final response =
          await apiService.get('/api/orcamentos/$id/produtos-completos');

      // Verificar se API retornou erro
      if (response.containsKey('success') && response['success'] == false) {
        final errorMsg =
            response['error'] ?? response['message'] ?? 'Erro desconhecido';
        throw Exception('Erro ao buscar produtos: $errorMsg');
      }

      // ✅ Extração explícita igual ao budget_config (que funciona)
      // ApiService envolve em {success: true, data: {...}}
      if (!response.containsKey('data')) {
        throw Exception('Resposta do ApiService em formato inválido');
      }

      final data = response['data'] as Map<String, dynamic>;

      // API retorna: {dados: {orcamento_id, total_produtos, produtos: [...]}}
      if (!data.containsKey('dados')) {
        throw Exception('Resposta da API em formato inválido');
      }

      final dados = data['dados'] as Map<String, dynamic>;

      // Validar estrutura dos dados
      if (!dados.containsKey('produtos')) {
        throw Exception('Dados sem array de produtos');
      }

      return dados;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
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

      final response = await apiService.put('/api/orcamentos/$id', body);

      // ApiService envolve em { success: true, data: {...} }
      // Então precisamos acessar response['data']['dados']
      final data = response['data']?['dados'] ?? response['data'] ?? response;

      return BudgetEditDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BudgetEditDto> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      // Converter DTO para JSON (apenas campos não-nulos)
      final body = updateData.toJson();

      final response = await apiService.put('/api/orcamentos/$budgetId', body);

      // Extrair dados da resposta
      Map<String, dynamic> data;

      if (response.containsKey('dados')) {
        data = response['dados'] as Map<String, dynamic>;
      } else if (response.containsKey('data')) {
        final dataField = response['data'];
        if (dataField is Map && dataField.containsKey('dados')) {
          data = dataField['dados'] as Map<String, dynamic>;
        } else {
          data = dataField as Map<String, dynamic>;
        }
      } else {
        data = response;
      }

      return BudgetEditDto.fromJson(data);
    } on DioException catch (e) {
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
