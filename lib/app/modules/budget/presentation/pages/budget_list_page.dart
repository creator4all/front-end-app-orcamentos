import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/widgets.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  void _handleSearchChanged(String query) {
    // Aqui você pode implementar a lógica de filtragem
    debugPrint('Search query: $query');
  }

  void _handleFiltersChanged(List<String> filters) {
    // Aqui você pode implementar a lógica de filtragem
    debugPrint('Selected filters: $filters');
  }

  void _handleReset() {
    // Aqui você pode implementar a lógica de reset
    debugPrint('Filters reset');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
      ),
      body: Column(
        children: [
          // Componente de filtros
          BudgetFilterWidget(
            onSearchChanged: _handleSearchChanged,
            onFiltersChanged: _handleFiltersChanged,
            onReset: _handleReset,
          ),

          // Lista de orçamentos
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              children: [
                // Exemplo para Administrador
                BudgetCardWidget(
                  title: 'Barra Velha - SC',
                  partner: 'XPTO',
                  seller: 'Pedro Penha',
                  budgetCode: 'D-4202107-119',
                  dueDate: DateTime(2024, 3, 15),
                  totalValue: 45282630.80,
                  daysRemaining: 10,
                  status: BudgetStatus.pending,
                  userRole: UserRole.admin,
                  onTap: () {
                    // Navegar para detalhes do orçamento
                  },
                ),

                // Exemplo para Gestor
                BudgetCardWidget(
                  title: 'Projeto Centro Comercial',
                  seller: 'Ana Silva',
                  budgetCode: 'D-4202107-120',
                  dueDate: DateTime(2024, 4, 20),
                  totalValue: 125000.50,
                  daysRemaining: 5,
                  status: BudgetStatus.approved,
                  userRole: UserRole.manager,
                  onTap: () {
                    // Navegar para detalhes do orçamento
                  },
                ),

                // Exemplo para Vendedor
                BudgetCardWidget(
                  title: 'Residencial Premium',
                  budgetCode: 'D-4202107-121',
                  dueDate: DateTime(2024, 2, 10),
                  totalValue: 85000.00,
                  daysRemaining: -5,
                  status: BudgetStatus.expired,
                  userRole: UserRole.seller,
                  onTap: () {
                    // Navegar para detalhes do orçamento
                  },
                ),

                // Exemplo com orçamento arquivado
                BudgetCardWidget(
                  title: 'Shopping Center Norte',
                  partner: 'ABC Construtora',
                  seller: 'Carlos Santos',
                  budgetCode: 'D-4202107-122',
                  dueDate: DateTime(2024, 1, 15),
                  totalValue: 250000.75,
                  daysRemaining: 0,
                  status: BudgetStatus.notApproved,
                  isArchived: true,
                  userRole: UserRole.admin,
                  onTap: () {
                    // Navegar para detalhes do orçamento
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
