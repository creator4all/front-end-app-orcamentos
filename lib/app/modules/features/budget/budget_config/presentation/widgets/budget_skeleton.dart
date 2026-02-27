import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BudgetSkeleton extends StatelessWidget {
  const BudgetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFE0E0E0),
        highlightColor: Color(0xFFF5F5F5),
        duration: Duration(milliseconds: 1000),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCardPlaceholder(),
            SizedBox(height: 12.h),
            _buildCensusPlaceholder(),
            SizedBox(height: 24.h),
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildCategoryPlaceholder(),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data do orçamento',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: '01/01/2026',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Validade do orç. *',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: '60',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBDBDBD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Salvar Orçamento',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardPlaceholder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'R\$ 12.500,00',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              Text(
                'Custo total',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
          Container(
            width: 48.w,
            height: 37.h,
            decoration: BoxDecoration(
              color: const Color(0xFFBDBDBD),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF9E9E9E),
                  size: 24,
                ),
                SizedBox(width: 4.w),
                Text(
                  '8',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPlaceholder() {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w, bottom: 12.h),
      constraints: BoxConstraints(maxHeight: 85.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.category,
            color: Colors.grey,
            size: 24,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categoria Exemplo',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'R\$ 2.500,00',
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '3/10',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCensusPlaceholder() {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w, bottom: 12.h),
      constraints: BoxConstraints(maxHeight: 85.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.people,
            color: Colors.grey,
            size: 24,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Censo Escolar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '2 Turmas',
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  '1.250 Estudantes',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
