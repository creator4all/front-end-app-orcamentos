import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_checkbox.dart';

import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';

class SubcategoriesModal extends StatelessWidget {
  final CategoryEntity category;
  final Function(SubcategoryEntity) onSubcategoryTap;
  final Function(int categoryId, int subcategoryId, bool selected)?
      onCheckboxChanged;
  final bool isReadOnly;

  const SubcategoriesModal({
    super.key,
    required this.category,
    required this.onSubcategoryTap,
    this.onCheckboxChanged,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: category.nome,
      content: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: category.orderedSubcategorias.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final subcategory = category.orderedSubcategorias[index];
          return _buildSubcategoryItem(context, subcategory);
        },
      ),
    );
  }

  Widget _buildSubcategoryItem(
      BuildContext context, SubcategoryEntity subcategory) {
    final hasSelectedProducts = subcategory.selectedProductsCount > 0;

    return InkWell(
      onTap: () => onSubcategoryTap(subcategory),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: hasSelectedProducts
                ? const Color(0xFF117BBD)
                : const Color(0xFFEAEAEA),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CustomCheckbox(
              value: hasSelectedProducts,
              onChanged: isReadOnly
                  ? null
                  : (value) {
                      onCheckboxChanged?.call(
                        category.id,
                        subcategory.id,
                        value,
                      );
                    },
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subcategory.nome,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subcategory.formattedTotalValue,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF484848),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${subcategory.selectedProductsCount}/${subcategory.activeProductsCount}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF484848),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: const Color(0xFF484848),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
