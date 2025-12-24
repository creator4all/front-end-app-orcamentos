import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../stores/user_management_store.dart';
import '../widgets/user_list_item_widget.dart';

/// Página de gestão de usuários
/// Acessível apenas para Gestor e Administrador
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late final UserManagementStore _store;
  late final AuthStore _authStore;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store = Modular.get<UserManagementStore>();
    _authStore = Modular.get<AuthStore>();

    // Carregar usuários ao iniciar
    _store.loadUsers();

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _store.loadMoreUsers();
    }
  }

  Future<void> _handleSave() async {
    if (!_store.hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma alteração para salvar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await _store.saveChanges();

    if (!mounted) return;

    if (result != null && result.isSuccess) {
      _showSuccessDialog(result.message);
    } else if (_store.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${_store.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: const Color(0xFF4CAF50),
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Sucesso!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      body: Observer(
        builder: (_) {
          if (_store.isLoading && _store.users.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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

          if (_store.users.isEmpty) {
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
                    'Nenhum usuário encontrado',
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
            onRefresh: _store.loadUsers,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: _store.users.length + (_store.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator no final
                if (index == _store.users.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final user = _store.users[index];
                final hasPendingChanges =
                    _store.pendingChanges.containsKey(user.id);

                return UserListItemWidget(
                  user: user,
                  hasPendingChanges: hasPendingChanges,
                  onStatusChanged: (status) =>
                      _store.updateUserStatus(user.id, status),
                  onRoleChanged: (roleId) {
                    final roleName = UserListItemWidget.availableRoles
                        .firstWhere((r) => r['id'] == roleId)['name'];
                    _store.updateUserRole(user.id, roleId, roleName);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Observer(
        builder: (_) => FloatingActionButton(
          onPressed: _store.isSaving ? null : _handleSave,
          backgroundColor: _store.hasChanges
              ? const Color(0xFF4CAF50)
              : const Color(0xFF9E9E9E),
          child: _store.isSaving
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Stack(
                  children: [
                    Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                    if (_store.hasChanges)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _store.changesCount > 9
                                  ? '9+'
                                  : _store.changesCount.toString(),
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
