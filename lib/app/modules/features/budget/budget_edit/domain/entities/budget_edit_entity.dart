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
  final bool isArchived;
  final double total;
  final int userId;
  final int? partnerId;
  final List<int> cityIds;
  final List<ProductSelectionEntity> products;
  final Map<String, dynamic> categoriesData;
  final CensusDataEntity? censusData;

  const BudgetEditEntity({
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

  @override
  List<Object?> get props => [
        id,
        name,
        validityDays,
        validityDate,
        creationDate,
        status,
        isArchived,
        total,
        userId,
        partnerId,
        cityIds,
        products,
        categoriesData,
        censusData,
      ];

  BudgetEditEntity copyWith({
    int? id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    DateTime? creationDate,
    String? status,
    bool? isArchived,
    double? total,
    int? userId,
    int? partnerId,
    List<int>? cityIds,
    List<ProductSelectionEntity>? products,
    Map<String, dynamic>? categoriesData,
    CensusDataEntity? censusData,
  }) {
    return BudgetEditEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      validityDays: validityDays ?? this.validityDays,
      validityDate: validityDate ?? this.validityDate,
      creationDate: creationDate ?? this.creationDate,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      total: total ?? this.total,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      cityIds: cityIds ?? this.cityIds,
      products: products ?? this.products,
      categoriesData: categoriesData ?? this.categoriesData,
      censusData: censusData ?? this.censusData,
    );
  }
}
