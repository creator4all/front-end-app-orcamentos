import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SharedInfoWidget extends StatelessWidget {
  final DateTime sharedDate;
  final String sharedBy;

  const SharedInfoWidget({
    super.key,
    required this.sharedDate,
    required this.sharedBy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.person,
          size: 12.sp,
          color: const Color(0xFF828282),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            'Compartilhado por $sharedBy',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF828282),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(
          Icons.access_time,
          size: 12.sp,
          color: const Color(0xFF828282),
        ),
        SizedBox(width: 4.w),
        Text(
          _formatDate(sharedDate),
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFF828282),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
