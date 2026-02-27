import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_draft_entity.dart';
import '../repositories/budget_draft_repository.dart';

class CreateDraftBudgetUseCase {
  final BudgetDraftRepository _repository;

  CreateDraftBudgetUseCase(this._repository);

  Future<Either<BudgetFailure, BudgetDraftEntity>> call(
    CreateBudgetDraftParams params,
  ) async {
    try {
      if (!params.isValid) {
        return const Left(ValidationFailure(
          'Dados inválidos para criar orçamento',
        ));
      }

      final result = await _repository.createDraft(params);

      return result.fold(
        (failure) => Left(failure),
        (draft) {
          if (!draft.isDraft) {
            return const Left(ValidationFailure(
              'Orçamento criado não está em estado de rascunho',
            ));
          }

          return Right(draft);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
