import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/models/breadcrumb_item.dart';

class FileBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Function(int? folderId) onNavigate;

  const FileBreadcrumb({
    super.key,
    required this.items,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Home icon
            InkWell(
              onTap: () => onNavigate(null),
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: const Color(0xFF1C94DF),
                      size: 20.sp,
                    ),
                    if (items.length == 1 && items.first.isRoot) ...[
                      SizedBox(width: 6.w),
                      Text(
                        'Início',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF1C94DF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Breadcrumb items
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              final isRoot = item.isRoot;

              // Não mostrar item root se houver outros itens
              if (isRoot && items.length > 1) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  // Chevron separator
                  if (!isRoot || items.length == 1)
                    Icon(
                      Icons.chevron_right,
                      size: 16.sp,
                      color: Colors.grey[400],
                    ),

                  // Breadcrumb item
                  InkWell(
                    onTap: isLast ? null : () => onNavigate(item.id),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isLast
                              ? const Color(0xFF484848)
                              : const Color(0xFF1C94DF),
                          fontWeight:
                              isLast ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
