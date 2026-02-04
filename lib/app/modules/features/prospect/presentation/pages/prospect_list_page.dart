import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../stores/prospect_store.dart';
import '../widgets/prospect_card_widget.dart';

/// Página principal de prospecção de parceiros
/// Exibe prospects não contactados
class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage> {
  late final ProspectStore _store;
  late final AuthStore _authStore;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ProspectStore>();
    _authStore = Modular.get<AuthStore>();

    // Carregar prospects ao iniciar
    _store.loadProspects();

    // Configurar scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isReachingEndOfPage = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (isReachingEndOfPage) {
      _store.loadMoreProspects();
    }
  }

  Future<void> _handleMarkContacted(int prospectId) async {
    final success = await _store.markAsContacted(prospectId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prospect marcado como contactado'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (_store.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_store.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToContacted() {
    Modular.to.pushNamed('/prospect/contacted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomTopBar(
        title: 'Prospecção de parceiros',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
        authStore: _authStore,
      ),
      body: Column(
        children: [
          // Banner para empresas já contactadas
          _buildContactedBanner(),

          // Lista de prospects
          Expanded(
            child: Observer(
              builder: (_) {
                if (_store.isLoading && _store.prospects.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_store.error != null && _store.prospects.isEmpty) {
                  return _buildErrorState();
                }

                if (_store.prospects.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _store.loadProspects,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                    itemCount: _store.prospects.length +
                        (_store.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator no final
                      if (index == _store.prospects.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final prospect = _store.prospects[index];
                      return ProspectCardWidget(
                        prospect: prospect,
                        showContactButton: true,
                        isMarkingContacted:
                            _store.markingContactedId == prospect.id,
                        onMarkContacted: () =>
                            _handleMarkContacted(prospect.id),
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

  Widget _buildContactedBanner() {
    return GestureDetector(
      onTap: _navigateToContacted,
      child: Container(
        width: double.infinity,
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: const BoxDecoration(
          color: Color(0xFFE0F0FF),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Empresas já contactadas',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0C498E),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: const Color(0xFF0C498E),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
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
              'Erro ao carregar prospects',
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
              onPressed: _store.loadProspects,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'Nenhum parceiro prospectado ainda',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Todos os parceiros já foram contactados.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
