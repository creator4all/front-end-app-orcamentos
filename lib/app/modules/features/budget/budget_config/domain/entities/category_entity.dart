import 'package:equatable/equatable.dart';

/// Entidade que representa uma categoria de produtos no orçamento
class CategoryEntity extends Equatable {
  /// ID da categoria
  final int id;

  /// Chave/identificador único (livros, portal, gamificacao, etc)
  final String key;

  /// Nome para exibição
  final String name;

  /// Ícone material (nome do ícone)
  final String icon;

  /// Valor total da categoria
  final double totalValue;

  /// Quantidade de produtos selecionados
  final int selectedCount;

  /// Quantidade total de produtos
  final int totalCount;

  /// Se a categoria está selecionada
  final bool isSelected;

  const CategoryEntity({
    required this.id,
    required this.key,
    required this.name,
    required this.icon,
    required this.totalValue,
    required this.selectedCount,
    required this.totalCount,
    required this.isSelected,
  });

  // ========== Regras de Negócio ==========

  /// Verifica se todos os produtos da categoria estão selecionados
  bool get isComplete => selectedCount == totalCount;

  /// Calcula percentual de completude
  double get percentComplete =>
      totalCount > 0 ? (selectedCount / totalCount * 100) : 0.0;

  /// Verifica se tem algum produto selecionado
  bool get hasSelectedProducts => selectedCount > 0;

  @override
  List<Object?> get props => [
        id,
        key,
        name,
        icon,
        totalValue,
        selectedCount,
        totalCount,
        isSelected,
      ];

  /// Cria uma cópia com campos alterados
  CategoryEntity copyWith({
    int? id,
    String? key,
    String? name,
    String? icon,
    double? totalValue,
    int? selectedCount,
    int? totalCount,
    bool? isSelected,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      totalValue: totalValue ?? this.totalValue,
      selectedCount: selectedCount ?? this.selectedCount,
      totalCount: totalCount ?? this.totalCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
