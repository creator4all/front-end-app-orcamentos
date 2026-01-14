import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/user_avatar_widget.dart';
import '../../domain/entities/managed_user.dart';

/// Widget que representa um item da lista de usuários
/// Layout horizontal: Avatar, Column (nome/role/email), Switch
class UserListItemWidget extends StatelessWidget {
  final ManagedUser user;
  final bool hasPendingChanges;
  final ValueChanged<bool> onStatusChanged;
  final ValueChanged<int> onRoleChanged;

  const UserListItemWidget({
    super.key,
    required this.user,
    this.hasPendingChanges = false,
    required this.onStatusChanged,
    required this.onRoleChanged,
  });

  /// Roles disponíveis para seleção (sem Administrador)
  static const List<Map<String, dynamic>> availableRoles = [
    {'id': 1, 'name': 'Vendedor'},
    {'id': 2, 'name': 'Gestor'},
  ];

  /// Obtém cor de fundo da tag de role
  Color _getRoleBackgroundColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'gestor':
        return const Color(0xFFE0F4FF);
      case 'vendedor':
        return const Color(0xFFE0F0E0);
      case 'administrador':
        return const Color(0xFFFFE0E0);
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  /// Obtém cor do texto da tag de role
  Color _getRoleTextColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'gestor':
        return const Color(0xFF0C498E);
      case 'vendedor':
        return const Color(0xFF155724);
      case 'administrador':
        return const Color(0xFF721C24);
      default:
        return const Color(0xFF333333);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          UserAvatarWidget(
            avatarBase64: user.avatarBase64,
            userName: user.name,
            radius: 22,
          ),

          SizedBox(width: 10.w),

          // Coluna com nome, role tag e email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 3.h),

                // Tag de Role com dropdown
                _buildRoleTag(),

                SizedBox(height: 3.h),

                // Email
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF666666),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 6.w),

          // Switch
          SizedBox(
            height: 24.h,
            child: Switch(
              value: user.status,
              onChanged: onStatusChanged,
              activeColor: const Color(0xFF4CAF50),
              inactiveThumbColor: const Color(0xFFBDBDBD),
              inactiveTrackColor: const Color(0xFFE0E0E0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTag() {
    return PopupMenuButton<int>(
      initialValue: user.roleId,
      onSelected: onRoleChanged,
      offset: Offset(0, 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      itemBuilder: (context) => availableRoles.map((role) {
        return PopupMenuItem<int>(
          value: role['id'],
          child: Text(
            role['name'],
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: _getRoleBackgroundColor(user.roleName),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.roleName.toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: _getRoleTextColor(user.roleName),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              size: 14.sp,
              color: _getRoleTextColor(user.roleName),
            ),
          ],
        ),
      ),
    );
  }
}
