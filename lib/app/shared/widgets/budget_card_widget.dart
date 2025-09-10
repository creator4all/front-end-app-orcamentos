import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'days_remaining_widget.dart';
import 'status_tag_widget.dart';

enum UserRole { admin, manager, seller }

enum BudgetStatus { pending, approved, notApproved, expired }

class BudgetCardWidget extends StatelessWidget {
  final String title;
  final String? partner;
  final String? seller;
  final String budgetCode;
  final DateTime dueDate;
  final double totalValue;
  final int daysRemaining;
  final BudgetStatus status;
  final bool isArchived;
  final UserRole userRole;
  final VoidCallback? onTap;

  const BudgetCardWidget({
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
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
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
                  if (userRole == UserRole.admin && partner != null)
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
      case UserRole.admin:
        return partner != null || seller != null;
      case UserRole.manager:
        return seller != null;
      case UserRole.seller:
        return false;
    }
  }

  TagType _mapStatusToTagType(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.pending:
        return TagType.pending;
      case BudgetStatus.approved:
        return TagType.approved;
      case BudgetStatus.notApproved:
        return TagType.notApproved;
      case BudgetStatus.expired:
        return TagType.expired;
    }
  }

  Widget _buildStatusTag(BudgetStatus status) {
    late Color textColor;
    late Color backgroundColor;
    late String label;

    switch (status) {
      case BudgetStatus.pending:
        textColor = const Color(0xFF0C498E);
        backgroundColor = const Color(0xFFE0F0FF);
        label = 'pendente';
        break;
      case BudgetStatus.approved:
        textColor = const Color(0xFF0E5210);
        backgroundColor = const Color(0xFFB6FFAD);
        label = 'aprovado';
        break;
      case BudgetStatus.notApproved:
        textColor = const Color(0xFF571414);
        backgroundColor = const Color(0xFFEEB8B8);
        label = 'não aprovado';
        break;
      case BudgetStatus.expired:
        textColor = const Color(0xFF573502);
        backgroundColor = const Color(0xFFF1DAB7);
        label = 'expirado';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
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
