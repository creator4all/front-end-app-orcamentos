import '../../../budget_config/data/models/census_data_dto.dart';
import '../../../budget_config/data/models/product_selection_dto.dart';
import '../../domain/entities/budget_edit_entity.dart';

/// DTO para edição de orçamento
class BudgetEditDto {
  final int id;
  final String? name;
  final int validityDays;
  final DateTime? validityDate;
  final DateTime? creationDate;
  final String status;
  final bool isArchived;
  final double total;
  final int userId;
  final int? partnerId;
  final List<int> cityIds;
  final List<ProductSelectionDto> products;
  final Map<String, dynamic> categoriesData;
  final CensusDataDto? censusData;

  BudgetEditDto({
    required this.id,
    this.name,
    required this.validityDays,
    this.validityDate,
    this.creationDate,
    required this.status,
    this.isArchived = false,
    required this.total,
    required this.userId,
    this.partnerId,
    required this.cityIds,
    required this.products,
    required this.categoriesData,
    this.censusData,
  });

  factory BudgetEditDto.fromJson(Map<String, dynamic> json) {
    // Parse produtos
    final List<ProductSelectionDto> productsList = [];

    // Estrutura organizada (categorias > subcategorias > produtos)
    if (json['categorias'] != null && json['categorias'] is List) {
      for (final categoria in json['categorias']) {
        final subcategorias = categoria['subcategorias'] as List? ?? [];
        for (final subcategoria in subcategorias) {
          final subId = subcategoria['id'] as int;
          final produtos = subcategoria['produtos'] as List? ?? [];
          for (final produto in produtos) {
            final produtoData = Map<String, dynamic>.from(produto);
            produtoData['subcategoria_id'] = subId;
            produtoData['categoria'] = categoria['nome'];
            productsList.add(ProductSelectionDto.fromJson(produtoData));
          }
        }
      }
    }

    // Parse cidades
    final List<int> cities = [];
    if (json['cidades'] != null && json['cidades'] is List) {
      cities.addAll((json['cidades'] as List).map((e) => e as int));
    } else if (json['orc_cidade_id'] != null) {
      cities.add(json['orc_cidade_id'] as int);
    }

    // Parse censo
    CensusDataDto? census;
    if (json['censo'] != null) {
      census = CensusDataDto.fromJson(json['censo']);
    }

    return BudgetEditDto(
      id: json['id'] ?? 0,
      name: json['nome'] ?? json['orc_nome'],
      validityDays: json['orc_dias_validade'] ?? json['dias_validade'] ?? 30,
      validityDate: json['orc_data_validade'] != null
          ? DateTime.tryParse(json['orc_data_validade'])
          : null,
      creationDate: json['orc_data_criacao'] != null
          ? DateTime.tryParse(json['orc_data_criacao'])
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null),
      status: json['orc_status'] ?? json['status'] ?? 'pendente',
      isArchived: (json['orc_status'] ?? json['status'] ?? '')
              .toString()
              .toLowerCase() ==
          'arquivado',
      total: (json['orc_total'] ?? json['total'] ?? 0.0).toDouble(),
      userId: json['orc_usuario_id'] ?? json['usuario_id'] ?? 0,
      partnerId: json['orc_partner_destino_id'] ?? json['partner_id'],
      cityIds: cities,
      products: productsList,
      categoriesData: json['categorias'] ?? {},
      censusData: census,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'nome': name,
      'orc_dias_validade': validityDays,
      if (validityDate != null)
        'orc_data_validade': validityDate!.toIso8601String(),
      'orc_status': status,
      'orc_total': total,
      'orc_usuario_id': userId,
      if (partnerId != null) 'orc_partner_destino_id': partnerId,
      'cidades': cityIds,
      'produtos_selecionados':
          products.where((p) => p.isSelected).map((p) => p.productId).toList(),
    };
  }

  BudgetEditEntity toEntity() {
    return BudgetEditEntity(
      id: id,
      name: name,
      validityDays: validityDays,
      validityDate: validityDate,
      creationDate: creationDate,
      status: status,
      isArchived: isArchived,
      total: total,
      userId: userId,
      partnerId: partnerId,
      cityIds: cityIds,
      products: products.map((p) => p.toEntity()).toList(),
      categoriesData: categoriesData,
      censusData: censusData?.toEntity(),
    );
  }
}
