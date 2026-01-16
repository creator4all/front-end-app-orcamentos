import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/drive_item.dart';
import 'item_card_doc.dart';

/// Card específico para exibir categorias de arquivos
/// Reutiliza a estrutura do ItemCardDoc mas simplificada
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
            // Ícone à esquerda
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(categoryType),
                color: colors.iconColor,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Textos à direita (2 linhas)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Linha 1: Nome da categoria
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
                  // Linha 2: Quantidade e tamanho
                  Text(
                    '$itemCount items • $totalSize',
                    style: TextStyle(
                      fontSize: 11.sp,
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

  /// Retorna o ícone apropriado para cada tipo de categoria
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
