import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_checkbox.dart';

class SelectAllCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color checkedColor;
  final Color uncheckedBorderColor;

  const SelectAllCard({
    super.key,
    required this.value,
    this.onChanged,
    this.checkedColor = const Color(0xFF117BBD),
    this.uncheckedBorderColor = const Color(0xFFD9D9D9),
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;
    final borderColor = value ? checkedColor : uncheckedBorderColor;
    final label = value ? 'Deselecionar todos' : 'Selecionar todos';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled ? () => onChanged!.call(!value) : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        constraints: BoxConstraints(minHeight: 56.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomCheckbox(
              value: value,
              onChanged: isEnabled ? onChanged : null,
              checkedColor: checkedColor,
              uncheckedBorderColor: uncheckedBorderColor,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF484848),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
