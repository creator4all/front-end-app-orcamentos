import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../repositories/budget_draft_repository.dart';

/// Caso de uso para validar dados antes de criar um orçamento
class ValidateBudgetDataUseCase {
  final BudgetDraftRepository _repository;

  ValidateBudgetDataUseCase(this._repository);

  /// Executa a validação dos dados do orçamento
  /// Retorna Either<BudgetFailure, bool>
  Future<Either<BudgetFailure, bool>> call(
    CreateBudgetDraftParams params,
  ) async {
    try {
      // Validações básicas de campos obrigatórios
      if (!params.isValid) {
        return const Left(ValidationFailure(
          'Dados inválidos: Parceiro, Estado e Cidade são obrigatórios',
        ));
      }

      // Validação de email se fornecido
      if (params.responsibleEmail != null &&
          params.responsibleEmail!.isNotEmpty) {
        if (!_isValidEmail(params.responsibleEmail!)) {
          return const Left(ValidationFailure(
            'Email do responsável é inválido',
          ));
        }
      }

      // Validação de data de validade se fornecida
      if (params.validityDate != null) {
        if (params.validityDate!.isBefore(DateTime.now())) {
          return const Left(ValidationFailure(
            'Data de validade deve ser futura',
          ));
        }
      }

      // Validação adicional no repositório (regras de negócio do backend)
      return await _repository.validateBudgetCreation(params);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Valida formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
