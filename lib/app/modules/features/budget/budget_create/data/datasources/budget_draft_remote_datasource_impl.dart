import '../../../../../../../app/shared/core/http/app_http_client.dart';
import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/repositories/budget_draft_repository.dart';
import '../models/budget_draft_dto.dart';
import 'budget_draft_remote_datasource.dart';

class BudgetDraftRemoteDataSourceImpl implements BudgetDraftRemoteDataSource {
  final AppHttpClient client;

  BudgetDraftRemoteDataSourceImpl(this.client);

  @override
  Future<BudgetDraftEntity> createDraft(CreateBudgetDraftParams params) async {
    try {
      const url = '/api/orcamentos/';
      final response = await client.post(url, data: params.toJson());

      var data = response.body['dados'];

      if (data == null) {
        throw Exception('Resposta da API não contém dados válidos');
      }

      // ⚠️ IMPORTANTE: dados deve ser um Map (não List)
      if (data is List) {
        print('⚠️ [BudgetDraftRemoteDataSourceImpl] Aviso: dados é List, esperado Map');
        if (data.isNotEmpty) {
          data = data.first;
        } else {
          throw Exception('Array de dados está vazio');
        }
      }

      if (data is! Map) {
        throw Exception('Formato inesperado: dados não é Map. Tipo: ${data.runtimeType}');
      }

      print('✅ [BudgetDraftRemoteDataSourceImpl] Parseando orçamento criado com sucesso');
      final dto = BudgetDraftDto.fromJson(Map<String, dynamic>.from(data as Map));
      return dto.toEntity();
    } catch (e) {
      print('❌ [BudgetDraftRemoteDataSourceImpl] Erro ao criar orçamento: $e');
      rethrow;
    }
  }

  @override
  Future<BudgetDraftEntity> getDraftById(int budgetId) async {
    try {
      final url = '/api/orcamentos/$budgetId';
      final response = await client.get(url);

      var data = response.body['dados'] ?? response.body['data'];

      if (data == null) {
        throw Exception('Orçamento não encontrado');
      }

      // ⚠️ IMPORTANTE: dados deve ser um Map (não List)
      if (data is List) {
        print('⚠️ [BudgetDraftRemoteDataSourceImpl] Aviso: dados é List, esperado Map');
        if (data.isNotEmpty) {
          data = data.first;
        } else {
          throw Exception('Array de dados está vazio');
        }
      }

      if (data is! Map) {
        throw Exception('Formato inesperado: dados não é Map. Tipo: ${data.runtimeType}');
      }

      print('✅ [BudgetDraftRemoteDataSourceImpl] Parseando orçamento ${budgetId} com sucesso');
      final dto = BudgetDraftDto.fromJson(Map<String, dynamic>.from(data as Map));
      return dto.toEntity();
    } catch (e) {
      print('❌ [BudgetDraftRemoteDataSourceImpl] Erro ao buscar orçamento: $e');
      rethrow;
    }
  }

  @override
  Future<bool> validateBudgetCreation(CreateBudgetDraftParams params) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }
}
