import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/managed_user.dart';

/// Widget que representa um item da lista de usuários
/// Exibe email, nome, cargo, toggle de status e dropdown de role
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasPendingChanges
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE0E0E0),
          width: hasPendingChanges ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email (destaque)
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 16.sp,
                color: const Color(0xFF117BBD),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF117BBD),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasPendingChanges)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Alterado',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 8.h),

          // Nome completo
          Text(
            user.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),

          SizedBox(height: 4.h),

          // Cargo
          if (user.cargo != null && user.cargo!.isNotEmpty)
            Text(
              'Cargo: ${user.cargo}',
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF666666),
              ),
            ),

          SizedBox(height: 12.h),

          // Row com Toggle de Status e Dropdown de Role
          Row(
            children: [
              // Toggle de Status
              Expanded(
                child: _buildStatusToggle(),
              ),

              SizedBox(width: 12.w),

              // Dropdown de Role
              Expanded(
                child: _buildRoleDropdown(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: user.status ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              user.status ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                user.status ? Icons.check_circle : Icons.cancel,
                size: 16.sp,
                color: user.status
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE57373),
              ),
              SizedBox(width: 6.w),
              Text(
                user.status ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: user.status
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
            width: 36.w,
            child: Switch(
              value: user.status,
              onChanged: onStatusChanged,
              activeColor: const Color(0xFF4CAF50),
              inactiveThumbColor: const Color(0xFFE57373),
              inactiveTrackColor: const Color(0xFFFFCDD2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: availableRoles.any((r) => r['id'] == user.roleId)
              ? user.roleId
              : availableRoles.first['id'],
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: const Color(0xFF666666),
            size: 20.sp,
          ),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
          items: availableRoles.map((role) {
            return DropdownMenuItem<int>(
              value: role['id'],
              child: Text(role['name']),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onRoleChanged(value);
            }
          },
        ),
      ),
    );
  }
}
