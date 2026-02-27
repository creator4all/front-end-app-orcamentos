import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../stores/prospect_store.dart';
import '../widgets/prospect_card_widget.dart';

class ContactedProspectsPage extends StatefulWidget {
  const ContactedProspectsPage({super.key});

  @override
  State<ContactedProspectsPage> createState() => _ContactedProspectsPageState();
}

class _ContactedProspectsPageState extends State<ContactedProspectsPage> {
  late final ProspectStore _store;
  late final AuthStore _authStore;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ProspectStore>();
    _authStore = Modular.get<AuthStore>();

    _store.loadContactedProspects();

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
      _store.loadMoreContactedProspects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomTopBar(
        title: 'Empresas já contactadas',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
        authStore: _authStore,
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoadingContacted && _store.contactedProspects.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_store.error != null && _store.contactedProspects.isEmpty) {
            return _buildErrorState();
          }

          if (_store.contactedProspects.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _store.loadContactedProspects,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
              itemCount: _store.contactedProspects.length +
                  (_store.isLoadingMoreContacted ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _store.contactedProspects.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final prospect = _store.contactedProspects[index];
                return ProspectCardWidget(
                  prospect: prospect,
                  showContactButton: false,
                );
              },
            ),
          );
        },
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
              onPressed: _store.loadContactedProspects,
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
            Icons.check_circle_outline,
            size: 64.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'Nenhuma empresa contactada',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'As empresas marcadas como contactadas\naparecerão aqui',
            textAlign: TextAlign.center,
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
