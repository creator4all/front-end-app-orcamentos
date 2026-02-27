import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'action_button.dart';
import 'card_base.dart';

class SchoolCensus extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final String? info1;
  final String? info2;

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

    return GestureDetector(
      onTap: () {
        onActionTap?.call();
      },
      child: CardBase(
        padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 0, bottom: 0),
        children: [
          SizedBox(
            height: 68.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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

                Expanded(
                  flex: 7,
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
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
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

                Expanded(
                  flex: 2,
                  child: Container(
                    height: 68.h,
                    alignment: Alignment.bottomRight,
                    child: ActionButton(
                      onTap: null,
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