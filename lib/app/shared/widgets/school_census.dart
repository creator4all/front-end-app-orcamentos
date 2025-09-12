import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'action_button.dart';
import 'card_base.dart';

/// SchoolCensus widget based on [CardBase].
///
/// Layout:
/// - Row with 3 columns (flex: 2, 7, 2) ~ 20%, 60-66%, 20%.
/// - Col 1: leading icon (provided by parameter).
/// - Col 2: Row with up to 3 texts: [title], [info1?], [info2?].
/// - Col 3: Action container (max height 25.h),
///   top-left radius 15, bottom-right radius 10,
///   blue background (#117BBD) with a right arrow icon.
class SchoolCensus extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final String? info1;
  final String? info2;

  /// Optional tap handler for the trailing action area.
  final VoidCallback? onActionTap;

  const SchoolCensus({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.info1,
    this.info2,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CardBase(
      padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 0, bottom: 0),
      children: [
        SizedBox(
          height: 68.h, // Increased height to prevent overflow
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // First column: leading icon (~20%)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: leadingIcon,
                  ),
                ),
              ),

              // Second column: main content (~60-66%) stacked vertically
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
                      // Info 1 (optional)
                      if ((info1 ?? '').isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Flexible(
                          child: Text(
                            info1!,
                            style: textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                      // Info 2 (optional)
                      if ((info2 ?? '').isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Flexible(
                          child: Text(
                            info2!,
                            style: textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Third column: action container (~20%)
              Expanded(
                flex: 2,
                child: Container(
                  height: 68.h,
                  alignment: Alignment.bottomRight,
                  child: ActionButton(
                    onTap: onActionTap,
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
