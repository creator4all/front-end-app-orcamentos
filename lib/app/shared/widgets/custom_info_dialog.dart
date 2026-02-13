import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DialogType {
  info,

  success,

  warning,

  error,
}

class CustomInfoDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const CustomInfoDialog._({
    required this.type,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onButtonPressed,
  });
  static Future<void> show({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String message,
    String buttonText = 'Entendi',
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomInfoDialog._(
        type: type,
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case DialogType.info:
        return const Color(0xFFE3F2FD);
      case DialogType.success:
        return const Color(0xFFE8F5E9);
      case DialogType.warning:
        return const Color(0xFFFFF3E0);
      case DialogType.error:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get _iconColor {
    switch (type) {
      case DialogType.info:
        return const Color(0xFF117BBD);
      case DialogType.success:
        return const Color(0xFF56B34A);
      case DialogType.warning:
        return const Color(0xFFFF9800);
      case DialogType.error:
        return const Color(0xFFF44336);
    }
  }

  IconData get _icon {
    switch (type) {
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.success:
        return Icons.check_circle;
      case DialogType.warning:
      case DialogType.error:
        return Icons.warning_rounded;
    }
  }

  Color get _buttonColor {
    switch (type) {
      case DialogType.info:
        return const Color(0xFF117BBD);
      case DialogType.success:
        return const Color(0xFF56B34A);
      case DialogType.warning:
        return const Color(0xFFFF9800);
      case DialogType.error:
        return const Color(0xFF1E88E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: _backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: _iconColor,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onButtonPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}