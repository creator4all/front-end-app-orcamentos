import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../widgets/school_census_card.dart';

class BudgetSkeleton extends StatelessWidget {
  const BudgetSkeleton({super.key});

  static const _fakeBudgetValue = 12500.00;
  static const _fakeProductCount = 8;
  static const _fakeCityCount = 2;

  static final _fakeCitiesData = <Map<String, dynamic>>[
    {
      'id': 1,
      'nome': 'Cidade Exemplo',
      'cidades_has_indice_etapa': [
        {
          'nome_etapa': 'EF1',
          'pivot': {'etapa_valor': 500}
        },
        {
          'nome_etapa': 'EF2',
          'pivot': {'etapa_valor': 750}
        },
      ],
    },
  ];

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
            const BudgetSummaryCard(
              budgetValue: _fakeBudgetValue,
              selectedProductsCount: _fakeProductCount,
            ),

            SizedBox(height: 12.h),

            SchoolCensusCard(
              numberOfCities: _fakeCityCount,
              citiesData: _fakeCitiesData,
            ),

            SizedBox(height: 24.h),

            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: const ProductCategory(
                  categoryIcon: Icon(
                    Icons.category,
                    color: Colors.black54,
                  ),
                  title: 'Categoria Exemplo',
                  value: 'R\$ 2.500,00',
                  selectedCount: 3,
                  totalCount: 10,
                  isSelected: false,
                ),
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
                  backgroundColor: const Color(0xFF117BBD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Salvar Orçamento',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
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
}
