import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/data/datasources/budget_detail_remote_datasource_impl.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/data/repositories/budget_detail_repository_impl.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/save_budget_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/budget_update_dto.dart';
import 'package:multimidiaapp/app/shared/core/errors/http_exceptions.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/http/http_response.dart';

class _BudgetClient implements AppHttpClient {
  final bool rejectUpdate;
  Map<String, dynamic>? sent;
  _BudgetClient({this.rejectUpdate = false});

  @override
  Future<HttpResponse> put(String url,
      {dynamic data, HttpRequestConfig? config}) async {
    expect(url, '/api/orcamentos/42');
    sent = Map<String, dynamic>.from(data as Map);
    if (rejectUpdate) {
      throw const UnprocessableEntityException(message: 'Produto inválido');
    }
    // O cliente HTTP normaliza o array vazio retornado pelo PHP como data: [].
    return HttpResponse(body: {'data': []}, headers: {}, statusCode: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const update = BudgetUpdateDto(
    nome: 'Orçamento configurado',
    diasValidade: 30,
    status: 'pendente',
    total: 500,
    usuarioId: 7,
    partnerDestinoId: 9,
    cidades: [11, 12],
    isArchived: true,
    produtos: [],
  );

  test('fluxo ativo salva pelo DTO completo e aceita PUT sem dados', () async {
    final client = _BudgetClient();
    final useCase = SaveBudgetUseCase(BudgetDetailRepositoryImpl(
      BudgetDetailRemoteDataSourceImpl(client),
    ));
    final result = await useCase(budgetId: 42, updateData: update);

    result.fold(
        (failure) => fail(failure.message), (entity) => expect(entity, isNull));
    expect(client.sent, {
      'orc_nome': 'Orçamento configurado',
      'orc_dias_validade': 30,
      'orc_status': 'pendente',
      'orc_total': 500.0,
      'orc_usuario_id': 7,
      'orc_partner_destino_id': 9,
      'isArchived': true,
      'cidades': [11, 12],
      'indicadores': [],
      'produtos': [],
    });
  });

  test('fluxo ativo propaga falha de validação sem confirmar salvamento',
      () async {
    final client = _BudgetClient(rejectUpdate: true);
    final useCase = SaveBudgetUseCase(BudgetDetailRepositoryImpl(
      BudgetDetailRemoteDataSourceImpl(client),
    ));
    final result = await useCase(budgetId: 42, updateData: update);

    expect(result.isLeft(), isTrue);
    result.fold((failure) => expect(failure.message, 'Produto inválido'),
        (_) => fail('Sucesso indevido'));
  });
}
