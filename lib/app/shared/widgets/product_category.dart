import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/string_utils.dart';
import 'action_button.dart';
import 'card_base.dart';

class ProductCategory extends StatelessWidget {
  final Widget categoryIcon;
  final String title;
  final String value;
  final int selectedCount;
  final int totalCount;
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;
  final bool isReadOnly;
  final VoidCallback? onActionTap;
  final VoidCallback? onCardTap;

  const ProductCategory({
    super.key,
    required this.categoryIcon,
    required this.title,
    required this.value,
    required this.selectedCount,
    required this.totalCount,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.isReadOnly = false,
    this.onActionTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
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
              : Colors.grey[300]!,
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
            height: 70.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: isReadOnly ? null : onCheckboxChanged,
                            activeColor: isReadOnly
                                ? Colors.grey[400]
                                : const Color(0xFF117BBD),
                            checkColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return isReadOnly
                                      ? Colors.grey[400]
                                      : const Color(0xFF117BBD);
                                }
                                return Colors.white;
                              },
                            ),
                            side: BorderSide(
                              color: isReadOnly
                                  ? Colors.grey[400]!
                                  : isSelected
                                      ? const Color(0xFF117BBD)
                                      : Colors.grey[300]!,
                              width: 2.0,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: categoryIcon,
                        ),
                      ],
                    ),
                  ),
                ),

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
                ),
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
    );
  }
}