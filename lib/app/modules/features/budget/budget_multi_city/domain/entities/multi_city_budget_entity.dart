import 'package:equatable/equatable.dart';

import '../../../budget_config/domain/entities/censo_escolar_entity.dart';

/// Entidade que representa um orçamento multi-cidades
/// Contém o censo escolar de múltiplas cidades
class MultiCityBudgetEntity extends Equatable {
  /// Nome do orçamento definido pelo usuário
  final String nome;

  /// Lista de censos escolares (um por cidade)
  final List<CensoEscolarEntity> censosCidades;

  /// ID da cidade atualmente selecionada no dropdown (null = agregado)
  final int? cidadeSelecionadaId;

  /// Dias de validade do orçamento
  final int diasValidade;

  /// ID do parceiro destino (opcional)
  final int? partnerDestinoId;

  const MultiCityBudgetEntity({
    required this.nome,
    required this.censosCidades,
    this.cidadeSelecionadaId,
    this.diasValidade = 60,
    this.partnerDestinoId,
  });

  /// Retorna os IDs de todas as cidades
  List<int> get cidadeIds => censosCidades.map((c) => c.cidadeId).toList();

  /// Retorna o número de cidades selecionadas
  int get quantidadeCidades => censosCidades.length;

  /// Retorna o censo da cidade selecionada ou null se visualização agregada
  CensoEscolarEntity? get censoSelecionado {
    if (cidadeSelecionadaId == null) return null;
    try {
      return censosCidades.firstWhere((c) => c.cidadeId == cidadeSelecionadaId);
    } catch (_) {
      return null;
    }
  }

  /// Valor total agregado de todas as cidades
  double get valorTotalAgregado {
    return censosCidades.fold(0.0, (sum, censo) => sum + censo.valorTotal);
  }

  /// Cria uma cópia com cidade selecionada alterada
  MultiCityBudgetEntity copyWith({
    String? nome,
    List<CensoEscolarEntity>? censosCidades,
    int? cidadeSelecionadaId,
    bool clearCidadeSelecionada = false,
    int? diasValidade,
    int? partnerDestinoId,
  }) {
    return MultiCityBudgetEntity(
      nome: nome ?? this.nome,
      censosCidades: censosCidades ?? this.censosCidades,
      cidadeSelecionadaId: clearCidadeSelecionada
          ? null
          : (cidadeSelecionadaId ?? this.cidadeSelecionadaId),
      diasValidade: diasValidade ?? this.diasValidade,
      partnerDestinoId: partnerDestinoId ?? this.partnerDestinoId,
    );
  }

  @override
  List<Object?> get props => [
        nome,
        censosCidades,
        cidadeSelecionadaId,
        diasValidade,
        partnerDestinoId,
      ];

  @override
  String toString() {
    return 'MultiCityBudgetEntity(nome: $nome, cidades: $quantidadeCidades, valorTotal: R\$ $valorTotalAgregado)';
  }
}
