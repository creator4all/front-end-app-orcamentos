import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/utils/currency_utils.dart';
import '../../../../../shared/widgets/days_remaining_widget.dart';
import '../../../../../shared/widgets/status_tag_widget.dart';

enum ReportUserRole { admin, manager, seller }

enum ReportBudgetStatus { pending, approved, notApproved, expired }

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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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

                Expanded(
                  flex: 2,
                  child: Text(
                    CurrencyUtils.formatBRL(totalValue),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DaysRemainingWidget(
                  daysRemaining: daysRemaining,
                ),

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
}
