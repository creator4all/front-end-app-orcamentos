import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DaysRemainingWidget extends StatelessWidget {
  final int daysRemaining;

  const DaysRemainingWidget({
    super.key,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 9.sp,
            color: const Color(0xFF484848),
          ),
          SizedBox(width: 4.w),
          Text(
            '$daysRemaining dias rest.',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF484848),
            ),
          ),
        ],
      ),
    );
  }
}
