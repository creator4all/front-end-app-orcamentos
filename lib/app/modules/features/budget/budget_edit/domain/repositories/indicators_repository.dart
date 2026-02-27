import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';

/// Parâmetros para salvar indicadores de um produto
class SaveIndicatorsParams {
  final int orcamentoId;
  final int produtoId;
  final List<Map<String, dynamic>> indicadores;

  const SaveIndicatorsParams({
    required this.orcamentoId,
    required this.produtoId,
    required this.indicadores,
  });

  Map<String, dynamic> toJson() {
    return {
      'indicadores': indicadores,
    };
  }
}

/// Interface do repositório para indicadores de produtos
abstract class IndicatorsRepository {
  /// Salva indicadores de um produto em um orçamento
  ///
  /// [params] Parâmetros com orcamentoId, produtoId e lista de indicadores
  /// Retorna [Unit] em caso de sucesso ou [BudgetFailure] em caso de erro
  Future<Either<BudgetFailure, Unit>> saveIndicators(
      SaveIndicatorsParams params);
}
