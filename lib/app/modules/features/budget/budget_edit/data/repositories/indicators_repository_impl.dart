import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/repositories/indicators_repository.dart';
import '../datasources/indicators_remote_datasource.dart';

class IndicatorsRepositoryImpl implements IndicatorsRepository {
  final IndicatorsRemoteDataSource _dataSource;

  IndicatorsRepositoryImpl(this._dataSource);

  @override
  Future<Either<BudgetFailure, Unit>> saveIndicators(
    SaveIndicatorsParams params,
  ) async {
    try {
      await _dataSource.saveIndicators(
        params.orcamentoId,
        params.produtoId,
        params.toJson(),
      );

      return const Right(unit);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
