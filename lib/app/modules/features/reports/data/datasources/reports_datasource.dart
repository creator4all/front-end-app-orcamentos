import '../models/report_budget_dto.dart';
import '../models/report_user_dto.dart';

/// Interface abstrata do datasource de relatórios.
///
/// Define os contratos para acesso aos dados da API.
abstract class ReportsDatasource {
  /// Busca usuários de um parceiro com estatísticas de vendas.
  ///
  /// [partnerId] - ID do parceiro (empresa)
  /// [dataInicio] - Data inicial para filtrar orçamentos (opcional)
  /// [dataFim] - Data final para filtrar orçamentos (opcional)
  ///
  /// Retorna lista de [ReportUserDto].
  Future<List<ReportUserDto>> getPartnerUsers(
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
  /// Retorna lista de [ReportBudgetDto].
  Future<List<ReportBudgetDto>> getUserBudgets(
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
  /// Retorna lista de [ReportBudgetDto].
  Future<List<ReportBudgetDto>> getPartnerSales(
    int partnerId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  });
}
