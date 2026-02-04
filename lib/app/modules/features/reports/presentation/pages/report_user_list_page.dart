import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../stores/report_filter_store.dart';
import '../stores/report_user_list_store.dart';
import '../widgets/report_user_card.dart';

/// Página que lista os usuários de uma empresa com estatísticas de vendas.
///
/// Layout conforme mockup:
/// - Header: Nome da empresa (partnerName)
/// - Container de filtros com borda azul
/// - Lista de usuários com cards
class ReportUserListPage extends StatefulWidget {
  final int partnerId;
  final String? partnerName;

  const ReportUserListPage({
    super.key,
    required this.partnerId,
    this.partnerName,
  });

  @override
  State<ReportUserListPage> createState() => _ReportUserListPageState();
}

class _ReportUserListPageState extends State<ReportUserListPage> {
  late final ReportUserListStore _store;
  late final ReportFilterStore _filterStore;
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ReportUserListStore>();
    _filterStore = Modular.get<ReportFilterStore>();

    // Limpar filtros ao entrar na página
    _filterStore.resetFilters();

    // Carregar usuários e depois as vendas do parceiro para calcular contadores
    _loadData();
  }

  Future<void> _loadData() async {
    await _store.loadUsers(widget.partnerId, partnerName: widget.partnerName);
    await _store.loadPartnerSales(widget.partnerId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _filterStore.setUserSearchQuery(query);
  }

  void _onDateFilterApplied() {
    _store.refresh();
  }

  void _onResetFilters() {
    _searchController.clear();
    _filterStore.resetFilters();
    _onDateFilterApplied();
  }

  void _onUserTap(int userId, String userName, String userCargo) {
    Modular.to.pushNamed(
      '/reports/user/$userId/budgets',
      arguments: {
        'userName': userName,
        'userCargo': userCargo,
        'partnerName': widget.partnerName,
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? _filterStore.dataInicio ?? DateTime.now()
        : _filterStore.dataFim ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      if (isStartDate) {
        _filterStore.setDataInicio(picked);
      } else {
        _filterStore.setDataFim(picked);
      }
      _onDateFilterApplied();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomTopBar(
        title: widget.partnerName ?? 'Relatórios',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: _store.refresh,
        color: const Color(0xFF0E3562),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Container de filtros com borda azul (estilo BudgetFilterWidget)
              Container(
                margin: EdgeInsets.symmetric(vertical: 0.h, horizontal: 10.w),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF3A99D9),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFF484848),
                          ),
                        ),
                        GestureDetector(
                          onTap: _onResetFilters,
                          child: Text(
                            'Resetar',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF484848),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Campo de busca
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Busca por nome',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF8C8C8C),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20.sp,
                          color: const Color(0xFF8C8C8C),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 10.h,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF484848),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Filtros de data
                    Observer(
                      builder: (_) => Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'De:',
                              date: _filterStore.dataInicio,
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildDateField(
                              label: 'Até:',
                              date: _filterStore.dataFim,
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de usuários
              Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0E3562),
                        ),
                      ),
                    );
                  }

                  if (_store.error != null) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.h),
                      child: Center(
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
                      ),
                    );
                  }

                  final users = _store.filteredUsers;

                  if (users.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.h),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48.w,
                              color: const Color(0xFF828282),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Nenhum usuário encontrado',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF828282),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ReportUserCard(
                        user: user,
                        onTap: () => _onUserTap(
                          user.id,
                          user.nome,
                          user.cargo,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF828282),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                date != null ? _dateFormat.format(date) : 'dd/mm/aaaa',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: date != null
                      ? const Color(0xFF484848)
                      : const Color(0xFF828282),
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 16.w,
              color: const Color(0xFF828282),
            ),
          ],
        ),
      ),
    );
  }
}
