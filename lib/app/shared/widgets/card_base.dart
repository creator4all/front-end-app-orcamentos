import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable base card container with optional border and shadow.
///
/// Specs:
/// - Border radius: 10
/// - Drop shadow: color #000000, blur 8, y-offset 2 (can be disabled)
/// - Border color: #117BBD (can be disabled)
/// - Width: full (stretches to available width)
/// - Height: fits its content (based on provided children)
class CardBase extends StatelessWidget {
  /// Widgets to render inside the card, stacked vertically.
  final List<Widget> children;

  /// Inner spacing of the card content.
  final EdgeInsetsGeometry padding;

  /// Optional outer spacing around the card.
  final EdgeInsetsGeometry? margin;

  /// Enables the box shadow.
  final bool enableShadow;

  /// Enables the border.
  final bool enableBorder;

  /// Corner radius; defaults to 10.
  final double borderRadius;

  /// Shadow blur radius; defaults to 8.
  final double shadowBlurRadius;

  /// Shadow vertical offset; defaults to 2.
  final double shadowYOffset;

  /// Border color; defaults to #117BBD.
  final Color borderColor;

  /// Background color; defaults to white.
  final Color backgroundColor;

  /// Shadow base color; defaults to black.
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
      width: double.infinity, // full width
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
