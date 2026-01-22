import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/report_budget.dart';
import '../../domain/entities/report_user.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_datasource.dart';

/// Implementação do repositório de relatórios.
///
/// Coordena o acesso ao datasource e trata erros retornando [Either].
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsDatasource datasource;

  ReportsRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<ReportUser>>> getPartnerUsers(
    int partnerId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      final dtos = await datasource.getPartnerUsers(
        partnerId,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar usuários: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReportBudget>>> getUserBudgets(
    int userId, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
  }) async {
    try {
      final dtos = await datasource.getUserBudgets(
        userId,
        dataInicio: dataInicio,
        dataFim: dataFim,
        status: status,
      );
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar orçamentos: ${e.toString()}'));
    }
  }
}
