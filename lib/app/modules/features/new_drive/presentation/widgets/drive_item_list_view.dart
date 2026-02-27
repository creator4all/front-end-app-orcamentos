import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/drive_item.dart';
import 'item_card_doc.dart';

class DriveItemListView extends StatelessWidget {
  final List<DriveItem> items;
  final void Function(DriveItem item) onItemTap;
  final void Function(DriveItem item)? onMenuTap;
  final bool showMenu;

  const DriveItemListView({
    super.key,
    required this.items,
    required this.onItemTap,
    this.onMenuTap,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      itemCount: items.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          children: [
            ItemCardDoc(
              item: item,
              showMenu: showMenu,
              onTap: () => onItemTap(item),
              onMenuTap: onMenuTap != null ? () => onMenuTap!(item) : null,
            ),
            if (index < items.length - 1) SizedBox(height: 12.h),
          ],
        );
      },
    );
  }
}
