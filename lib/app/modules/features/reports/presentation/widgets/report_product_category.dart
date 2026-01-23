import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/utils/string_utils.dart';
import '../../../../../shared/widgets/action_button.dart';

/// Widget de categoria de produto para modo readonly (relatórios).
/// Clone EXATO do ProductCategory apenas com checkbox disabled (cinza).
class ReportProductCategory extends StatelessWidget {
  final Widget categoryIcon;
  final String title;
  final String value;
  final int selectedCount;
  final int totalCount;
  final bool isSelected;

  /// Optional tap handler for the entire card area (excluding checkbox).
  final VoidCallback? onCardTap;

  /// Optional tap handler for the trailing action area.
  final VoidCallback? onActionTap;

  const ReportProductCategory({
    super.key,
    required this.categoryIcon,
    required this.title,
    required this.value,
    required this.selectedCount,
    required this.totalCount,
    this.isSelected = false,
    this.onCardTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth transition
      curve: Curves.easeInOut,
      width: double.infinity, // full width
      padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 0, bottom: 0),
      constraints: BoxConstraints(
        maxHeight: 85.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF117BBD)
              : Colors.grey[300]!, // Animated border color
          width: 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 70.h, // Increased height to prevent overflow
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // First column: checkbox + icon (~20%)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Checkbox (DISABLED - gray color for readonly)
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: null, // Disabled - readonly mode
                            activeColor: Colors.grey[400], // Gray when selected
                            checkColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.grey[400]; // Gray when selected
                                }
                                return Colors
                                    .white; // White background when unselected
                              },
                            ),
                            side: BorderSide(
                              color: Colors.grey[400]!, // Gray border always
                              width: 2.0,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Category icon
                        Flexible(
                          child: categoryIcon,
                        ),
                      ],
                    ),
                  ),
                ),

                // Second column: title and value (~60-66%)
                Expanded(
                  flex: 7,
                  child: GestureDetector(
                    onTap: onCardTap ?? onActionTap,
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title (required)
                            Flexible(
                              child: Text(
                                capitalizeFirstLetter(title),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            // Value
                            Flexible(
                              child: Text(
                                value,
                                style: textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ), // Third column: selected count + action button (~20%)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onCardTap ?? onActionTap,
                    child: Container(
                      height: 70.h,
                      alignment: Alignment.bottomRight,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Selected count text
                          Padding(
                            padding: EdgeInsets.only(top: 8.h, right: 8.w),
                            child: Text(
                              '$selectedCount/$totalCount',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Action button (blue chevron - same as original)
                          ActionButton(
                            onTap: onActionTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ); // AnimatedContainer
  }
}
