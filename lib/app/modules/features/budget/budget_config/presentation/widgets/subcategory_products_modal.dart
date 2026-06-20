import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/presentation/widgets/product_item_card.dart';

import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import 'product_info_modal.dart';

typedef CategoryResolver = CategoryEntity Function(int categoryId);
typedef SubcategoryResolver = SubcategoryEntity Function(
  int categoryId,
  int subcategoryId,
);
typedef ProductSelectionChanged = void Function(int productId, bool selected);
typedef ProductValueChanged = void Function(int productId, double value);
typedef ProductQuantityChanged = void Function(int productId, double quantity);
typedef ProductQuantityModeChanged = void Function(int productId, bool manual);
typedef ProductIndicatorToggled = void Function(int productId, int indicatorId);

class SubcategoryProductsModal extends StatelessWidget {
  final int categoryId;
  final int subcategoryId;
  final CategoryResolver resolveCategory;
  final SubcategoryResolver resolveSubcategory;
  final ProductSelectionChanged? onToggleProduct;
  final ProductValueChanged? onUpdateProductValue;
  final ProductQuantityChanged? onUpdateProductQuantity;
  final ProductQuantityChanged? onUpdateProductManualQuantity;
  final ProductQuantityModeChanged? onUpdateProductQuantityMode;
  final ProductIndicatorToggled? onToggleProductIndicator;
  final bool isReadOnly;

  const SubcategoryProductsModal({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    required this.resolveCategory,
    required this.resolveSubcategory,
    this.onToggleProduct,
    this.onUpdateProductValue,
    this.onUpdateProductQuantity,
    this.onUpdateProductManualQuantity,
    this.onUpdateProductQuantityMode,
    this.onToggleProductIndicator,
    this.isReadOnly = false,
  });

  static Future<void> show({
    required BuildContext context,
    required CategoryEntity category,
    required SubcategoryEntity subcategory,
    required CategoryResolver resolveCategory,
    required SubcategoryResolver resolveSubcategory,
    ProductSelectionChanged? onToggleProduct,
    ProductValueChanged? onUpdateProductValue,
    ProductQuantityChanged? onUpdateProductQuantity,
    ProductQuantityChanged? onUpdateProductManualQuantity,
    ProductQuantityModeChanged? onUpdateProductQuantityMode,
    ProductIndicatorToggled? onToggleProductIndicator,
    bool isReadOnly = false,
  }) {
    return CustomModal.show(
      context: context,
      title: '${category.nome}: ${subcategory.nome}',
      content: SubcategoryProductsModal(
        categoryId: category.id,
        subcategoryId: subcategory.id,
        resolveCategory: resolveCategory,
        resolveSubcategory: resolveSubcategory,
        onToggleProduct: onToggleProduct,
        onUpdateProductValue: onUpdateProductValue,
        onUpdateProductQuantity: onUpdateProductQuantity,
        onUpdateProductManualQuantity: onUpdateProductManualQuantity,
        onUpdateProductQuantityMode: onUpdateProductQuantityMode,
        onToggleProductIndicator: onToggleProductIndicator,
        isReadOnly: isReadOnly,
      ),
    );
  }

  void _handleInfoTap(BuildContext context, ProductEntity product) {
    ProductInfoModal.show(
      context: context,
      getProduct: () {
        final currentSubcategory =
            resolveSubcategory(categoryId, subcategoryId);
        return currentSubcategory.produtos.firstWhere(
          (item) => item.id == product.id,
          orElse: () => product,
        );
      },
      getCategoryName: () => resolveCategory(categoryId).nome,
      getSubcategoryName: () =>
          resolveSubcategory(categoryId, subcategoryId).nome,
      onValueChanged: isReadOnly
          ? null
          : (value) => onUpdateProductValue?.call(product.id, value),
      onQuantityChanged: isReadOnly
          ? null
          : (quantity) => onUpdateProductQuantity?.call(product.id, quantity),
      onManualQuantityChanged: isReadOnly
          ? null
          : (quantity) =>
              onUpdateProductManualQuantity?.call(product.id, quantity),
      onQuantityModeChanged: isReadOnly
          ? null
          : (manual) => onUpdateProductQuantityMode?.call(product.id, manual),
      onIndicatorToggled: isReadOnly
          ? null
          : (indicatorId) =>
              onToggleProductIndicator?.call(product.id, indicatorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final subcategory = resolveSubcategory(categoryId, subcategoryId);
        final activeProducts = subcategory.activeProdutos;

        if (activeProducts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Text(
                'Nenhum produto disponível',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeProducts.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final product = activeProducts[index];

                return ProductItemCard(
                  product: product,
                  onToggle: isReadOnly
                      ? null
                      : (isSelected) {
                          onToggleProduct?.call(product.id, isSelected);
                        },
                  onInfoTap: () => _handleInfoTap(context, product),
                );
              },
            ),
            SizedBox(height: 24.h),
            if (!isReadOnly)
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Color(0xFFFFFFFF),
                  ),
                  label: Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF56B34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}
