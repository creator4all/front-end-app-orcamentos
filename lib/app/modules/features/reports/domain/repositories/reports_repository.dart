import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/report_budget.dart';
import '../entities/report_user.dart';

/// Interface abstrata do repositório de relatórios.
///
/// Define os contratos que a camada de dados deve implementar.
/// Segue o princípio de inversão de dependência (Dependency Inversion).
abstract class ReportsRepository {
  /// Busca usuários de um parceiro com estatísticas de vendas.
  ///
  /// [partnerId] - ID do parceiro (empresa)
  /// [dataInicio] - Data inicial para filtrar orçamentos (opcional)
  /// [dataFim] - Data final para filtrar orçamentos (opcional)
  ///
  /// Retorna [Either] com [Failure] em caso de erro ou [List<ReportUser>] em caso de sucesso.
  Future<Either<Failure, List<ReportUser>>> getPartnerUsers(
    int partnerId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  /// Busca orçamentos de um usuário específico.
  ///
  /// [userId] - ID do usuário
  /// [dataInicio] - Data inicial para filtrar orçamentos (opcional)
  /// [dataFim] - Data final para filtrar orçamentos (opcional)
  /// [status] - Filtrar por status específico (opcional)
  ///
  /// Retorna [Either] com [Failure] em caso de erro ou [List<ReportBudget>] em caso de sucesso.
  Future<Either<Failure, List<ReportBudget>>> getUserBudgets(
    int userId, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
  });

  /// Busca todos os orçamentos de um parceiro.
  ///
  /// [partnerId] - ID do parceiro (empresa)
  /// [dataInicio] - Data inicial para filtrar orçamentos (opcional)
  /// [dataFim] - Data final para filtrar orçamentos (opcional)
  ///
  /// Retorna [Either] com [Failure] em caso de erro ou [List<ReportBudget>] em caso de sucesso.
  Future<Either<Failure, List<ReportBudget>>> getPartnerSales(
    int partnerId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  });
}
