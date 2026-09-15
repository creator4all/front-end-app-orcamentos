import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/data/datasources/budget_edit_remote_datasource.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/data/repositories/budget_edit_repository_impl.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/budget_update_dto.dart';
import 'package:multimidiaapp/app/shared/core/errors/api_error_message.dart';
import 'package:multimidiaapp/app/shared/core/errors/http_exceptions.dart';

const _sqlError = 'SQLSTATE[22003]: Numeric value out of range: 1264 Out of '
    "range value for column 'orc_total' at row 1";

/// Toda chamada ao datasource lança a exceção configurada.
class _FailingDataSource implements BudgetEditRemoteDataSource {
  final Exception exception;

  _FailingDataSource(this.exception);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw exception;
}

void main() {
  const update = BudgetUpdateDto(
    nome: 'projeto educacao 129',
    diasValidade: 60,
    status: 'pendente',
    total: 100,
    cidades: [11, 12],
    isArchived: false,
    produtos: [],
  );

  group('BudgetEditRepositoryImpl', () {
    test('não expõe o SQL quando o versionamento falha com erro 500', () async {
      final repository = BudgetEditRepositoryImpl(
        _FailingDataSource(
          const InternalServerException(message: _sqlError),
        ),
      );

      final result = await repository.versionMultiCityBudgetWithDto(
        budgetId: 55,
        updateData: update,
      );

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, ApiErrorMessage.serverFailure);
        },
        (_) => fail('deveria ter falhado'),
      );
    });

    test('não expõe o SQL quando o servidor responde 400 com erro de banco',
        () async {
      final repository = BudgetEditRepositoryImpl(
        _FailingDataSource(const BadRequestException(message: _sqlError)),
      );

      final result = await repository.versionBudgetWithDto(
        budgetId: 55,
        updateData: update,
      );

      result.fold(
        (failure) => expect(failure.message, ApiErrorMessage.serverFailure),
        (_) => fail('deveria ter falhado'),
      );
    });

    test('mantém mensagens de negócio do servidor em erros 4xx', () async {
      final repository = BudgetEditRepositoryImpl(
        _FailingDataSource(
          const BadRequestException(message: 'Orçamento já aprovado'),
        ),
      );

      final result = await repository.versionBudgetWithDto(
        budgetId: 55,
        updateData: update,
      );

      result.fold(
        (failure) => expect(failure.message, 'Orçamento já aprovado'),
        (_) => fail('deveria ter falhado'),
      );
    });

    test('usa mensagem genérica para exceções inesperadas', () async {
      final repository = BudgetEditRepositoryImpl(
        _FailingDataSource(const FormatException('campo orc_total inválido')),
      );

      final result = await repository.updateBudgetWithDto(
        budgetId: 55,
        updateData: update,
      );

      result.fold(
        (failure) => expect(failure.message, budgetSaveErrorMessage),
        (_) => fail('deveria ter falhado'),
      );
    });
  });
}
