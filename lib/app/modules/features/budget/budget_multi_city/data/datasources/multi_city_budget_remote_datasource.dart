import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';

/// DataSource abstrato para operações de orçamento multi-cidades
abstract class MultiCityBudgetRemoteDataSource {
  /// Busca os censos escolares para múltiplas cidades
  Future<Map<int, CensoEscolarEntity>> buscarCensosMultiCidade(
    List<int> cidadeIds,
  );

  /// Cria um novo orçamento multi-cidades
  /// Retorna os dados completos do orçamento criado (categorias, cidades, censo_agregado)
  Future<Map<String, dynamic>> criarMultiCidade({
    required String nome,
    required int diasValidade,
    required int usuarioId,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
    int? partnerDestinoId,
  });
}
