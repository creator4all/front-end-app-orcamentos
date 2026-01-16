import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/drive_item.dart';
import 'authenticated_thumbnail.dart';

/// Configuração de cores para cada tipo de item
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

  /// Retorna as cores baseadas no tipo de item
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

/// Componente reutilizável para exibir itens do drive
///
/// Suporta duas variantes:
/// 1. Icon-based: Ícone colorido no topo esquerdo (padrão para documentos, imagens e pastas)
/// 2. Image-based: Thumbnail de imagem quando o item é um vídeo
class ItemCardDoc extends StatelessWidget {
  final String itemName;
  final String itemSize;
  final String itemDate;
  final DriveItemType itemType;
  final String? thumbnailUrl;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;
  final bool showDate; // Para cards de categoria que não mostram data

  const ItemCardDoc({
    super.key,
    required this.itemName,
    required this.itemSize,
    required this.itemDate,
    required this.itemType,
    this.thumbnailUrl,
    this.onTap,
    this.onMenuTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determina se deve usar variante com imagem (apenas para vídeos)
    final bool hasImage = itemType == DriveItemType.video &&
        thumbnailUrl != null &&
        thumbnailUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
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

  /// Variante com ícone colorido - layout horizontal compacto
  Widget _buildIconVariant() {
    final colors = DriveItemColors.fromType(itemType);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              _getIconForType(itemType),
              color: colors.iconColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          // Nome e metadata (expande para preencher espaço)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome do item (pode quebrar em múltiplas linhas)
                Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF171A1F),
                  ),
                ),
                SizedBox(height: 4.h),
                // Metadata row (tamanho e data)
                _buildMetadataRow(),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Menu de três pontos
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

  /// Variante com imagem de thumbnail
  Widget _buildImageVariant() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container da imagem com menu sobreposto
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              child: SizedBox(
                height: 62.h,
                width: double.infinity,
                child: AuthenticatedThumbnail(
                  url: thumbnailUrl!,
                  width: double.infinity,
                  height: 62.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Menu posicionado sobre a imagem
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
        // Informações do item
        Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nome do item
              Text(
                itemName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF171A1F),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              // Metadata row
              _buildMetadataRow(),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói a row de metadata (tamanho • data de compartilhamento ou tamanho • contagem)
  Widget _buildMetadataRow() {
    return Row(
      children: [
        // Tamanho do arquivo
        Text(
          itemSize,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF565E6C),
          ),
        ),
        if (showDate) ...[
          SizedBox(width: 8.w),
          // Separador circular
          Container(
            width: 4.w,
            height: 4.h,
            decoration: const BoxDecoration(
              color: Color(0xFFDEE1E6),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          // Data de compartilhamento
          Expanded(
            child: Text(
              itemDate,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF565E6C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// Retorna o ícone apropriado para cada tipo de item
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
