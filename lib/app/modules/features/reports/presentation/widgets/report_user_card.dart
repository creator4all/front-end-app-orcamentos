import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/report_user.dart';

/// Card para exibir informações de um usuário com estatísticas de vendas.
///
/// Layout conforme mockup:
/// - Linha 1: Nome + Badge de cargo (space-between)
/// - Linha 2: Total de vendas em negrito
/// - Linha 3: 4 badges de status (fundo branco, borda azul)
class ReportUserCard extends StatelessWidget {
  final ReportUser user;
  final VoidCallback? onTap;

  const ReportUserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  /// Formata valor monetário em BRL
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
            // Linha 1: Nome + Badge de cargo (space-between)
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

            // Linha 2: Total de vendas em negrito
            Text(
              'Total de vendas: ${_formatCurrency(user.totalVendas)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),

            SizedBox(height: 12.h),

            // Linha 3: 4 badges de status
            Row(
              children: [
                _buildStatusBadge('Aprovado', user.aprovados),
                SizedBox(width: 8.w),
                _buildStatusBadge('Pendente', user.pendentes),
                SizedBox(width: 8.w),
                _buildStatusBadge('Expirado', user.expirados),
                SizedBox(width: 8.w),
                _buildStatusBadge('Não aprovado', user.naoAprovados),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Badge de cargo (estilo similar ao da página de budget_list)
  Widget _buildCargoBadge(String cargo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F0FF),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        cargo,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0C498E),
        ),
      ),
    );
  }

  /// Badge de status: fundo branco, borda azul, texto + quantidade
  Widget _buildStatusBadge(String label, int count) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFF0E3562)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8.sp,
                color: const Color(0xFF0E3562),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0E3562),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
