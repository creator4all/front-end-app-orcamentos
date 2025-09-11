import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'profile_modal.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? userImageUrl;
  final String? userName;
  final String? userEmail;
  final String? userDocument;
  final VoidCallback? onProfileTap;

  const CustomTopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.userImageUrl,
    this.userName,
    this.userEmail,
    this.userDocument,
    this.onProfileTap,
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

              // Right side - User profile circle
              GestureDetector(
                onTap: () {
                  if (userName != null &&
                      userEmail != null &&
                      userDocument != null) {
                    _showProfileModal(context);
                  } else if (onProfileTap != null) {
                    onProfileTap!();
                  }
                },
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF117BBD),
                    image: userImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(userImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: userImageUrl == null
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20.sp,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfileModal(
          userName: userName ?? 'Usuário',
          userEmail: userEmail ?? 'email@exemplo.com',
          userDocument: userDocument ?? '000.000.000-00',
          userImageUrl: userImageUrl,
          onClose: () => Navigator.of(context).pop(),
          onEditProfile: () {
            Navigator.of(context).pop();
            // TODO: Implementar navegação para editar perfil
          },
          onConfigureProducts: () {
            Navigator.of(context).pop();
            // TODO: Implementar navegação para configurar produtos
          },
          onPartnerProspecting: () {
            Navigator.of(context).pop();
            // TODO: Implementar navegação para prospecção de parceiros
          },
          onAdministrativeManagement: () {
            Navigator.of(context).pop();
            // TODO: Implementar navegação para gestão administrativa
          },
          onWiki: () {
            Navigator.of(context).pop();
            // TODO: Implementar navegação para wiki
          },
          onDrive: () {
            Navigator.of(context).pop();
            // TODO: Implementar navegação para drive
          },
          onLogout: () {
            Navigator.of(context).pop();
            // TODO: Implementar logout
          },
          onDeleteAccount: () {
            Navigator.of(context).pop();
            // TODO: Implementar deletar conta
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}
