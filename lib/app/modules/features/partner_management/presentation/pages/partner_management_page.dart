import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../stores/partner_management_store.dart';
import '../widgets/partner_card_widget.dart';
import '../widgets/partner_skeleton.dart';

class PartnerManagementPage extends StatefulWidget {
  const PartnerManagementPage({super.key});

  @override
  State<PartnerManagementPage> createState() => _PartnerManagementPageState();
}

class _PartnerManagementPageState extends State<PartnerManagementPage> {
  late final PartnerManagementStore _store;
  late final AuthStore _authStore;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _store = Modular.get<PartnerManagementStore>();
    _authStore = Modular.get<AuthStore>();

    _store.loadPartners();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isReachingEndOfPage = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (isReachingEndOfPage) {
      _store.loadMorePartners();
    }
  }

  void _onUsersPressed(int partnerId) {
    Modular.to.pushNamed('/user-management/partner/$partnerId');
  }

  void _onReportsPressed(int partnerId, String partnerName) {
    Modular.to.pushNamed(
      '/reports/partner/$partnerId',
      arguments: {'partnerName': partnerName},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomTopBar(
        title: 'Gestão de Empresas',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
        authStore: _authStore,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              onChanged: _store.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar empresas...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 20.sp,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (_store.isLoading && _store.partners.isEmpty) {
                  return const PartnerSkeleton();
                }

                if (_store.error != null && _store.partners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Erro ao carregar empresas',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _store.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _store.loadPartners,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (_store.filteredPartners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _store.searchQuery.isEmpty
                              ? 'Nenhuma empresa encontrada'
                              : 'Nenhum resultado para "${_store.searchQuery}"',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _store.loadPartners,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _store.filteredPartners.length +
                        (_store.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _store.filteredPartners.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final partner = _store.filteredPartners[index];
                      return PartnerCardWidget(
                        partner: partner,
                        onUsersPressed: () => _onUsersPressed(partner.id),
                        onReportsPressed: () =>
                            _onReportsPressed(partner.id, partner.tradeName),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
