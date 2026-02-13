import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardBase extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool enableShadow;

  final bool enableBorder;
  final double borderRadius;

  final double shadowBlurRadius;

  final double shadowYOffset;

  final Color borderColor;

  final Color backgroundColor;
  final Color shadowColor;

  const CardBase({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.enableShadow = true,
    this.enableBorder = false,
    this.borderRadius = 10,
    this.shadowBlurRadius = 8,
    this.shadowYOffset = 2,
    this.borderColor = const Color(0xFF117BBD),
    this.backgroundColor = Colors.white,
    this.shadowColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final List<BoxShadow> shadows = enableShadow
        ? [
            BoxShadow(
              color: shadowColor.withOpacity(0.25),
              blurRadius: shadowBlurRadius,
              offset: Offset(0, shadowYOffset),
            ),
          ]
        : const [];

    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      constraints: BoxConstraints(
        maxHeight: 85.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: enableBorder ? Border.all(color: borderColor) : null,
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
