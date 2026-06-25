import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_checkbox.dart';

import 'action_button.dart';

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
  final bool splitTapZones;

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
    this.splitTapZones = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final checkboxOnChanged =
        splitTapZones || isReadOnly || onCheckboxChanged == null
            ? null
            : (value) => onCheckboxChanged!(value);

    final leftZoneTap =
        splitTapZones && !isReadOnly && onCheckboxChanged != null
            ? () => onCheckboxChanged!(!isSelected)
            : null;

    final middleZoneTap = splitTapZones ? () {} : (onCardTap ?? onActionTap);
    final rightZoneTap = onCardTap ?? onActionTap;
    final actionButtonTap = splitTapZones ? null : onActionTap;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 0, bottom: 0),
      constraints: BoxConstraints(
        minHeight: 85.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFF117BBD) : Colors.grey[300]!,
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
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 73.h),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: leftZoneTap,
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomCheckbox(
                              value: isSelected,
                              checkedColor: const Color(0xFF117BBD),
                              uncheckedBorderColor: Colors.grey[300]!,
                              disabledColor: Colors.grey[400]!,
                              enabled: !isReadOnly,
                              onChanged: checkboxOnChanged,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: categoryIcon,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: middleZoneTap,
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
                                  title,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.15,
                                  ),
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
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
                      onTap: rightZoneTap,
                      child: Container(
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
                              onTap: actionButtonTap,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
