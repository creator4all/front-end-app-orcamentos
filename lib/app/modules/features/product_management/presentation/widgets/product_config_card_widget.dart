import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product_config_entity.dart';

class ProductConfigCardWidget extends StatelessWidget {
  final ProductConfigEntity product;
  final VoidCallback? onInfoTap;
  final ValueChanged<bool>? onStatusChanged;

  const ProductConfigCardWidget({
    super.key,
    required this.product,
    this.onInfoTap,
    this.onStatusChanged,
  });

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.codigo,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF484848),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _capitalize(product.solucao),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF484848),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  _formatCurrency(product.valor),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => onStatusChanged?.call(!product.status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50.w,
              height: 28.h,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.h),
                color: product.status
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : Colors.transparent,
                border: Border.all(
                  color: product.status
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF666666),
                  width: 2,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: product.status
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: product.status
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onInfoTap,
            child: Icon(
              Icons.info_outline,
              size: 24.sp,
              color: const Color(0xFF0028C1),
            ),
          ),
        ],
      ),
    );
  }
}
