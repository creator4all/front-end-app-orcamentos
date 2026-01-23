import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/days_remaining_widget.dart';
import '../../../../../shared/widgets/status_tag_widget.dart';

enum ReportUserRole { admin, manager, seller }

enum ReportBudgetStatus { pending, approved, notApproved, expired }

/// Card para exibir orçamento na lista de relatórios.
/// Cópia do BudgetCardWidget para uso independente.
class ReportBudgetCardWidget extends StatelessWidget {
  final String title;
  final String? partner;
  final String? seller;
  final String budgetCode;
  final DateTime dueDate;
  final double totalValue;
  final int daysRemaining;
  final ReportBudgetStatus status;
  final bool isArchived;
  final ReportUserRole userRole;
  final VoidCallback? onTap;

  const ReportBudgetCardWidget({
    super.key,
    required this.title,
    this.partner,
    this.seller,
    required this.budgetCode,
    required this.dueDate,
    required this.totalValue,
    required this.daysRemaining,
    required this.status,
    this.isArchived = false,
    required this.userRole,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 90.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 0.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(
            color: const Color(0xFFD9D9D9),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF484848),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Parceiro e Vendedor (baseado no role)
            if (_shouldShowPartnerAndSeller())
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (userRole == ReportUserRole.admin && partner != null)
                    Expanded(
                      child: Text(
                        'Parceiro: $partner',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF828282),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Spacer para manter Vendedor à direita quando Parceiro não é exibido
                  if (userRole != ReportUserRole.admin || partner == null)
                    const Spacer(),
                  if (seller != null)
                    Text(
                      'Vendedor: $seller',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF828282),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

            // Linha principal: Código/Data vs Valor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lado esquerdo: Código e Data na mesma linha
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        budgetCode,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF828282),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.event_available,
                        size: 12.sp,
                        color: const Color(0xFF1C94DF),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          _formatDate(dueDate),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF828282),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lado direito: Valor
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatCurrency(totalValue),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Linha inferior: Dias restantes vs Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dias restantes
                DaysRemainingWidget(
                  daysRemaining: daysRemaining,
                ),

                // Status tags
                Row(
                  children: [
                    StatusTagWidget(
                      type: _mapStatusToTagType(status),
                    ),
                    if (isArchived) ...[
                      SizedBox(width: 8.w),
                      const StatusTagWidget(
                        type: TagType.archived,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowPartnerAndSeller() {
    switch (userRole) {
      case ReportUserRole.admin:
        return partner != null || seller != null;
      case ReportUserRole.manager:
        return seller != null;
      case ReportUserRole.seller:
        return false;
    }
  }

  TagType _mapStatusToTagType(ReportBudgetStatus status) {
    switch (status) {
      case ReportBudgetStatus.pending:
        return TagType.pending;
      case ReportBudgetStatus.approved:
        return TagType.approved;
      case ReportBudgetStatus.notApproved:
        return TagType.notApproved;
      case ReportBudgetStatus.expired:
        return TagType.expired;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double value) {
    // Converte para string com 2 casas decimais
    String valueString = value.toStringAsFixed(2);

    // Separa parte inteira e decimal
    List<String> parts = valueString.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];

    // Adiciona pontos para milhares
    String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );

    // Retorna no formato brasileiro: R$999.999.999,99
    return 'R\$ $formattedInteger,$decimalPart';
  }
}
