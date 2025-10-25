import 'package:equatable/equatable.dart';

import 'product_entity.dart';
import 'statistics_entity.dart';

/// Entidade que representa uma subcategoria de produtos
class SubcategoryEntity extends Equatable {
  /// ID único da subcategoria
  final int id;

  /// Nome da subcategoria (ex: "Como se escreve", "Educação Musical")
  final String nome;

  /// Ordem de exibição (menor valor = maior prioridade)
  final int ordem;

  /// Lista de produtos da subcategoria (pode estar vazia se usar estatísticas)
  final List<ProductEntity> produtos;

  /// Estatísticas agregadas (usado quando produtos não estão carregados)
  final StatisticsEntity? estatisticas;

  const SubcategoryEntity({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.produtos,
    this.estatisticas,
  });

  // ========== Getters Úteis ==========

  /// Verifica se está usando estatísticas (produtos não carregados ainda)
  bool get usandoEstatisticas => produtos.isEmpty && estatisticas != null;

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
  /// Usa estatísticas se produtos não carregados
  int get activeProductsCount {
    if (usandoEstatisticas) {
      return estatisticas!.totalProdutos;
    }
    return activeProdutos.length;
  }

  /// Quantidade de produtos selecionados
  /// Usa estatísticas se produtos não carregados
  int get selectedProductsCount {
    if (usandoEstatisticas) {
      return estatisticas!.produtosSelecionados;
    }
    return selectedProdutos.length;
  }

  /// Valor total dos produtos selecionados
  /// Usa estatísticas se produtos não carregados
  double get totalValue {
    if (usandoEstatisticas) {
      return estatisticas!.valorSelecionado;
    }
    return selectedProdutos.fold(0.0, (sum, p) => sum + p.totalValue);
  }

  /// Valor total se todos os produtos fossem selecionados
  /// Usa estatísticas se produtos não carregados
  double get maxPossibleValue {
    if (usandoEstatisticas) {
      return estatisticas!.valorTotal;
    }
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
  List<Object?> get props => [id, nome, ordem, produtos, estatisticas];

  /// Cria uma cópia com campos alterados
  SubcategoryEntity copyWith({
    int? id,
    String? nome,
    int? ordem,
    List<ProductEntity>? produtos,
    StatisticsEntity? estatisticas,
  }) {
    return SubcategoryEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ordem: ordem ?? this.ordem,
      produtos: produtos ?? this.produtos,
      estatisticas: estatisticas ?? this.estatisticas,
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
    if (usandoEstatisticas) {
      return 'SubcategoryEntity(id: $id, nome: $nome, ordem: $ordem, usando estatísticas: total=${estatisticas!.totalProdutos}, selecionados=${estatisticas!.produtosSelecionados})';
    }
    return 'SubcategoryEntity(id: $id, nome: $nome, ordem: $ordem, produtos: ${produtos.length}, ativos: $activeProductsCount, selecionados: $selectedProductsCount)';
  }
}
