import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/utils/string_utils.dart';
import '../../../../../shared/widgets/custom_modal.dart';
import '../../../budget/budget_config/domain/entities/category_entity.dart';
import '../../../budget/budget_config/domain/entities/product_entity.dart';
import '../../../budget/budget_config/domain/entities/subcategory_entity.dart';
import 'report_product_info_modal.dart';
import 'report_product_item_card.dart';

class ReportProductsModal extends StatelessWidget {
  final CategoryEntity category;
  final SubcategoryEntity subcategory;

  const ReportProductsModal({
    super.key,
    required this.category,
    required this.subcategory,
  });

  static Future<void> show({
    required BuildContext context,
    required CategoryEntity category,
    required SubcategoryEntity subcategory,
  }) {
    return CustomModal.show(
      context: context,
      title:
          '${capitalizeFirstLetter(category.nome)}: ${capitalizeFirstLetter(subcategory.nome)}',
      content: ReportProductsModal(
        category: category,
        subcategory: subcategory,
      ),
    );
  }

  void _handleInfoTap(BuildContext context, ProductEntity product) {
    ReportProductInfoModal.show(
      context: context,
      category: category,
      subcategory: subcategory,
      product: product,
    );
  }

  @override
  Widget build(BuildContext context) {
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

            return ReportProductItemCard(
              product: product,
              onInfoTap: () => _handleInfoTap(context, product),
            );
          },
        ),

        SizedBox(height: 24.h),

        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E3562),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Fechar',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),

        SizedBox(height: 16.h),
      ],
    );
  }
}
