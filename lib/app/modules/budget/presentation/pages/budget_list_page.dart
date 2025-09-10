import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BudgetListPage extends StatelessWidget {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: const Center(
          child: Text(
            'Lista de Orçamentos\n(Em implementação)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
