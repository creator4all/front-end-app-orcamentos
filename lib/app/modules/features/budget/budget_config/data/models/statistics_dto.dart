import '../../domain/entities/statistics_entity.dart';

/// DTO para parsing de estatísticas do JSON da API
class StatisticsDTO {
  final int totalProdutos;
  final int produtosSelecionados;
  final double valorTotal;
  final double valorSelecionado;

  StatisticsDTO({
    required this.totalProdutos,
    required this.produtosSelecionados,
    required this.valorTotal,
    required this.valorSelecionado,
  });

  /// Cria DTO a partir do JSON da API
  factory StatisticsDTO.fromJson(Map<String, dynamic> json) {
    return StatisticsDTO(
      totalProdutos: json['total_produtos'] as int? ?? 0,
      produtosSelecionados: json['produtos_selecionados'] as int? ?? 0,
      valorTotal: (json['valor_total'] as num?)?.toDouble() ?? 0.0,
      valorSelecionado: (json['valor_selecionado'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converte DTO para Entity
  StatisticsEntity toEntity() {
    return StatisticsEntity(
      totalProdutos: totalProdutos,
      produtosSelecionados: produtosSelecionados,
      valorTotal: valorTotal,
      valorSelecionado: valorSelecionado,
    );
  }

  /// Converte DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'total_produtos': totalProdutos,
      'produtos_selecionados': produtosSelecionados,
      'valor_total': valorTotal,
      'valor_selecionado': valorSelecionado,
    };
  }

  /// Cria DTO a partir de Entity
  factory StatisticsDTO.fromEntity(StatisticsEntity entity) {
    return StatisticsDTO(
      totalProdutos: entity.totalProdutos,
      produtosSelecionados: entity.produtosSelecionados,
      valorTotal: entity.valorTotal,
      valorSelecionado: entity.valorSelecionado,
    );
  }

  /// Cria estatísticas vazias
  factory StatisticsDTO.empty() {
    return StatisticsDTO(
      totalProdutos: 0,
      produtosSelecionados: 0,
      valorTotal: 0.0,
      valorSelecionado: 0.0,
    );
  }

  @override
  String toString() {
    return 'StatisticsDTO(total: $totalProdutos, selecionados: $produtosSelecionados, valorTotal: $valorTotal, valorSelecionado: $valorSelecionado)';
  }
}
