import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/drive_item.dart';
import 'item_card_doc.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final DriveItemType categoryType;
  final int itemCount;
  final String totalSize;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.categoryType,
    required this.itemCount,
    required this.totalSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DriveItemColors.fromType(categoryType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFBCC1CA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(categoryType),
                color: colors.iconColor,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF171A1F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$itemCount ${itemCount == 1 ? 'item' : 'itens'} • $totalSize',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF565E6C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return Icons.description;
      case DriveItemType.video:
        return Icons.play_circle_outline;
      case DriveItemType.image:
        return Icons.image;
      case DriveItemType.folder:
        return Icons.folder;
    }
  }
}
