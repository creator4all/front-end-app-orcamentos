import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/budget_summary_card.dart';
import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/product_category.dart';
import '../../../../shared/widgets/school_census.dart';

class ConfigNewBudgetPage extends StatefulWidget {
  const ConfigNewBudgetPage({super.key});

  @override
  State<ConfigNewBudgetPage> createState() => _ConfigNewBudgetPageState();
}

class _ConfigNewBudgetPageState extends State<ConfigNewBudgetPage> {
  bool isLivrosSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Novo orçamento',
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            const BudgetSummaryCard(
              budgetValue: 0.0,
              selectedProductsCount: 0,
            ),
            const SizedBox(height: 12),
            const SchoolCensus(
              leadingIcon: Icon(Icons.school, color: Colors.black54),
              title: 'Censo Escolar',
              info1: '7 turmas',
              info2: '2000 alunos',
            ),
            const SizedBox(height: 12),
            ProductCategory(
              categoryIcon: const Icon(Icons.menu_book, color: Colors.black54),
              title: 'Livros',
              value: 'R\$500.000,00',
              selectedCount: 47,
              totalCount: 48,
              isSelected: isLivrosSelected,
              onCheckboxChanged: (bool? value) {
                setState(() {
                  isLivrosSelected = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
