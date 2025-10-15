import '../../domain/entities/budget_detail_entity.dart';
import 'product_selection_dto.dart';

/// DTO para detalhes de orçamento
/// Responsável pela conversão JSON <-> Entity
class BudgetDetailDto {
  final int id;
  final String? name;
  final int validityDays;
  final DateTime? validityDate;
  final DateTime? creationDate;
  final String status;
  final double total;
  final int userId;
  final int? partnerId;
  final List<int> cityIds;
  final List<ProductSelectionDto> products;
  final Map<String, bool> categoryStates;

  BudgetDetailDto({
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
  });

  /// Cria DTO a partir do JSON da API
  factory BudgetDetailDto.fromJson(Map<String, dynamic> json) {
    // Parse produtos
    final List<ProductSelectionDto> productsList = [];
    if (json['produtos'] != null && json['produtos'] is List) {
      productsList.addAll(
        (json['produtos'] as List).map(
          (p) => ProductSelectionDto.fromJson(Map<String, dynamic>.from(p)),
        ),
      );
    } else if (json['produtos_selecionados'] != null &&
        json['produtos_selecionados'] is List) {
      productsList.addAll(
        (json['produtos_selecionados'] as List).map(
          (p) => ProductSelectionDto.fromJson(Map<String, dynamic>.from(p)),
        ),
      );
    }

    // Parse estados de categorias
    final Map<String, bool> categories = {};
    if (json['categorias'] != null && json['categorias'] is Map) {
      (json['categorias'] as Map).forEach((key, value) {
        categories[key.toString()] = value == true || value == 1;
      });
    } else if (json['categorias_ativas'] != null &&
        json['categorias_ativas'] is List) {
      for (final cat in json['categorias_ativas']) {
        categories[cat.toString()] = true;
      }
    }

    // Parse cidades
    final List<int> cities = [];
    if (json['cidades'] != null && json['cidades'] is List) {
      cities.addAll((json['cidades'] as List).map((e) => e as int));
    } else if (json['orc_cidade_id'] != null) {
      cities.add(json['orc_cidade_id'] as int);
    }

    return BudgetDetailDto(
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
      status: json['orc_status'] ?? json['status'] ?? 'rascunho',
      total: (json['orc_total'] ?? json['total'] ?? 0.0).toDouble(),
      userId: json['orc_usuario_id'] ?? json['usuario_id'] ?? 0,
      partnerId: json['orc_partner_destino_id'] ?? json['partner_id'],
      cityIds: cities,
      products: productsList,
      categoryStates: categories,
    );
  }

  /// Converte DTO para JSON
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
      'produtos_selecionados': products.map((p) => p.toJson()).toList(),
      'categorias_ativas': categoryStates.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
    };
  }

  /// Converte DTO para Entity
  BudgetDetailEntity toEntity() {
    return BudgetDetailEntity(
      id: id,
      name: name,
      validityDays: validityDays,
      validityDate: validityDate,
      creationDate: creationDate,
      status: status,
      total: total,
      userId: userId,
      partnerId: partnerId,
      cityIds: cityIds,
      products: products.map((p) => p.toEntity()).toList(),
      categoryStates: categoryStates,
    );
  }

  /// Cria DTO a partir de Entity
  factory BudgetDetailDto.fromEntity(BudgetDetailEntity entity) {
    return BudgetDetailDto(
      id: entity.id,
      name: entity.name,
      validityDays: entity.validityDays,
      validityDate: entity.validityDate,
      creationDate: entity.creationDate,
      status: entity.status,
      total: entity.total,
      userId: entity.userId,
      partnerId: entity.partnerId,
      cityIds: entity.cityIds,
      products: entity.products
          .map((p) => ProductSelectionDto.fromEntity(p))
          .toList(),
      categoryStates: entity.categoryStates,
    );
  }
}
