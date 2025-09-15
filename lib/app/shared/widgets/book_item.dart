import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Book item component for modals.
///
/// Features:
/// - Container with max width and height up to 70.h
/// - Row layout with checkbox, book details, and quantity with arrow
class BookItem extends StatelessWidget {
  final String title;
  final String value;
  final String quantity; // Format: "1/1", "43/48", etc.
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onTap;

  const BookItem({
    super.key,
    required this.title,
    required this.value,
    required this.quantity,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Max width depending on where it is
        constraints: BoxConstraints(
          maxHeight: 70.h,
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF2830F2) : const Color(0xFFD9D9D9),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // First column: Checkbox
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onCheckboxChanged,
                  activeColor: const Color(0xFF2830F2),
                  checkColor: Colors.white,
                  fillColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF2830F2);
                      }
                      return Colors.white; // White background when unselected
                    },
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF2830F2)
                        : Colors.grey[300]!,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5), // 5px rounded borders
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),

              SizedBox(width: 12.w),

              // Second column: Title and value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w500, // Medium
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),

                    SizedBox(height: 4.h),

                    // Value
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF484848),
                        fontWeight: FontWeight.normal, // Regular
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Third column: Quantity and arrow
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quantity text
                  Text(
                    quantity,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w500, // Medium
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp, // Aproximadamente 20x20
                    color: const Color(0xFF000000),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
