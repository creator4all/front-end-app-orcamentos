import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../repositories/budget_pdf_repository.dart';

/// Caso de uso para geração de PDF do orçamento
class GeneratePdfUseCase {
  final BudgetPdfRepository repository;

  GeneratePdfUseCase(this.repository);

  /// Executa a geração do PDF
  ///
  /// [params] Parâmetros para geração do PDF
  /// Retorna [PdfResult] com o PDF em base64 ou [BudgetFailure] em caso de erro
  Future<Either<BudgetFailure, PdfResult>> call(
      GeneratePdfParams params) async {
    // Validações
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

    return await repository.generatePdf(params);
  }
}
