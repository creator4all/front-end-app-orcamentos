import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/repositories/budget_pdf_repository.dart';
import '../datasources/budget_pdf_remote_datasource.dart';

/// Implementação do repositório para geração de PDF
class BudgetPdfRepositoryImpl implements BudgetPdfRepository {
  final BudgetPdfRemoteDataSource _dataSource;

  BudgetPdfRepositoryImpl(this._dataSource);

  @override
  Future<Either<BudgetFailure, PdfResult>> generatePdf(
    GeneratePdfParams params,
  ) async {
    try {
      print('📄 [PdfRepository] Iniciando geração de PDF...');

      final dto = await _dataSource.generatePdf(
        params.orcamentoId,
        params.toJson(),
      );

      print('✅ [PdfRepository] PDF gerado com sucesso');
      return Right(dto.toEntity());
    } on Exception catch (e) {
      print('❌ [PdfRepository] Erro: $e');
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(message));
    } catch (e) {
      print('❌ [PdfRepository] Erro desconhecido: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
