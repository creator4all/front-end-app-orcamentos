import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'statistics_entity.dart';
import 'subcategory_entity.dart';

part 'category_entity.g.dart';

@CopyWith()
class CategoryEntity extends Equatable {
  final int id;

  final String nome;

  final int ordem;

  final bool expandido;

  final List<SubcategoryEntity> subcategorias;

  final StatisticsEntity? estatisticas;

  const CategoryEntity({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.expandido,
    required this.subcategorias,
    this.estatisticas,
  });


  List<SubcategoryEntity> get activeSubcategories {
    return subcategorias.where((s) => s.hasActiveProducts).toList();
  }
  int get activeSubcategoriesCount => activeSubcategories.length;

  int get totalActiveProducts {
    return subcategorias.fold(0, (sum, s) => sum + s.activeProductsCount);
  }
  int get selectedProductsCount {
    return subcategorias.fold(0, (sum, s) => sum + s.selectedProductsCount);
  }

  double get totalValue {
    return subcategorias.fold(0.0, (sum, s) => sum + s.totalValue);
  }
  double get maxPossibleValue {
    return subcategorias.fold(0.0, (sum, s) => sum + s.maxPossibleValue);
  }

  bool get isFullySelected {
    return totalActiveProducts > 0 &&
        selectedProductsCount == totalActiveProducts;
  }

  double get selectionPercentage {
    if (totalActiveProducts == 0) return 0.0;
    return (selectedProductsCount / totalActiveProducts) * 100;
  }

  bool get hasSelectedProducts => selectedProductsCount > 0;

  bool get hasSubcategories => subcategorias.isNotEmpty;

  bool get hasActiveSubcategories => activeSubcategoriesCount > 0;

  String get formattedTotalValue {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(totalValue);
  }

  bool get deveExibirExpandida => expandido;

  bool get deveExibirComoCard => !expandido;

  @override
  List<Object?> get props => [
        id,
        nome,
        ordem,
        expandido,
        subcategorias,
        estatisticas,
      ];

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
