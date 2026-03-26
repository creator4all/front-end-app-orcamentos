import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/modules/features/reports/presentation/widgets/readonly_checkbox.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import '../../../../../shared/utils/string_utils.dart';
import '../../../budget/budget_config/domain/entities/product_entity.dart';

class ReportProductItemCard extends StatelessWidget {
  final ProductEntity product;

  final VoidCallback? onInfoTap;

  const ReportProductItemCard({
    super.key,
    required this.product,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = product.selecionado;
    final borderColor =
        isSelected ? const Color(0xFF2830F2) : const Color(0xFFD9D9D9);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReadonlyCheckbox(
            value: isSelected,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  capitalizeFirstLetter(product.solucao),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF484848),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qtde: ${product.quantidade.toInt()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatBRL(product.valor),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatBRL(product.totalValue),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onInfoTap,
            child: Icon(
              Icons.info_outline,
              size: 22.sp,
              color: const Color(0xFF2830F2),
            ),
          ),
        ],
      ),
    );
  }
}
