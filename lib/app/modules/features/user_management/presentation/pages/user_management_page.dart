import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../shared/utils/user_role_mapper.dart';
import '../../../../../shared/widgets/custom_info_dialog.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../stores/user_management_store.dart';
import '../widgets/user_list_item_widget.dart';

/// Página de gestão de usuários
/// Acessível para Gestor (seus usuários) e Admin (usuários de um parceiro)
class UserManagementPage extends StatefulWidget {
  /// ID do parceiro (para Admin visualizando usuários de um parceiro específico)
  final int? partnerId;

  const UserManagementPage({
    super.key,
    this.partnerId,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late final UserManagementStore _store;
  late final AuthStore _authStore;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _store = Modular.get<UserManagementStore>();
    _authStore = Modular.get<AuthStore>();

    // Configurar partnerId se fornecido (contexto Admin)
    if (widget.partnerId != null) {
      _store.setPartnerId(widget.partnerId);
    }

    // Carregar usuários ao iniciar
    _store.loadUsers();

    // Configurar scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    // Limpar partnerId ao sair
    _store.setPartnerId(null);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _store.loadMoreUsers();
    }
  }

  /// Retorna o ID da role do usuário logado
  int get _currentUserRoleId {
    return getRoleIdFromName(_authStore.currentUser?.role?.name);
  }

  /// Exibe dialog de permissão negada
  void _showPermissionDeniedDialog() {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.warning,
      title: 'Ação não permitida',
      message: 'Você não pode alterar usuários com cargo superior ao seu.',
    );
  }

  Future<void> _handleSave() async {
    if (!_store.hasChanges) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Atenção',
        message: 'Nenhuma alteração para salvar',
      );
      return;
    }

    final result = await _store.saveChanges();

    if (!mounted) return;

    if (result != null && result.isSuccess) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Sucesso!',
        message: result.message,
      );
    } else if (_store.error != null) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro',
        message: 'Erro ao salvar: ${_store.error}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomTopBar(
        title: 'Gestão de Usuários',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
        authStore: _authStore,
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              onChanged: _store.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar usuários...',
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

          // Lista de usuários
          Expanded(
            child: Observer(
              builder: (_) {
                // Skeleton durante loading inicial
                if (_store.isLoading && _store.users.isEmpty) {
                  return _buildSkeleton();
                }

                // Erro
                if (_store.error != null && _store.users.isEmpty) {
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
                          'Erro ao carregar usuários',
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
                          onPressed: _store.loadUsers,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                // Lista vazia
                if (_store.filteredUsers.isEmpty) {
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
                          _store.searchQuery.isEmpty
                              ? 'Nenhum usuário encontrado'
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

                // Lista de usuários
                return RefreshIndicator(
                  onRefresh: _store.loadUsers,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:
                        EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h),
                    itemCount: _store.filteredUsers.length +
                        (_store.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator no final
                      if (index == _store.filteredUsers.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final user = _store.filteredUsers[index];
                      final hasPendingChanges =
                          _store.pendingChanges.containsKey(user.id);

                      return UserListItemWidget(
                        user: user,
                        hasPendingChanges: hasPendingChanges,
                        currentUserRoleId: _currentUserRoleId,
                        onStatusChanged: (status) =>
                            _store.updateUserStatus(user.id, status),
                        onRoleChanged: (roleId) {
                          final roleName = UserListItemWidget.availableRoles
                              .firstWhere((r) => r['id'] == roleId)['name'];
                          _store.updateUserRole(user.id, roleId, roleName);
                        },
                        onPermissionDenied: _showPermissionDeniedDialog,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Observer(
        builder: (_) => FloatingActionButton.extended(
          onPressed: _store.isSaving ? null : _handleSave,
          backgroundColor: _store.hasChanges
              ? const Color(0xFF4CAF50)
              : const Color(0xFF9E9E9E),
          icon: _store.isSaving
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(Icons.save, color: Colors.white, size: 20.sp),
          label: Row(
            children: [
              Text(
                'Salvar Alterações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_store.hasChanges) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    _store.changesCount > 9
                        ? '9+'
                        : _store.changesCount.toString(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFE0E0E0),
        highlightColor: Color(0xFFF5F5F5),
        duration: Duration(milliseconds: 1000),
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) => _buildUserCardSkeleton(),
      ),
    );
  }

  Widget _buildUserCardSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          // Info placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 60.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 150.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          // Switch placeholder
          Container(
            width: 40.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }
}
