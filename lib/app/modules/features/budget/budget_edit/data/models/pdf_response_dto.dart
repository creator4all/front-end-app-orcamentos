import '../../domain/repositories/budget_pdf_repository.dart';

class PdfResponseDto {
  final String pdfBase64;
  final String? nomeArquivo;

  const PdfResponseDto({
    required this.pdfBase64,
    this.nomeArquivo,
  });

  factory PdfResponseDto.fromJson(Map<String, dynamic> json) {
    return PdfResponseDto(
      pdfBase64: json['pdf'] as String? ?? '',
      nomeArquivo: json['nome_arquivo'] as String?,
    );
  }

  PdfResult toEntity() {
    return PdfResult(
      pdfBase64: pdfBase64,
      nomeArquivo: nomeArquivo,
    );
  }
}
