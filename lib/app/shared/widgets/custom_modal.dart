import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom modal component with modern layout concepts.
///
/// Features:
/// - Container height defined by its content
/// - Top rounded corners (10px radius)
/// - Straight bottom borders
/// - Handle bar at the top
/// - Customizable title and content
class CustomModal extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onClose;

  const CustomModal({
    super.key,
    required this.title,
    required this.content,
    this.onClose,
  });

  /// Show the modal using showModalBottomSheet
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomModal(
        title: title,
        content: content,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.h),
              width: 100.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: content,
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
