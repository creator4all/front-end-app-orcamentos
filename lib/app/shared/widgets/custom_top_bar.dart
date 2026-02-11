import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../modules/features/auth/presentation/stores/auth_store.dart';
import '../../modules/features/profile/domain/repositories/profile_repository.dart';
import '../core/utils/token_cache.dart';
import 'custom_info_dialog.dart';
import 'delete_account_modal.dart';
import 'profile_modal.dart';
import 'user_avatar_widget.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final AuthStore? authStore;
  final VoidCallback? onProfileTap;
  final Widget? actionButton;

  const CustomTopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.authStore,
    this.onProfileTap,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF117BBD).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Back button (if needed) + Title
              Row(
                children: [
                  if (showBackButton) ...[
                    GestureDetector(
                      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.arrow_back,
                          size: 24.sp,
                          color: const Color(0xFF484848),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF484848),
                    ),
                  ),
                ],
              ),

              // Right side - Action button or User profile circle
              if (actionButton != null) ...[
                actionButton!,
              ] else if (!showBackButton) ...[
                Observer(
                  builder: (_) {
                    final userImageBase64 = authStore?.userDisplayAvatar;
                    final userName = authStore?.currentUser?.name ?? 'Usuário';
                    final hasUserData = authStore?.currentUser != null;

                    return GestureDetector(
                      onTap: () {
                        if (hasUserData) {
                          _showProfileModal(context);
                        } else if (onProfileTap != null) {
                          onProfileTap!();
                        }
                      },
                      child: UserAvatarWidget(
                        avatarBase64: userImageBase64,
                        userName: userName,
                        radius: 15,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Mostrar diálogo de confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE55353),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    // Se confirmado, realizar logout
    if (confirmed == true && authStore != null) {
      try {
        await authStore!.logout();
      } catch (e) {
        if (context.mounted) {
          CustomInfoDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Erro ao sair',
            message: 'Erro ao fazer logout: $e',
          );
        }
      }
    }
  }

  void _showProfileModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfileModal(
          userName: authStore?.userDisplayName ?? 'Usuário',
          userEmail: authStore?.userDisplayEmail ?? 'email@exemplo.com',
          userDocument: authStore?.userDisplayDocument ?? '000.000.000-00',
          userImageUrl: authStore?.userDisplayAvatar,
          userRole: authStore?.userRole,
          partnerName: authStore?.partnerName,
          isAdmin: authStore?.isAdmin ?? false,
          isManager: authStore?.isManager ?? false,
          onClose: () => Navigator.of(context).pop(),
          onEditProfile: () {
            Navigator.of(context).pop();
            Modular.to.pushNamed('/profile/');
          },
          onEditCompany: authStore?.hasPartnerData == true
              ? () {
                  Navigator.of(context).pop();
                  Modular.to.pushNamed('/partner/edit');
                }
              : null,
          onConfigureProducts: () {
            Navigator.of(context).pop();
            Modular.to.pushNamed('/product-management/');
          },
          onPartnerProspecting: () {
            Navigator.of(context).pop();
            Modular.to.pushNamed('/prospect/');
          },
          onAdministrativeManagement: () {
            Navigator.of(context).pop();
            // Admin vai para Gestão de Empresas, Gestor vai direto para Gestão de Usuários
            if (authStore?.isAdmin == true) {
              Modular.to.pushNamed('/partner-management/');
            } else {
              Modular.to.pushNamed('/user-management/');
            }
          },
          onWiki: () {
            Navigator.of(context).pop();
            // TODO: Implementar navegação para wiki
          },
          onDrive: () {
            Navigator.of(context).pop();
            Modular.to.pushNamed('/drive/');
          },
          onLogout: () {
            Navigator.of(context).pop();
            _handleLogout(context);
          },
          onDeleteAccount: () {
            Navigator.of(context).pop();
            _handleDeleteAccount(context);
          },
        );
      },
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final repository = Modular.get<ProfileRepository>();
    const secureStorage = FlutterSecureStorage();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DeleteAccountModal(
        userName: authStore?.userDisplayName ?? 'Usuário',
        onConfirmDelete: () async {
          final result = await repository.deleteAccount();

          result.fold(
            (failure) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                CustomInfoDialog.show(
                  context: context,
                  type: DialogType.error,
                  title: 'Erro ao excluir conta',
                  message: failure.message,
                );
              }
            },
            (mensagem) async {
              await secureStorage.delete(key: 'auth_token');
              await secureStorage.delete(key: 'user_data');
              TokenCache.instance.clearToken();

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              if (context.mounted) {
                CustomInfoDialog.show(
                  context: context,
                  type: DialogType.success,
                  title: 'Conta excluída',
                  message: mensagem,
                  onButtonPressed: () {
                    Modular.to.pushReplacementNamed('/auth/login');
                  },
                );
              }
            },
          );
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}
