import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/repositories/budget_pdf_repository.dart';
import '../datasources/budget_pdf_remote_datasource.dart';

class BudgetPdfRepositoryImpl implements BudgetPdfRepository {
  final BudgetPdfRemoteDataSource _dataSource;

  BudgetPdfRepositoryImpl(this._dataSource);

  @override
  Future<Either<BudgetFailure, PdfResult>> generatePdf(
    GeneratePdfParams params,
  ) async {
    try {
      final dto = await _dataSource.generatePdf(
        params.orcamentoId,
        params.toJson(),
      );

      return Right(dto.toEntity());
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
