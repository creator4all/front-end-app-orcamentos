import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable badge widget for displaying selected cities
/// with city name, state, and close button
///
/// Supports custom colors for different design systems:
/// - Default: Blue background (#2830F2) with white text
/// - Custom: Configurable colors via parameters
class CityBadgeWidget extends StatelessWidget {
  final String city;
  final String state;
  final VoidCallback onRemove;
  final bool showIcon;

  final Color backgroundColor;
  final Color textColor;
  final Color iconBackgroundColor;
  final Color iconColor;

  const CityBadgeWidget({
    super.key,
    required this.city,
    required this.state,
    required this.onRemove,
    this.showIcon = true,
    this.backgroundColor = const Color(0xFF2830F2),
    this.textColor = Colors.white,
    this.iconBackgroundColor = Colors.white,
    this.iconColor = const Color(0xFF2830F2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$city - $state',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: iconBackgroundColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12.sp,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}