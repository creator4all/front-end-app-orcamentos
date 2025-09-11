import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/widgets.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  String _selectedFilter = '';

  void _handleSearchChanged(String query) {
    // Aqui você pode implementar a lógica de filtragem
    debugPrint('Search query: $query');
  }

  void _handleFiltersChanged(List<String> filters) {
    // Aqui você pode implementar a lógica de filtragem
    debugPrint('Selected filters: $filters');

    // Atualiza o filtro selecionado para controlar o texto "Realizados/Arquivados"
    setState(() {
      _selectedFilter = filters.contains('archived') ? 'archived' : '';
    });
  }

  void _handleReset() {
    // Aqui você pode implementar a lógica de reset
    debugPrint('Filters reset');
    setState(() {
      _selectedFilter = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Orçamentos',
        showBackButton: false,
        userName: 'Pedro Penha',
        userEmail: 'pedro.penha.martins@gmail.com',
        userDocument: '03.848.869/0001-89',
      ),
      body: Column(
        children: [
          // Componente de filtros
          BudgetFilterWidget(
            onSearchChanged: _handleSearchChanged,
            onFiltersChanged: _handleFiltersChanged,
            onReset: _handleReset,
          ),

          // Seção Realizados/Arquivados
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _selectedFilter == 'archived' ? 'Arquivados' : 'Realizados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: const Color(0xFF484848),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Modular.to.pushNamed('/budget/new');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF117BBD),
                    foregroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  ),
                  icon: Icon(
                    Icons.add,
                    size: 16.sp,
                    color: const Color(0xFFFFFFFF),
                  ),
                  label: const Text('Novo Orç.'),
                ),
              ],
            ),
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
