import '../../../../../../shared/core/http/app_http_client.dart';
import '../models/pdf_response_dto.dart';
import 'budget_pdf_remote_datasource.dart';

/// Implementação do datasource remoto para geração de PDF
class BudgetPdfRemoteDataSourceImpl implements BudgetPdfRemoteDataSource {
  final AppHttpClient _client;

  BudgetPdfRemoteDataSourceImpl(this._client);

  @override
  Future<PdfResponseDto> generatePdf(
    int orcamentoId,
    Map<String, dynamic> requestData,
  ) async {
    print('📄 [PdfDataSource] Gerando PDF do orçamento ID: $orcamentoId');
    print('📋 [PdfDataSource] Dados: $requestData');

    final response = await _client.post(
      '/api/orcamentos/$orcamentoId/pdf',
      data: requestData,
    );

    print('🔍 [PdfDataSource] Resposta: ${response.statusCode}');

    if (!response.isSuccess) {
      final errorMsg = response.body['mensagem'] ??
          response.body['message'] ??
          'Erro ao gerar PDF';
      throw Exception(errorMsg);
    }

    // Extrair dados da resposta
    final data =
        response.body['dados'] ?? response.body['data'] ?? response.body;

    print('🔍 [PdfDataSource] Dados extraídos: ${data.runtimeType}');

    if (data is! Map<String, dynamic>) {
      throw Exception('Formato de resposta inválido');
    }

    return PdfResponseDto.fromJson(data);
  }
}
