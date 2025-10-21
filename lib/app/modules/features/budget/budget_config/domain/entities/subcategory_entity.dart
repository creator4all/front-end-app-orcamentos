import 'package:equatable/equatable.dart';

import 'product_entity.dart';

/// Entidade que representa uma subcategoria de produtos
class SubcategoryEntity extends Equatable {
  /// ID único da subcategoria
  final int id;

  /// Nome da subcategoria (ex: "Como se escreve", "Educação Musical")
  final String nome;

  /// Lista de produtos da subcategoria
  final List<ProductEntity> produtos;

  const SubcategoryEntity({
    required this.id,
    required this.nome,
    required this.produtos,
  });

  // ========== Getters Úteis ==========

  /// ⚠️ Lista apenas produtos ATIVOS (que podem ser exibidos)
  List<ProductEntity> get activeProdutos {
    return produtos.where((p) => p.ativo).toList();
  }

  /// ✅ Lista apenas produtos SELECIONADOS (e ativos)
  List<ProductEntity> get selectedProdutos {
    return produtos.where((p) => p.ativo && p.selecionado).toList();
  }

  /// Lista produtos não selecionados (mas ativos)
  List<ProductEntity> get unselectedProdutos {
    return produtos.where((p) => p.ativo && !p.selecionado).toList();
  }

  /// Quantidade total de produtos ativos
  int get activeProductsCount => activeProdutos.length;

  /// Quantidade de produtos selecionados
  int get selectedProductsCount => selectedProdutos.length;

  /// Valor total dos produtos selecionados
  double get totalValue {
    return selectedProdutos.fold(0.0, (sum, p) => sum + p.totalValue);
  }

  /// Valor total se todos os produtos fossem selecionados
  double get maxPossibleValue {
    return activeProdutos.fold(0.0, (sum, p) => sum + p.totalValue);
  }

  /// Percentual de produtos selecionados
  double get selectionPercentage {
    if (activeProductsCount == 0) return 0.0;
    return (selectedProductsCount / activeProductsCount) * 100;
  }

  /// Verifica se todos os produtos ativos estão selecionados
  bool get isFullySelected {
    return activeProductsCount > 0 &&
        selectedProductsCount == activeProductsCount;
  }

  /// Verifica se algum produto está selecionado
  bool get hasSelectedProducts => selectedProductsCount > 0;

  /// Verifica se tem produtos disponíveis para exibir
  bool get hasActiveProducts => activeProductsCount > 0;

  /// Formata o valor total para exibição
  String get formattedTotalValue => 'R\$ ${totalValue.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [id, nome, produtos];

  /// Cria uma cópia com campos alterados
  SubcategoryEntity copyWith({
    int? id,
    String? nome,
    List<ProductEntity>? produtos,
  }) {
    return SubcategoryEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      produtos: produtos ?? this.produtos,
    );
  }

  /// Atualiza um produto específico na lista
  SubcategoryEntity updateProduct(ProductEntity updatedProduct) {
    final updatedProducts = produtos.map((p) {
      return p.id == updatedProduct.id ? updatedProduct : p;
    }).toList();

    return copyWith(produtos: updatedProducts);
  }

  @override
  String toString() {
    return 'SubcategoryEntity(id: $id, nome: $nome, produtos: ${produtos.length}, ativos: $activeProductsCount, selecionados: $selectedProductsCount)';
  }
}
