import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import '../../../../../../shared/widgets/custom_checkbox.dart';
import '../../domain/entities/product_entity.dart';

class ProductItemCard extends StatelessWidget {
  final ProductEntity product;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onInfoTap;

  const ProductItemCard({
    super.key,
    required this.product,
    this.onToggle,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = product.selecionado;

    final borderColor =
        isSelected ? const Color(0xFF117BBD) : const Color(0xFFD9D9D9);

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
          CustomCheckbox(
            value: isSelected,
            onChanged: onToggle,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.solucao,
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
                      'Qtde: ${product.formattedQuantidade}',
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
              size: 28.sp,
              color: const Color(0xFF117BBD),
            ),
          ),
        ],
      ),
    );
  }
}
