import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';

class SubcategoriesModal extends StatelessWidget {
  final CategoryEntity category;
  final Function(SubcategoryEntity) onSubcategoryTap;
  final Function(int categoryId, int subcategoryId, bool selected)?
      onCheckboxChanged;

  const SubcategoriesModal({
    super.key,
    required this.category,
    required this.onSubcategoryTap,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: capitalizeFirstLetter(category.nome),
      content: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: category.subcategorias.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final subcategory = category.subcategorias[index];
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
                ? const Color(0xFF2830F2)
                : const Color(0xFFEAEAEA),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                onCheckboxChanged?.call(
                  category.id,
                  subcategory.id,
                  !hasSelectedProducts,
                );
              },
              child: Container(
                width: 17.w,
                height: 17.h,
                decoration: BoxDecoration(
                  color: hasSelectedProducts
                      ? const Color(0xFF2830F2)
                      : Colors.white,
                  border: Border.all(
                    color: hasSelectedProducts
                        ? const Color(0xFF2830F2)
                        : const Color(0xFFEAEAEA),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: hasSelectedProducts
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    capitalizeFirstLetter(subcategory.nome),
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
