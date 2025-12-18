import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';

/// Parâmetros para geração de PDF
class GeneratePdfParams {
  final int orcamentoId;
  final String nomeVendedor;
  final String cargo;
  final String telefone;
  final String? url;
  final String? logoBase64;

  const GeneratePdfParams({
    required this.orcamentoId,
    required this.nomeVendedor,
    required this.cargo,
    required this.telefone,
    this.url,
    this.logoBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome_vendedor': nomeVendedor,
      'cargo': cargo,
      'telefone': telefone,
      if (url != null && url!.isNotEmpty) 'url': url,
      if (logoBase64 != null && logoBase64!.isNotEmpty) 'logo': logoBase64,
    };
  }
}

/// Resultado da geração de PDF
class PdfResult {
  final String pdfBase64;
  final String? nomeArquivo;

  const PdfResult({
    required this.pdfBase64,
    this.nomeArquivo,
  });
}

/// Interface do repositório para geração de PDF
abstract class BudgetPdfRepository {
  /// Gera PDF do orçamento
  ///
  /// [params] Parâmetros para geração do PDF
  /// Retorna [PdfResult] com o PDF em base64 ou [BudgetFailure] em caso de erro
  Future<Either<BudgetFailure, PdfResult>> generatePdf(
      GeneratePdfParams params);
}
