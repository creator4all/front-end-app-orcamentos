import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../data/datasources/census_remote_datasource.dart';
import '../../data/models/budget_census_dto.dart';

/// Use case para buscar dados do censo de um orçamento
/// Suporta tanto orçamentos de cidade única quanto multi-cidade
class GetBudgetCensusUseCase {
  final CensusRemoteDataSource _dataSource;

  GetBudgetCensusUseCase(this._dataSource);

  /// Busca os dados do censo do orçamento
  /// Retorna [BudgetCensusDto] com cidades e censo agregado
  Future<Either<BudgetFailure, BudgetCensusDto>> call(int budgetId) async {
    try {
      final result = await _dataSource.getBudgetCensus(budgetId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar censo: ${e.toString()}'));
    }
  }
}
