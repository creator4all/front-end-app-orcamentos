import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable action button with custom styling.
///
/// Features:
/// - Fixed dimensions (width: 50.w, height: 25.h)
/// - Blue background (#117BBD)
/// - Custom border radius (top-left: 15, bottom-right: 10)
/// - Right arrow icon
/// - Optional tap handler
class ActionButton extends StatelessWidget {
  /// Optional tap handler for the button.
  final VoidCallback? onTap;

  /// Button width; defaults to 50.w.
  final double width;

  /// Button height; defaults to 25.h.
  final double height;

  /// Background color; defaults to #117BBD.
  final Color backgroundColor;

  /// Icon color; defaults to white.
  final Color iconColor;

  /// Icon size; defaults to 16.
  final double iconSize;

  /// Top-left border radius; defaults to 15.
  final double topLeftRadius;

  /// Bottom-right border radius; defaults to 10.
  final double bottomRightRadius;

  const ActionButton({
    super.key,
    this.onTap,
    this.width = 50,
    this.height = 25,
    this.backgroundColor = const Color(0xFF117BBD),
    this.iconColor = Colors.white,
    this.iconSize = 16,
    this.topLeftRadius = 15,
    this.bottomRightRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      height: height.h,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeftRadius),
          bottomRight: Radius.circular(bottomRightRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius),
            bottomRight: Radius.circular(bottomRightRadius),
          ),
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.arrow_forward_ios,
              color: iconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
