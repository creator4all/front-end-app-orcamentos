import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';

/// DataSource abstrato para operações de orçamento multi-cidades
abstract class MultiCityBudgetRemoteDataSource {
  /// Busca os censos escolares para múltiplas cidades
  Future<Map<int, CensoEscolarEntity>> buscarCensosMultiCidade(
    List<int> cidadeIds,
  );

  /// Preview do orçamento multi-cidades (sem salvar)
  Future<Map<String, dynamic>> previewMultiCidade({
    required String nome,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
  });

  /// Cria um novo orçamento multi-cidades
  Future<int> criarMultiCidade({
    required String nome,
    required int diasValidade,
    required int usuarioId,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
    int? partnerDestinoId,
  });

  /// Atualiza as cidades de um orçamento existente
  Future<void> atualizarCidades({
    required int budgetId,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
  });
}
