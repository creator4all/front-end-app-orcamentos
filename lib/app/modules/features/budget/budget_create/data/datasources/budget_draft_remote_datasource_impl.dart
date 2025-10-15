import 'package:dio/dio.dart';

import '../../../../../../../services/api_service.dart';
import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/repositories/budget_draft_repository.dart';
import '../models/budget_draft_dto.dart';
import 'budget_draft_remote_datasource.dart';

/// Implementação concreta do BudgetDraftRemoteDataSource usando Dio/ApiService
class BudgetDraftRemoteDataSourceImpl implements BudgetDraftRemoteDataSource {
  final ApiService apiService;

  BudgetDraftRemoteDataSourceImpl(this.apiService);

  @override
  Future<BudgetDraftEntity> createDraft(CreateBudgetDraftParams params) async {
    try {
      const url = '/api/orcamentos/';
      final payload = params.toJson();

      print('🌐 [BudgetDraftDataSource] Criando orçamento: $url');
      print('📦 [BudgetDraftDataSource] Payload: $payload');

      final response = await apiService.post(url, payload);
      print('📡 [BudgetDraftDataSource] Resposta da API: $response');

      // Extrair dados da resposta
      final data = response['dados'] ?? response['data'] ?? response;

      print('✅ [BudgetDraftDataSource] Orçamento criado com sucesso');

      // Converter para Entity usando DTO
      final dto =
          BudgetDraftDto.fromJson(Map<String, dynamic>.from(data as Map));
      return dto.toEntity();
    } on DioException catch (e) {
      print('❌ [BudgetDraftDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [BudgetDraftDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<BudgetDraftEntity> getDraftById(int budgetId) async {
    try {
      final url = '/api/orcamentos/$budgetId';
      print('🔍 [BudgetDraftDataSource] Buscando orçamento ID: $budgetId');

      final response = await apiService.get(url);

      // Extrair dados da resposta
      final data = response['dados'] ?? response['data'] ?? response;

      print('✅ [BudgetDraftDataSource] Orçamento carregado com sucesso');

      // Converter para Entity usando DTO
      final dto =
          BudgetDraftDto.fromJson(Map<String, dynamic>.from(data as Map));
      return dto.toEntity();
    } on DioException catch (e) {
      print('❌ [BudgetDraftDataSource] Erro Dio: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [BudgetDraftDataSource] Erro desconhecido: $e');
      rethrow;
    }
  }

  @override
  Future<bool> validateBudgetCreation(CreateBudgetDraftParams params) async {
    try {
      // Por enquanto, retorna true
      // Futuramente pode ter endpoint de validação específico
      print('✅ [BudgetDraftDataSource] Validação básica passou');
      return true;
    } catch (e) {
      print('❌ [BudgetDraftDataSource] Erro na validação: $e');
      return false;
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
          return Exception('Orçamento não encontrado');
        } else if (statusCode == 401) {
          return Exception('Não autorizado');
        } else if (statusCode == 403) {
          return Exception('Acesso negado');
        } else if (statusCode == 422) {
          return Exception(
              'Dados inválidos: ${error.response?.data?['message'] ?? 'Erro de validação'}');
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
