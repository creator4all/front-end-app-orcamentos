import '../../domain/repositories/budget_pdf_repository.dart';

/// DTO para resposta da geração de PDF
class PdfResponseDto {
  final String pdfBase64;
  final String? nomeArquivo;

  const PdfResponseDto({
    required this.pdfBase64,
    this.nomeArquivo,
  });

  factory PdfResponseDto.fromJson(Map<String, dynamic> json) {
    // A API pode retornar o PDF em diferentes campos
    final pdf =
        json['pdf'] ?? json['pdf_base64'] ?? json['dados']?['pdf'] ?? '';
    final nome = json['nome_arquivo'] ??
        json['filename'] ??
        json['dados']?['nome_arquivo'];

    return PdfResponseDto(
      pdfBase64: pdf as String,
      nomeArquivo: nome as String?,
    );
  }

  /// Converte para entidade de domínio
  PdfResult toEntity() {
    return PdfResult(
      pdfBase64: pdfBase64,
      nomeArquivo: nomeArquivo,
    );
  }
}
