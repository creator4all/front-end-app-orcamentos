import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../stores/report_filter_store.dart';
import '../stores/report_user_list_store.dart';
import '../widgets/report_date_filter.dart';
import '../widgets/report_period_label.dart';
import '../widgets/report_user_card.dart';

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

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ReportUserListStore>();
    _filterStore = Modular.get<ReportFilterStore>();

    _filterStore.resetFilters();

    _loadData();
  }

  Future<void> _loadData() async {
    await _store.loadUsers(widget.partnerId, partnerName: widget.partnerName);
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
    _filterStore.clearStatusFilter();
    Modular.to.pushNamed(
      '/reports/user/$userId/budgets',
      arguments: {
        'userName': userName,
        'userCargo': userCargo,
        'partnerName': widget.partnerName,
      },
    );
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
                    Observer(
                        builder: (_) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReportDateFilter(
                                  dataInicio: _filterStore.dataInicio,
                                  dataFim: _filterStore.dataFim,
                                  onDataInicioChanged: (date) {
                                    _filterStore.setDataInicio(date);
                                    _onDateFilterApplied();
                                  },
                                  onDataFimChanged: (date) {
                                    _filterStore.setDataFim(date);
                                    _onDateFilterApplied();
                                  },
                                  onClear: () {
                                    _filterStore.clearDateFilter();
                                    _onDateFilterApplied();
                                  },
                                ),
                                ReportPeriodLabel(
                                    start: _filterStore.dataInicio,
                                    end: _filterStore.dataFim),
                              ],
                            )),
                  ],
                ),
              ),
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
}
