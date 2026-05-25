import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

import 'category_entity.dart';
import 'product_selection_entity.dart';

part 'budget_detail_entity.g.dart';

@CopyWith()
class BudgetDetailEntity extends Equatable {
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

  final List<ProductSelectionEntity> products;

  final Map<String, bool> categoryStates;

  final List<CategoryEntity> categories;

  final List<Map<String, dynamic>> citiesData;

  final Map<String, double> censoAgregado;

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
    this.censoAgregado = const {},
  });


  bool get canBeFinalized => products.isNotEmpty && total > 0;

  int get selectedProductsCount => products.where((p) => p.isSelected).length;

  bool get isDraft => status.toLowerCase() == 'rascunho';

  bool get isPending => status.toLowerCase() == 'pendente';

  bool get isMultiCity => cityIds.length > 1;

  int get totalActiveProducts {
    return categories.fold(0, (sum, c) => sum + c.totalActiveProducts);
  }

  int get totalSelectedProducts {
    return categories.fold(0, (sum, c) => sum + c.selectedProductsCount);
  }
  double get calculatedTotal {
    return categories.fold(0.0, (sum, c) => sum + c.totalValue);
  }

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
        citiesData,
        censoAgregado,
      ];
}
