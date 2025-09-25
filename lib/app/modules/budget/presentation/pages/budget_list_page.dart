import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/widgets.dart';
import '../stores/budget_list_store.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  late final BudgetListStore _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = Modular.get<BudgetListStore>();
    _store.fetch();
  }
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
      body: SafeArea(
        child: Column(
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

            Expanded(
              child: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_store.error != null) {
                    return Center(child: Text('Erro: ${_store.error}'));
                  }
                  if (_store.items.isEmpty) {
                    return const Center(child: Text('Nenhum orçamento encontrado'));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    itemCount: _store.items.length,
                    itemBuilder: (context, index) {
                      final b = _store.items[index];
                      return BudgetCardWidget(
                        title: b.nome ?? 'Orçamento',
                        budgetCode: 'D-${b.id}',
                        dueDate: b.dataValidade ?? DateTime.now(),
                        totalValue: b.total,
                        daysRemaining: 0,
                        status: BudgetStatus.pending,
                        userRole: UserRole.admin,
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
