import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double budgetValue;
  final int selectedProductsCount;

  const BudgetSummaryCard({
    super.key,
    required this.budgetValue,
    required this.selectedProductsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFB8DCCE),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lado esquerdo - Valor e subtítulo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Valor do orçamento
              Text(
                'R\$ ${budgetValue.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF183127),
                ),
              ),
              // SizedBox(height: 2.h),
              // Subtítulo
              Text(
                'Custo total',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF183127),
                ),
              ),
            ],
          ),

          // Lado direito - Container com carrinho e contador
          Container(
            width: 48.w,
            height: 37.h,
            decoration: BoxDecoration(
              color: const Color(0xFF5B9A82),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFFFFFFFF),
                  size: 24,
                ),
                SizedBox(width: 4.w),
                Text(
                  selectedProductsCount.toString(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
