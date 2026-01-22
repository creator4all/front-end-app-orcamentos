import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/report_budget.dart';
import '../repositories/reports_repository.dart';

/// Use case para buscar orçamentos de um usuário específico.
///
/// Encapsula a lógica de negócio para buscar orçamentos criados por um usuário,
/// com suporte a filtros de data e status.
class GetUserBudgetsUsecase {
  final ReportsRepository repository;

  GetUserBudgetsUsecase(this.repository);

  /// Executa o use case.
  ///
  /// [userId] - ID do usuário
  /// [dataInicio] - Data inicial para filtrar orçamentos (opcional)
  /// [dataFim] - Data final para filtrar orçamentos (opcional)
  /// [status] - Filtrar por status específico (opcional)
  ///
  /// Retorna [Either] com [Failure] em caso de erro ou [List<ReportBudget>] em caso de sucesso.
  Future<Either<Failure, List<ReportBudget>>> call(
    int userId, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
  }) {
    return repository.getUserBudgets(
      userId,
      dataInicio: dataInicio,
      dataFim: dataFim,
      status: status,
    );
  }
}
