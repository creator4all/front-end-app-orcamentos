import 'package:equatable/equatable.dart';

import 'category_entity.dart';
import 'product_selection_entity.dart';

/// Entidade que representa os detalhes completos de um orçamento
/// Utilizada na tela de configuração para exibir e editar dados
class BudgetDetailEntity extends Equatable {
  /// ID do orçamento
  final int id;

  /// Nome/título do orçamento
  final String? name;

  /// Dias de validade
  final int validityDays;

  /// Data de validade
  final DateTime? validityDate;

  /// Data de criação
  final DateTime? creationDate;

  /// Status atual (rascunho, pendente, aprovado, etc)
  final String status;

  /// Valor total do orçamento
  final double total;

  /// ID do usuário que criou
  final int userId;

  /// ID do parceiro destino (se admin selecionou)
  final int? partnerId;

  /// Lista de IDs das cidades
  final List<int> cityIds;

  /// Lista de produtos selecionados (legado - manter para compatibilidade)
  final List<ProductSelectionEntity> products;

  /// Estado das categorias (livros, portal, etc) - manter para compatibilidade
  final Map<String, bool> categoryStates;

  /// ✅ Lista de categorias com subcategorias e produtos (nova estrutura)
  final List<CategoryEntity> categories;

  /// ✅ Dados completos das cidades com indicadores para Censo Escolar
  final List<Map<String, dynamic>> citiesData;

  const BudgetDetailEntity({
    required this.id,
    this.name,
    required this.validityDays,
    this.validityDate,
    this.creationDate,
    required this.status,
    required this.total,
    required this.userId,
    this.partnerId,
    required this.cityIds,
    required this.products,
    required this.categoryStates,
    required this.categories,
    required this.citiesData,
  });

  // ========== Regras de Negócio ==========

  /// Verifica se o orçamento pode ser finalizado
  bool get canBeFinalized => products.isNotEmpty && total > 0;

  /// Retorna a quantidade de produtos selecionados
  int get selectedProductsCount => products.where((p) => p.isSelected).length;

  /// Verifica se é um rascunho
  bool get isDraft => status.toLowerCase() == 'rascunho';

  /// Verifica se está pendente
  bool get isPending => status.toLowerCase() == 'pendente';

  /// Verifica se tem múltiplas cidades
  bool get isMultiCity => cityIds.length > 1;

  /// ✅ Quantidade total de produtos ativos em todas as categorias
  int get totalActiveProducts {
    return categories.fold(0, (sum, c) => sum + c.totalActiveProducts);
  }

  /// ✅ Quantidade total de produtos selecionados em todas as categorias
  int get totalSelectedProducts {
    return categories.fold(0, (sum, c) => sum + c.selectedProductsCount);
  }

  /// ✅ Valor total calculado a partir das categorias
  double get calculatedTotal {
    return categories.fold(0.0, (sum, c) => sum + c.totalValue);
  }

  /// Verifica se tem categorias disponíveis
  bool get hasCategories => categories.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        validityDays,
        validityDate,
        creationDate,
        status,
        total,
        userId,
        partnerId,
        cityIds,
        products,
        categoryStates,
        categories,
      ];

  /// Cria uma cópia com campos alterados
  BudgetDetailEntity copyWith({
    int? id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    DateTime? creationDate,
    String? status,
    double? total,
    int? userId,
    int? partnerId,
    List<int>? cityIds,
    List<ProductSelectionEntity>? products,
    Map<String, bool>? categoryStates,
    List<CategoryEntity>? categories,
    List<Map<String, dynamic>>? citiesData,
  }) {
    return BudgetDetailEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      validityDays: validityDays ?? this.validityDays,
      validityDate: validityDate ?? this.validityDate,
      creationDate: creationDate ?? this.creationDate,
      status: status ?? this.status,
      total: total ?? this.total,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      cityIds: cityIds ?? this.cityIds,
      products: products ?? this.products,
      categoryStates: categoryStates ?? this.categoryStates,
      categories: categories ?? this.categories,
      citiesData: citiesData ?? this.citiesData,
    );
  }
}
