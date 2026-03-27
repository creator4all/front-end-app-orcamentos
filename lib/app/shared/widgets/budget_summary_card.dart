import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyUtils.formatBRL(budgetValue),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF183127),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
          ),
          SizedBox(width: 8.w),
          Container(
            height: 37.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
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
