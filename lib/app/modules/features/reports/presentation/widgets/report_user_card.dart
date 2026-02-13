import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/report_user.dart';

class ReportUserCard extends StatelessWidget {
  final ReportUser user;
  final VoidCallback? onTap;

  const ReportUserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user.nome,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF484848),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                _buildCargoBadge(user.cargo),
              ],
            ),

            SizedBox(height: 12.h),

            Text(
              'Total de vendas: ${_formatCurrency(user.totalVendas)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                _buildStatusBadge('Aprovado', user.aprovados),
                SizedBox(width: 8.w),
                _buildStatusBadge('Pendente', user.pendentes),
                SizedBox(width: 8.w),
                _buildStatusBadge('Expirado', user.expirados),
                SizedBox(width: 8.w),
                _buildStatusBadge('NÃ£o aprovado', user.naoAprovados),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildCargoBadge(String cargo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getRoleBackgroundColor(cargo),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        cargo.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: _getRoleTextColor(cargo),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, int count) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFF0E3562)),
        ),
        child: Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0E3562),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
