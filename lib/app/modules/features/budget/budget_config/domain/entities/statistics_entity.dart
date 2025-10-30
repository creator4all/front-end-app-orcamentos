import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Entidade que representa estatísticas agregadas de produtos
/// Usada quando não há produtos individuais carregados (apenas contadores)
class StatisticsEntity extends Equatable {
  /// Quantidade total de produtos disponíveis
  final int totalProdutos;

  /// Quantidade de produtos selecionados pelo usuário
  final int produtosSelecionados;

  /// Valor total de todos os produtos (selecionados + não selecionados)
  final double valorTotal;

  /// Valor apenas dos produtos selecionados
  final double valorSelecionado;

  const StatisticsEntity({
    required this.totalProdutos,
    required this.produtosSelecionados,
    required this.valorTotal,
    required this.valorSelecionado,
  });

  // ========== Getters Úteis ==========

  /// Valor dos produtos não selecionados
  double get valorNaoSelecionado => valorTotal - valorSelecionado;

  /// Percentual de produtos selecionados (0-100)
  double get percentualSelecionado {
    if (totalProdutos == 0) return 0.0;
    return (produtosSelecionados / totalProdutos) * 100;
  }

  /// Percentual do valor selecionado em relação ao total (0-100)
  double get percentualValorSelecionado {
    if (valorTotal == 0) return 0.0;
    return (valorSelecionado / valorTotal) * 100;
  }

  /// Verifica se todos os produtos estão selecionados
  bool get todosSelecionados {
    return totalProdutos > 0 && produtosSelecionados == totalProdutos;
  }

  /// Verifica se algum produto está selecionado
  bool get temProdutosSelecionados => produtosSelecionados > 0;

  /// Verifica se tem produtos disponíveis
  bool get temProdutos => totalProdutos > 0;

  /// Verifica se a seleção está parcial (nem todos, nem nenhum)
  bool get selecaoParcial {
    return produtosSelecionados > 0 && produtosSelecionados < totalProdutos;
  }

  /// Quantidade de produtos não selecionados
  int get produtosNaoSelecionados => totalProdutos - produtosSelecionados;

  /// Valor médio por produto (considerando todos)
  double get valorMedioPorProduto {
    if (totalProdutos == 0) return 0.0;
    return valorTotal / totalProdutos;
  }

  /// Valor médio dos produtos selecionados
  double get valorMedioSelecionado {
    if (produtosSelecionados == 0) return 0.0;
    return valorSelecionado / produtosSelecionados;
  }

  // ========== Formatação para Exibição ==========

  /// Formata o valor total para exibição (padrão brasileiro)
  String get formattedValorTotal {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(valorTotal);
  }

  /// Formata o valor selecionado para exibição (padrão brasileiro)
  String get formattedValorSelecionado {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(valorSelecionado);
  }

  /// Formata o percentual de seleção
  String get formattedPercentualSelecionado =>
      '${percentualSelecionado.toStringAsFixed(1)}%';

  /// Resumo textual da seleção (ex: "28 de 35 produtos")
  String get resumoSelecao =>
      '$produtosSelecionados de $totalProdutos produtos';

  @override
  List<Object?> get props => [
        totalProdutos,
        produtosSelecionados,
        valorTotal,
        valorSelecionado,
      ];

  /// Cria uma cópia com campos alterados
  StatisticsEntity copyWith({
    int? totalProdutos,
    int? produtosSelecionados,
    double? valorTotal,
    double? valorSelecionado,
  }) {
    return StatisticsEntity(
      totalProdutos: totalProdutos ?? this.totalProdutos,
      produtosSelecionados: produtosSelecionados ?? this.produtosSelecionados,
      valorTotal: valorTotal ?? this.valorTotal,
      valorSelecionado: valorSelecionado ?? this.valorSelecionado,
    );
  }

  /// Cria estatísticas vazias
  factory StatisticsEntity.empty() {
    return const StatisticsEntity(
      totalProdutos: 0,
      produtosSelecionados: 0,
      valorTotal: 0.0,
      valorSelecionado: 0.0,
    );
  }

  @override
  String toString() {
    return 'StatisticsEntity(total: $totalProdutos, selecionados: $produtosSelecionados, valorTotal: $valorTotal, valorSelecionado: $valorSelecionado)';
  }
}
