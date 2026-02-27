import '../models/pdf_response_dto.dart';

/// Interface do datasource remoto para geração de PDF
abstract class BudgetPdfRemoteDataSource {
  /// Gera PDF do orçamento
  ///
  /// [orcamentoId] ID do orçamento
  /// [requestData] Dados da requisição (nome vendedor, cargo, telefone, etc)
  /// Retorna [PdfResponseDto] com o PDF em base64
  /// Lança exceção em caso de erro
  Future<PdfResponseDto> generatePdf(
      int orcamentoId, Map<String, dynamic> requestData);
}
