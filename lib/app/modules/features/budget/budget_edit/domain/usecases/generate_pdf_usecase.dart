import 'package:dartz/dartz.dart';

import '../../../../../../shared/utils/email_validator.dart';
import '../../../shared/errors/budget_failure.dart';
import '../repositories/budget_pdf_repository.dart';

class GeneratePdfUseCase {
  final BudgetPdfRepository repository;

  GeneratePdfUseCase(this.repository);

  Future<Either<BudgetFailure, PdfResult>> call(
      GeneratePdfParams params) async {
    if (params.orcamentoId <= 0) {
      return const Left(ValidationFailure('ID do orçamento inválido'));
    }

    if (params.nomeVendedor.trim().isEmpty) {
      return const Left(ValidationFailure('Nome do vendedor é obrigatório'));
    }

    if (params.cargo.trim().isEmpty) {
      return const Left(ValidationFailure('Cargo é obrigatório'));
    }

    if (params.telefone.trim().isEmpty) {
      return const Left(ValidationFailure('Telefone é obrigatório'));
    }

    if (params.emailVendedor.trim().isEmpty) {
      return const Left(ValidationFailure('E-mail do vendedor é obrigatório'));
    }

    if (!EmailValidator.isValid(params.emailVendedor.trim())) {
      return const Left(ValidationFailure('E-mail do vendedor inválido'));
    }

    return await repository.generatePdf(params);
  }
}
