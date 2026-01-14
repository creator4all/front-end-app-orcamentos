import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card para exibição de categorias e subcategorias
/// Design baseado na referência visual fornecida
class CategoryCardWidget extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const CategoryCardWidget({
    super.key,
    required this.name,
    required this.subtitle,
    this.icon = Icons.folder_outlined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF0028C1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: const Color(0xFFEBEDFF),
              ),
            ),

            SizedBox(width: 12.w),

            // Nome e subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF484848),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Seta
            Icon(
              Icons.chevron_right,
              size: 24.sp,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
