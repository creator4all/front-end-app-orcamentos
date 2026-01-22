import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../stores/report_budget_list_store.dart';
import '../stores/report_filter_store.dart';

/// Página que lista os orçamentos de um usuário específico.
///
/// Layout conforme mockup:
/// - Header: "Gestão admnistrativa"
/// - Container de filtros com borda (busca + chips de status)
/// - Info: Nome da empresa + "Vendedor: nome"
/// - Lista de orçamentos
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
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ReportBudgetListStore>();
    _filterStore = Modular.get<ReportFilterStore>();

    // Limpar apenas busca e status (manter filtros de data)
    _filterStore.clearBudgetSearch();
    _filterStore.clearStatusFilter();

    // Carregar orçamentos
    _store.loadBudgets(
      widget.userId,
      userName: widget.userName,
      userCargo: widget.userCargo,
      partnerName: widget.partnerName,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _filterStore.setBudgetSearchQuery(query);
  }

  void _onBudgetTap(int budgetId) {
    Modular.to.pushNamed('/reports/budget/$budgetId');
  }

  void _onResetFilters() {
    _searchController.clear();
    _filterStore.clearBudgetSearch();
    _filterStore.clearStatusFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            CustomTopBar(
              title: 'Gestão admnistrativa',
              showBackButton: true,
              onBackPressed: () => Modular.to.pop(),
            ),

            // Container de filtros com borda
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Filtros + Resetar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF484848),
                        ),
                      ),
                      GestureDetector(
                        onTap: _onResetFilters,
                        child: Text(
                          'Resetar',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF0E3562),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Campo de busca
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Busca por código ou cidade',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF828282),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20.w,
                        color: const Color(0xFF828282),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Chips de status
                  Observer(
                    builder: (_) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip('Aprovados', 'aprovado'),
                          SizedBox(width: 8.w),
                          _buildStatusChip('Não aprovados', 'nao_aprovado'),
                          SizedBox(width: 8.w),
                          _buildStatusChip('Expirados', 'expirado'),
                          SizedBox(width: 8.w),
                          _buildStatusChip('Pendentes', 'pendente'),
                          SizedBox(width: 8.w),
                          _buildStatusChip('Arquivados', 'arquivado'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info: Empresa + Vendedor
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.partnerName != null)
                    Text(
                      widget.partnerName!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF484848),
                      ),
                    ),
                  if (widget.userName != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Vendedor: ${widget.userName}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF828282),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Lista de orçamentos
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0E3562),
                      ),
                    );
                  }

                  if (_store.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: const Color(0xFF828282),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _store.error!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF828282),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: _store.refresh,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  final budgets = _store.filteredBudgets;

                  if (budgets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 48.w,
                            color: const Color(0xFF828282),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Nenhum orçamento encontrado',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF828282),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _store.refresh,
                    color: const Color(0xFF0E3562),
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        return _buildBudgetCard(budget);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String statusKey) {
    final isSelected = _filterStore.selectedStatuses.contains(statusKey);

    return GestureDetector(
      onTap: () => _filterStore.toggleStatus(statusKey),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E3562) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF0E3562),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : const Color(0xFF0E3562),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(dynamic budget) {
    final diasRestantes = _calculateDaysRemaining(budget.dataValidade);

    return GestureDetector(
      onTap: () => _onBudgetTap(budget.id),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título (orc_nome ou cidade)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    budget.nome ?? 'Orçamento ${budget.codigo}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF484848),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                // Valor
                Text(
                  _currencyFormat.format(budget.total),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E3562),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Código + Data
            Row(
              children: [
                Text(
                  budget.codigo,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF828282),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.calendar_today,
                  size: 12.w,
                  color: const Color(0xFF828282),
                ),
                SizedBox(width: 4.w),
                Text(
                  budget.dataValidade != null
                      ? _dateFormat.format(budget.dataValidade!)
                      : '-',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF828282),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Dias restantes + Status tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.w,
                      color: const Color(0xFF828282),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$diasRestantes dias rest.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF828282),
                      ),
                    ),
                  ],
                ),
                _buildStatusTag(budget.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDaysRemaining(DateTime? dataValidade) {
    if (dataValidade == null) return 0;
    final hoje = DateTime.now();
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    final dias = dataValidade.difference(hojeDate).inDays;
    return dias > 0 ? dias : 0;
  }

  Widget _buildStatusTag(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'aprovado':
        bgColor = const Color(0xFFB6FFAD);
        textColor = const Color(0xFF0E5210);
        break;
      case 'pendente':
        bgColor = const Color(0xFFE0F0FF);
        textColor = const Color(0xFF0C498E);
        break;
      case 'expirado':
        bgColor = const Color(0xFFF1DAB7);
        textColor = const Color(0xFF573502);
        break;
      case 'nao_aprovado':
        bgColor = const Color(0xFFEEB8B8);
        textColor = const Color(0xFF571414);
        break;
      default:
        bgColor = const Color(0xFFE0F0FF);
        textColor = const Color(0xFF0C498E);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
