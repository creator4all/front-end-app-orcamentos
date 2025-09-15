import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Technology item component for modals.
///
/// Features:
/// - Rectangle container with max width and height up to 70.h
/// - Rounded borders (10px) with color #2830F2
/// - White background
/// - Row layout with checkbox, item details, and action icon
class TechnologyItem extends StatelessWidget {
  final String itemName;
  final String text1;
  final String text2;
  final String text3;
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onActionTap;

  const TechnologyItem({
    super.key,
    required this.itemName,
    required this.text1,
    required this.text2,
    required this.text3,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Max width depending on page
      constraints: BoxConstraints(
        maxHeight: 70.h,
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFF2830F2) : const Color(0xFFD9D9D9),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // First item: Column with centered checkbox
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
              ],
            ),

            SizedBox(width: 12.w),

            // Second item: Column with item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // First row: Item name
                  Text(
                    itemName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF484848),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  SizedBox(height: 4.h),

                  // Second row: 3 texts (can wrap to next line if too large)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 2.h,
                    children: [
                      Text(
                        text1,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        text2,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        text3,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Third item: Action icon
            GestureDetector(
              onTap: onActionTap,
              child: Icon(
                Icons.info_outline,
                size: 20.sp,
                color: const Color(0xFF2830F2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
