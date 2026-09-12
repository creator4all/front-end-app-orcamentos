import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

import '../../../budget_config/domain/entities/budget_detail_entity.dart';
import '../../../budget_config/domain/entities/census_data_entity.dart';
import '../../../budget_config/domain/entities/product_selection_entity.dart';

part 'budget_edit_entity.g.dart';

@CopyWith()
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
  final List<Map<String, dynamic>> citiesDataRaw;
  final List<ProductSelectionEntity> products;
  final dynamic categoriesData;
  final CensusDataEntity? censusData;
  final bool isArchived;

  /// Classificação de multi-cidade declarada pelo backend (`multi_cidade`).
  ///
  /// Decide o endpoint de versionamento. Quando a chave não vem no payload,
  /// [isMultiCity] volta a derivar pela quantidade de cidades.
  final bool? multiCity;

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
    this.isArchived = false,
    this.multiCity,
    this.censoAgregado = const {},
  });

  factory BudgetEditEntity.fromBudgetDetail(BudgetDetailEntity budget) {
    return BudgetEditEntity(
      id: budget.id,
      name: budget.name,
      validityDays: budget.validityDays,
      validityDate: budget.validityDate,
      creationDate: budget.creationDate,
      status: budget.status,
      total: budget.total,
      userId: budget.userId,
      partnerId: budget.partnerId,
      cityIds: List<int>.from(budget.cityIds),
      citiesDataRaw: budget.citiesData
          .map((city) => Map<String, dynamic>.from(city))
          .toList(),
      products: List<ProductSelectionEntity>.from(budget.products),
      categoriesData: List.unmodifiable(budget.categories),
      isArchived: budget.isArchived,
      multiCity: budget.multiCity,
      censoAgregado: Map<String, double>.from(budget.censoAgregado),
    );
  }

  bool get isExpired {
    if (validityDate == null) return false;
    return validityDate!.isBefore(DateTime.now());
  }

  int get selectedProductsCount => products.where((p) => p.isSelected).length;

  double get calculatedTotal => products
      .where((p) => p.isSelected)
      .fold(0.0, (sum, p) => sum + p.totalPrice);

  bool get isMultiCity => multiCity ?? cityIds.length > 1;

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
        isArchived,
        multiCity,
        censoAgregado,
      ];
}
