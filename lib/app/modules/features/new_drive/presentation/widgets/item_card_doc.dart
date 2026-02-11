import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/drive_item.dart';
import 'authenticated_thumbnail.dart';

class DriveItemColors {
  final Color backgroundColor;
  final Color iconColor;

  const DriveItemColors({
    required this.backgroundColor,
    required this.iconColor,
  });

  static const document = DriveItemColors(
    backgroundColor: Color(0xFF2830F2),
    iconColor: Color(0xFFEBEDFF),
  );

  static const video = DriveItemColors(
    backgroundColor: Color(0xFF800019),
    iconColor: Color(0xFFFFEBEF),
  );

  static const image = DriveItemColors(
    backgroundColor: Color(0xFF103323),
    iconColor: Color(0xFFEFFAF5),
  );

  static const folder = DriveItemColors(
    backgroundColor: Color(0xFF402F00),
    iconColor: Color(0xFFFFD932),
  );

  static DriveItemColors fromType(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return document;
      case DriveItemType.video:
        return video;
      case DriveItemType.image:
        return image;
      case DriveItemType.folder:
        return folder;
    }
  }
}

class ItemCardDoc extends StatelessWidget {
  final DriveItem item;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onLongPress;
  final bool showDate;
  final bool showMenu;
  final int? maxNameLines;

  const ItemCardDoc({
    super.key,
    required this.item,
    this.onTap,
    this.onMenuTap,
    this.onLongPress,
    this.showDate = true,
    this.showMenu = true,
    this.maxNameLines,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = item.type == DriveItemType.video &&
        item.thumbnailUrl != null &&
        item.thumbnailUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFBCC1CA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: hasImage ? _buildImageVariant() : _buildIconVariant(),
      ),
    );
  }

  Widget _buildIconVariant() {
    final colors = DriveItemColors.fromType(item.type);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForType(item.type),
              color: colors.iconColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF171A1F),
                  ),
                  maxLines: maxNameLines,
                  overflow: maxNameLines != null ? TextOverflow.ellipsis : null,
                ),
                SizedBox(height: 4.h),
                _buildMetadataRow(),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (showMenu)
            GestureDetector(
              onTap: onMenuTap,
              child: Icon(
                Icons.more_horiz,
                color: const Color(0xFF565E6C),
                size: 20.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageVariant() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AuthenticatedThumbnail(
                  url: item.thumbnailUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (showMenu)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onMenuTap,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF171A1F),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              _buildMetadataRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow() {
    final formattedDate = item.getFormattedDate();
    return Text(
      showDate ? '${item.size} • $formattedDate' : item.size,
      style: TextStyle(
        fontSize: 12.sp,
        color: const Color(0xFF565E6C),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
