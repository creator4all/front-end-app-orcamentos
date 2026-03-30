import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../stores/report_budget_list_store.dart';
import '../stores/report_filter_store.dart';
import '../widgets/report_budget_card_widget.dart';
import '../widgets/report_filter_widget.dart';

class ReportBudgetListPage extends StatefulWidget {
  final int userId;
  final String? userName;
  final String? userCargo;
  final String? partnerName;

  const ReportBudgetListPage({
    super.key,
    required this.userId,
    this.userName,
    this.userCargo,
    this.partnerName,
  });

  @override
  State<ReportBudgetListPage> createState() => _ReportBudgetListPageState();
}

class _ReportBudgetListPageState extends State<ReportBudgetListPage> {
  late final ReportBudgetListStore _store;
  late final ReportFilterStore _filterStore;

  List<String> _selectedFilters = ['pendente'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ReportBudgetListStore>();
    _filterStore = Modular.get<ReportFilterStore>();

    _filterStore.clearBudgetSearch();

    if (_filterStore.selectedStatuses.isEmpty) {
      _filterStore.toggleStatus('pendente');
      _selectedFilters = ['pendente'];
    } else {
      _selectedFilters = _filterStore.selectedStatuses.toList();
    }

    _store.loadBudgets(
      widget.userId,
      userName: widget.userName,
      userCargo: widget.userCargo,
      partnerName: widget.partnerName,
    );
  }

  void _handleSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterStore.setBudgetSearchQuery(query);
  }

  void _handleFiltersChanged(List<String> filters) {
    setState(() {
      _selectedFilters = List.from(filters);
    });

    _filterStore.clearStatusFilter();
    for (final filter in filters) {
      _filterStore.toggleStatus(filter.toLowerCase());
    }
  }

  void _handleReset() {
    _filterStore.clearBudgetSearch();
    _filterStore.clearStatusFilter();
    _filterStore.toggleStatus('pendente');
  }

  void _onBudgetTap(int budgetId) {
    Modular.to.pushNamed(
      '/reports/budget/$budgetId',
      arguments: {
        'partnerName': widget.partnerName,
        'userName': widget.userName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Gestão admnistrativa',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: () => _store.refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ReportFilterWidget(
                onSearchChanged: _handleSearchChanged,
                onFiltersChanged: _handleFiltersChanged,
                onReset: _handleReset,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.partnerName ?? 'Empresa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: const Color(0xFF484848),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.userName ?? 'Vendedor',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF828282),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Observer(
              builder: (_) {
                if (_store.isLoading && _store.allBudgets.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (_store.error != null && _store.allBudgets.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Erro: ${_store.error}'),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () => _store.refresh(),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final budgets = _store.filteredBudgets;

                if (budgets.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 200.h),
                          const Center(
                            child: Text('Nenhum orçamento encontrado'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final b = budgets[index];

                      ReportBudgetStatus status;
                      switch (b.status.toLowerCase()) {
                        case 'aprovado':
                          status = ReportBudgetStatus.approved;
                          break;
                        case 'nao_aprovado':
                          status = ReportBudgetStatus.notApproved;
                          break;
                        case 'expirado':
                          status = ReportBudgetStatus.expired;
                          break;
                        default:
                          status = ReportBudgetStatus.pending;
                      }

                      int daysRemaining = 0;
                      if (b.dataValidade != null) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final target = DateTime(b.dataValidade!.year, b.dataValidade!.month, b.dataValidade!.day);
                        final difference = target.difference(today).inDays;
                        daysRemaining = difference > 0 ? difference : 0;
                      }

                      return ReportBudgetCardWidget(
                        title: b.nome ?? 'Orçamento #${b.id}',
                        budgetCode: b.codigo,
                        dueDate: b.dataValidade ?? DateTime.now(),
                        totalValue: b.total,
                        daysRemaining: daysRemaining,
                        status: status,
                        isArchived: b.isArchived,
                        userRole: ReportUserRole.admin,
                        onTap: () => _onBudgetTap(b.id),
                      );
                    }, childCount: budgets.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
