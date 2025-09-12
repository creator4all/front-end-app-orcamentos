import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'action_button.dart';
import 'card_base.dart';

/// ProductCategory widget based on [CardBase].
///
/// Layout:
/// - Row with 3 columns (flex: 2, 7, 2) ~ 20%, 60-66%, 20%.
/// - Col 1: Row with checkbox + category icon.
/// - Col 2: Column with title and value.
/// - Col 3: Column with selected count text + ActionButton.
class ProductCategory extends StatelessWidget {
  final Widget categoryIcon;
  final String title;
  final String value;
  final int selectedCount;
  final int totalCount;
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;

  /// Optional tap handler for the trailing action area.
  final VoidCallback? onActionTap;

  const ProductCategory({
    super.key,
    required this.categoryIcon,
    required this.title,
    required this.value,
    required this.selectedCount,
    required this.totalCount,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CardBase(
      enableShadow: isSelected,
      enableBorder: isSelected,
      padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 0, bottom: 0),
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
                      // Checkbox
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: onCheckboxChanged,
                          activeColor: const Color(0xFF117BBD),
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFF117BBD);
                              }
                              return Colors.grey[200]; // Light grey when unselected
                            },
                          ),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF117BBD) : Colors.grey[300]!,
                            width: 2.0,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          title,
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

              // Third column: selected count + action button (~20%)
              Expanded(
                flex: 2,
                child: Container(
                  height: 70.h,
                  alignment: Alignment.bottomRight,
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
                      // Action button
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
      ],
    );
  }
}
