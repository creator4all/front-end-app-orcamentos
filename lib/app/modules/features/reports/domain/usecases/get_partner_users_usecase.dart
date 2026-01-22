import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/report_user.dart';
import '../repositories/reports_repository.dart';

/// Use case para buscar usuários de um parceiro com estatísticas de vendas.
///
/// Encapsula a lógica de negócio para buscar usuários de uma empresa,
/// incluindo estatísticas de orçamentos por status.
class GetPartnerUsersUsecase {
  final ReportsRepository repository;

  GetPartnerUsersUsecase(this.repository);

  /// Executa o use case.
  ///
  /// [partnerId] - ID do parceiro (empresa)
  /// [dataInicio] - Data inicial para filtrar orçamentos (opcional)
  /// [dataFim] - Data final para filtrar orçamentos (opcional)
  ///
  /// Retorna [Either] com [Failure] em caso de erro ou [List<ReportUser>] em caso de sucesso.
  Future<Either<Failure, List<ReportUser>>> call(
    int partnerId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return repository.getPartnerUsers(
      partnerId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }
}
