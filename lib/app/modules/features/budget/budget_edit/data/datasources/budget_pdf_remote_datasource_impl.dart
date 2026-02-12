import '../../../../../../shared/core/http/app_http_client.dart';
import '../models/pdf_response_dto.dart';
import 'budget_pdf_remote_datasource.dart';

class BudgetPdfRemoteDataSourceImpl implements BudgetPdfRemoteDataSource {
  final AppHttpClient _client;

  BudgetPdfRemoteDataSourceImpl(this._client);

  @override
  Future<PdfResponseDto> generatePdf(
    int orcamentoId,
    Map<String, dynamic> requestData,
  ) async {
    final response = await _client.post(
      '/api/orcamentos/$orcamentoId/pdf',
      data: requestData,
    );

    if (!response.isSuccess) {
      final errorMsg = response.body['mensagem'] ??
          response.body['message'] ??
          'Erro ao gerar PDF';
      throw Exception(errorMsg);
    }

    final data = response.body['dados'] as Map<String, dynamic>;
    return PdfResponseDto.fromJson(data);
  }
}
