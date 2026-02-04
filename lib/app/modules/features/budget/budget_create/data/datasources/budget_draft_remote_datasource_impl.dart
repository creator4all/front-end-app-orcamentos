import '../../../../../../../app/shared/core/http/app_http_client.dart';
import '../../../../../../../app/shared/errors/http_exception.dart';
import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/repositories/budget_draft_repository.dart';
import '../models/budget_draft_dto.dart';
import 'budget_draft_remote_datasource.dart';

class BudgetDraftRemoteDataSourceImpl implements BudgetDraftRemoteDataSource {
  final AppHttpClient client;

  BudgetDraftRemoteDataSourceImpl(this.client);

  @override
  Future<BudgetDraftEntity> createDraft(CreateBudgetDraftParams params) async {
    const url = '/api/orcamentos/';
    final response = await client.post(url, data: params.toJson());

    if (!response.isSuccess) {
      throw HttpException(
        statusCode: response.statusCode ?? 0,
        message: response.body['mensagem'] ?? 'Erro ao criar orçamento',
      );
    }

    var data = response.body['dados'];

    if (data == null) {
      throw Exception('Resposta da API não contém dados válidos');
    }

    // API às vezes retorna List ao invés de Map - normalizar para Map
    if (data is List) {
      if (data.isEmpty) {
        throw Exception('Array de dados está vazio');
      }
      data = data.first;
    }

    if (data is! Map) {
      throw Exception(
          'Formato inesperado: dados não é Map. Tipo: ${data.runtimeType}');
    }

    final dto = BudgetDraftDto.fromJson(Map<String, dynamic>.from(data));
    return dto.toEntity();
  }

  @override
  Future<BudgetDraftEntity> getDraftById(int budgetId) async {
    final url = '/api/orcamentos/$budgetId';
    final response = await client.get(url);

    if (!response.isSuccess) {
      throw HttpException(
        statusCode: response.statusCode ?? 0,
        message: response.body['mensagem'] ?? 'Erro ao buscar orçamento',
      );
    }

    var data = response.body['dados'] ?? response.body['data'];

    if (data == null) {
      throw Exception('Orçamento não encontrado');
    }

    // API às vezes retorna List ao invés de Map - normalizar para Map
    if (data is List) {
      if (data.isEmpty) {
        throw Exception('Array de dados está vazio');
      }
      data = data.first;
    }

    if (data is! Map) {
      throw Exception(
          'Formato inesperado: dados não é Map. Tipo: ${data.runtimeType}');
    }

    final dto = BudgetDraftDto.fromJson(Map<String, dynamic>.from(data));
    return dto.toEntity();
  }
}
