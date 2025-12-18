import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/repositories/indicators_repository.dart';
import '../datasources/indicators_remote_datasource.dart';

/// Implementação do repositório para indicadores de produtos
class IndicatorsRepositoryImpl implements IndicatorsRepository {
  final IndicatorsRemoteDataSource _dataSource;

  IndicatorsRepositoryImpl(this._dataSource);

  @override
  Future<Either<BudgetFailure, Unit>> saveIndicators(
    SaveIndicatorsParams params,
  ) async {
    try {
      print('💾 [IndicatorsRepository] Iniciando salvamento de indicadores...');

      await _dataSource.saveIndicators(
        params.orcamentoId,
        params.produtoId,
        params.toJson(),
      );

      print('✅ [IndicatorsRepository] Indicadores salvos com sucesso');
      return const Right(unit);
    } on Exception catch (e) {
      print('❌ [IndicatorsRepository] Erro: $e');
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(message));
    } catch (e) {
      print('❌ [IndicatorsRepository] Erro desconhecido: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
