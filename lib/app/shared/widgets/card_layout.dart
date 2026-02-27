import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'action_button.dart';

class CardLayout extends StatelessWidget {
  final Widget? firstColumn;

  final Widget? secondColumn;

  final Widget? thirdColumnTop;

  final bool showActionButton;
  final VoidCallback? onActionTap;

  final bool showCheckbox;

  final bool isChecked;

  final ValueChanged<bool?>? onCheckboxChanged;

  final Widget? icon;

  final bool showBorder;

  final Color borderColor;

  final bool showShadow;

  final Color shadowColor;

  final Color backgroundColor;

  final double borderRadius;

  final double maxHeight;

  final EdgeInsets padding;

  const CardLayout({
    super.key,
    this.firstColumn,
    this.secondColumn,
    this.thirdColumnTop,
    this.showActionButton = true,
    this.onActionTap,
    this.showCheckbox = true,
    this.isChecked = false,
    this.onCheckboxChanged,
    this.icon,
    this.showBorder = true,
    this.borderColor = const Color(0xFFE0E0E0),
    this.showShadow = false,
    this.shadowColor = const Color(0xFF000000),
    this.backgroundColor = Colors.white,
    this.borderRadius = 10,
    this.maxHeight = 85,
    this.padding =
        const EdgeInsets.only(left: 12, top: 12, right: 0, bottom: 0),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: padding,
      constraints: BoxConstraints(maxHeight: maxHeight.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: borderColor, width: 1.0) : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: SizedBox(
        height: 70.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (firstColumn != null || showCheckbox || icon != null)
              Expanded(
                flex: showCheckbox ? 2 : 1,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: showCheckbox ? 12.w : 0,
                    bottom: 12.h,
                  ),
                  child: firstColumn ??
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (showCheckbox)
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: Checkbox(
                                value: isChecked,
                                onChanged: onCheckboxChanged,
                                activeColor: const Color(0xFF117BBD),
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return const Color(0xFF117BBD);
                                    }
                                    return Colors.white;
                                  },
                                ),
                                side: BorderSide(
                                  color: isChecked
                                      ? const Color(0xFF117BBD)
                                      : Colors.grey[300]!,
                                  width: 2.0,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          if (showCheckbox && icon != null)
                            SizedBox(width: 8.w),
                          if (icon != null)
                            Flexible(
                              child: icon!,
                            ),
                        ],
                      ),
                ),
              ),

            if (secondColumn != null)
              Expanded(
                flex: showCheckbox ? 7 : 8,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                  child: secondColumn!,
                ),
              ),

            if (thirdColumnTop != null || showActionButton)
              Expanded(
                flex: 2,
                child: Container(
                  height: 70.h,
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (thirdColumnTop != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h, right: 8.w),
                          child: thirdColumnTop!,
                        ),
                      if (showActionButton)
                        ActionButton(
                          onTap: onActionTap,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}