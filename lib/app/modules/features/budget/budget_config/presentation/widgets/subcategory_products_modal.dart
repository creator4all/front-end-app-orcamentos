import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/presentation/widgets/product_item_card.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../stores/budget_config_store.dart';
import 'product_info_modal.dart';

class SubcategoryProductsModal extends StatelessWidget {
  final int categoryId;
  final int subcategoryId;
  final dynamic store;
  final bool isReadOnly;

  const SubcategoryProductsModal({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    this.store,
    this.isReadOnly = false,
  });

  static Future<void> show({
    required BuildContext context,
    required CategoryEntity category,
    required SubcategoryEntity subcategory,
    dynamic store,
    bool isReadOnly = false,
  }) {
    return CustomModal.show(
      context: context,
      title:
          '${capitalizeFirstLetter(category.nome)}: ${capitalizeFirstLetter(subcategory.nome)}',
      content: SubcategoryProductsModal(
        categoryId: category.id,
        subcategoryId: subcategory.id,
        store: store,
        isReadOnly: isReadOnly,
      ),
    );
  }

  void _handleInfoTap(
      BuildContext context,
      ProductEntity product,
      dynamic storeInstance,
      CategoryEntity category,
      SubcategoryEntity subcategory) {
    ProductInfoModal.show(
      context: context,
      categoryId: category.id,
      subcategoryId: subcategory.id,
      productId: product.id,
      store: storeInstance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeInstance = store ?? Modular.get<BudgetConfigStore>();

    return Observer(
      builder: (_) {
        final category = storeInstance.categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => throw Exception('Categoria não encontrada'),
        );

        final subcategory = category.subcategorias.firstWhere(
          (s) => s.id == subcategoryId,
          orElse: () => throw Exception('Subcategoria não encontrada'),
        );

        if (subcategory.produtos.isNotEmpty) {
          for (var i = 0; i < 3 && i < subcategory.produtos.length; i++) {
            final p = subcategory.produtos[i];
          }
        }

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
                          storeInstance.toggleProduct(product.id, isSelected);
                        },
                  onInfoTap: () => _handleInfoTap(
                      context, product, storeInstance, category, subcategory),
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
