import 'package:equatable/equatable.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

/// Estatísticas agregadas de produtos para exibição em resumos
class StatisticsEntity extends Equatable {
  final int totalProdutos;
  final int produtosSelecionados;
  final double valorTotal;
  final double valorSelecionado;

  const StatisticsEntity({
    required this.totalProdutos,
    required this.produtosSelecionados,
    required this.valorTotal,
    required this.valorSelecionado,
  });

  double get valorNaoSelecionado => valorTotal - valorSelecionado;

  double get percentualSelecionado {
    if (totalProdutos == 0) return 0.0;
    return (produtosSelecionados / totalProdutos) * 100;
  }

  double get percentualValorSelecionado {
    if (valorTotal == 0) return 0.0;
    return (valorSelecionado / valorTotal) * 100;
  }

  bool get todosSelecionados =>
      totalProdutos > 0 && produtosSelecionados == totalProdutos;

  bool get temProdutosSelecionados => produtosSelecionados > 0;

  bool get temProdutos => totalProdutos > 0;

  bool get selecaoParcial =>
      produtosSelecionados > 0 && produtosSelecionados < totalProdutos;

  int get produtosNaoSelecionados => totalProdutos - produtosSelecionados;

  double get valorMedioPorProduto {
    if (totalProdutos == 0) return 0.0;
    return valorTotal / totalProdutos;
  }

  double get valorMedioSelecionado {
    if (produtosSelecionados == 0) return 0.0;
    return valorSelecionado / produtosSelecionados;
  }

  String get formattedValorTotal => CurrencyUtils.formatBRL(valorTotal);

  String get formattedValorSelecionado =>
      CurrencyUtils.formatBRL(valorSelecionado);

  String get formattedPercentualSelecionado =>
      '${percentualSelecionado.toStringAsFixed(1)}%';

  String get resumoSelecao =>
      '$produtosSelecionados de $totalProdutos produtos';

  @override
  List<Object?> get props => [
        totalProdutos,
        produtosSelecionados,
        valorTotal,
        valorSelecionado,
      ];

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
