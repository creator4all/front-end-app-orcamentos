import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import 'product_entity.dart';
import 'statistics_entity.dart';

part 'subcategory_entity.g.dart';

@CopyWith()
class SubcategoryEntity extends Equatable {
  final int id;
  final String nome;
  final FractionalOrder ordem;

  final List<ProductEntity> produtos;

  final StatisticsEntity? estatisticas;

  const SubcategoryEntity({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.produtos,
    this.estatisticas,
  });

  bool get usandoEstatisticas => produtos.isEmpty && estatisticas != null;

  List<ProductEntity> get activeProdutos {
    return produtos.toList()..sort((a, b) => a.ordem.compareTo(b.ordem));
  }

  List<ProductEntity> get selectedProdutos {
    return produtos.where((p) => p.selecionado).toList();
  }

  List<ProductEntity> get unselectedProdutos {
    return produtos.where((p) => !p.selecionado).toList();
  }

  int get activeProductsCount {
    if (usandoEstatisticas) {
      return estatisticas!.totalProdutos;
    }
    return activeProdutos.length;
  }

  int get selectedProductsCount {
    if (usandoEstatisticas) {
      return estatisticas!.produtosSelecionados;
    }
    return selectedProdutos.length;
  }

  double get totalValue {
    if (usandoEstatisticas) {
      return estatisticas!.valorSelecionado;
    }
    return selectedProdutos.fold(0.0, (sum, p) => sum + p.totalValue);
  }

  double get maxPossibleValue {
    if (usandoEstatisticas) {
      return estatisticas!.valorTotal;
    }
    return activeProdutos.fold(0.0, (sum, p) => sum + p.totalValue);
  }

  double get selectionPercentage {
    if (activeProductsCount == 0) return 0.0;
    return (selectedProductsCount / activeProductsCount) * 100;
  }

  bool get isFullySelected {
    return activeProductsCount > 0 &&
        selectedProductsCount == activeProductsCount;
  }

  bool get hasSelectedProducts => selectedProductsCount > 0;

  bool get hasActiveProducts => activeProductsCount > 0;

  String get formattedTotalValue => CurrencyUtils.formatBRL(totalValue);

  @override
  List<Object?> get props => [id, nome, ordem, produtos, estatisticas];

  SubcategoryEntity updateProduct(ProductEntity updatedProduct) {
    final updatedProducts = produtos.map((p) {
      return p.id == updatedProduct.id ? updatedProduct : p;
    }).toList();

    return copyWith(produtos: updatedProducts);
  }

  @override
  String toString() {
    if (usandoEstatisticas) {
      return 'SubcategoryEntity(id: $id, nome: $nome, ordem: $ordem, usando estatísticas: total=${estatisticas!.totalProdutos}, selecionados=${estatisticas!.produtosSelecionados})';
    }
    return 'SubcategoryEntity(id: $id, nome: $nome, ordem: $ordem, produtos: ${produtos.length}, ativos: $activeProductsCount, selecionados: $selectedProductsCount)';
  }
}
