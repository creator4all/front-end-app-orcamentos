import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

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
  final List<Map<String, dynamic>>
      citiesDataRaw;
  final List<ProductSelectionEntity> products;
  final dynamic categoriesData;
  final CensusDataEntity? censusData;

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


  bool get canBeEdited => status.toLowerCase() != 'aprovado';

  bool get isExpired {
    if (validityDate == null) return false;
    return validityDate!.isBefore(DateTime.now());
  }

  int get selectedProductsCount => products.where((p) => p.isSelected).length;

  double get calculatedTotal => products
      .where((p) => p.isSelected)
      .fold(0.0, (sum, p) => sum + p.totalPrice);

  bool get isArchived => status.toLowerCase() == 'arquivado';

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
}
