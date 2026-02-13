import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReadonlyCheckbox extends StatelessWidget {
  final bool value;

  final double? size;

  const ReadonlyCheckbox({
    super.key,
    required this.value,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 17.0;

    return Container(
      width: effectiveSize.w,
      height: effectiveSize.h,
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF9E9E9E)
            : Colors.white,
        border: Border.all(
          color: value
              ? const Color(0xFF9E9E9E)
              : const Color(0xFFBDBDBD),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: value
          ? Icon(
              Icons.check,
              color: Colors.white,
              size: (effectiveSize * 0.8).sp,
            )
          : null,
    );
  }
}
