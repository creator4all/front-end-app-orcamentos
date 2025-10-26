import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'statistics_entity.dart';
import 'subcategory_entity.dart';

/// Entidade que representa uma categoria de produtos no orçamento
class CategoryEntity extends Equatable {
  /// ID da categoria
  final int id;

  /// Nome para exibição (ex: "Livros", "Tecnologias")
  final String nome;

  /// Ordem de exibição (menor valor = maior prioridade)
  final int ordem;

  /// Lista de subcategorias
  final List<SubcategoryEntity> subcategorias;

  /// Estatísticas agregadas da categoria (soma de todas subcategorias)
  final StatisticsEntity? estatisticas;

  const CategoryEntity({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.subcategorias,
    this.estatisticas,
  });

  // ========== Getters Úteis ==========

  /// Lista todas as subcategorias que têm produtos ativos
  List<SubcategoryEntity> get activeSubcategories {
    return subcategorias.where((s) => s.hasActiveProducts).toList();
  }

  /// Quantidade total de subcategorias com produtos ativos
  int get activeSubcategoriesCount => activeSubcategories.length;

  /// Quantidade total de produtos ativos em todas as subcategorias
  int get totalActiveProducts {
    return subcategorias.fold(0, (sum, s) => sum + s.activeProductsCount);
  }

  /// Quantidade de produtos selecionados em todas as subcategorias
  int get selectedProductsCount {
    return subcategorias.fold(0, (sum, s) => sum + s.selectedProductsCount);
  }

  /// Valor total dos produtos selecionados
  double get totalValue {
    return subcategorias.fold(0.0, (sum, s) => sum + s.totalValue);
  }

  /// Valor total se todos os produtos fossem selecionados
  double get maxPossibleValue {
    return subcategorias.fold(0.0, (sum, s) => sum + s.maxPossibleValue);
  }

  /// Verifica se todos os produtos da categoria estão selecionados
  bool get isFullySelected {
    return totalActiveProducts > 0 &&
        selectedProductsCount == totalActiveProducts;
  }

  /// Calcula percentual de seleção
  double get selectionPercentage {
    if (totalActiveProducts == 0) return 0.0;
    return (selectedProductsCount / totalActiveProducts) * 100;
  }

  /// Verifica se tem algum produto selecionado
  bool get hasSelectedProducts => selectedProductsCount > 0;

  /// Verifica se tem subcategorias disponíveis
  bool get hasSubcategories => subcategorias.isNotEmpty;

  /// Verifica se tem subcategorias com produtos ativos
  bool get hasActiveSubcategories => activeSubcategoriesCount > 0;

  /// Formata o valor total para exibição (padrão brasileiro)
  String get formattedTotalValue {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(totalValue);
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        ordem,
        subcategorias,
        estatisticas,
      ];

  /// Cria uma cópia com campos alterados
  CategoryEntity copyWith({
    int? id,
    String? nome,
    int? ordem,
    List<SubcategoryEntity>? subcategorias,
    StatisticsEntity? estatisticas,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ordem: ordem ?? this.ordem,
      subcategorias: subcategorias ?? this.subcategorias,
      estatisticas: estatisticas ?? this.estatisticas,
    );
  }

  /// Atualiza uma subcategoria específica na lista
  CategoryEntity updateSubcategory(SubcategoryEntity updatedSubcategory) {
    final updatedSubcategorias = subcategorias.map((s) {
      return s.id == updatedSubcategory.id ? updatedSubcategory : s;
    }).toList();

    return copyWith(subcategorias: updatedSubcategorias);
  }

  @override
  String toString() {
    return 'CategoryEntity(id: $id, nome: $nome, ordem: $ordem, subcategorias: ${subcategorias.length}, produtos: $totalActiveProducts, selecionados: $selectedProductsCount)';
  }
}
