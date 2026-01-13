import 'package:equatable/equatable.dart';

import '../../../budget_config/domain/entities/census_data_entity.dart';
import '../../../budget_config/domain/entities/product_selection_entity.dart';

/// Entidade para edição completa de um orçamento
class BudgetEditEntity extends Equatable {
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
  final List<Map<String, dynamic>>
      citiesDataRaw; // Dados completos das cidades com indicadores
  final List<ProductSelectionEntity> products;
  final dynamic categoriesData; // Pode ser List ou Map dependendo da API
  final CensusDataEntity? censusData;

  /// Dados agregados do censo escolar para orçamentos multi-cidade
  /// Mapa de nome_etapa -> valor (ex: {"bercario": 2935, "maternal": 1120})
  final Map<String, double> censoAgregado;

  const BudgetEditEntity({
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
    this.citiesDataRaw = const [],
    required this.products,
    required this.categoriesData,
    this.censusData,
    this.censoAgregado = const {},
  });

  // ========== Regras de Negócio ==========

  bool get canBeEdited => status.toLowerCase() != 'aprovado';

  bool get isExpired {
    if (validityDate == null) return false;
    return validityDate!.isBefore(DateTime.now());
  }

  int get selectedProductsCount => products.where((p) => p.isSelected).length;

  double get calculatedTotal => products
      .where((p) => p.isSelected)
      .fold(0.0, (sum, p) => sum + p.totalPrice);

  /// Computed property para compatibilidade com código existente
  bool get isArchived => status.toLowerCase() == 'arquivado';

  /// Verifica se é um orçamento multi-cidade (mais de 1 cidade)
  bool get isMultiCity => cityIds.length > 1;

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
        citiesDataRaw,
        products,
        categoriesData,
        censusData,
        censoAgregado,
      ];

  BudgetEditEntity copyWith({
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
    List<Map<String, dynamic>>? citiesDataRaw,
    List<ProductSelectionEntity>? products,
    dynamic categoriesData,
    CensusDataEntity? censusData,
    Map<String, double>? censoAgregado,
  }) {
    return BudgetEditEntity(
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
      citiesDataRaw: citiesDataRaw ?? this.citiesDataRaw,
      products: products ?? this.products,
      categoriesData: categoriesData ?? this.categoriesData,
      censusData: censusData ?? this.censusData,
      censoAgregado: censoAgregado ?? this.censoAgregado,
    );
  }
}
