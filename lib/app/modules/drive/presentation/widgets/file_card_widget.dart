import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/models/file_item.dart';
import '../../domain/models/file_type_enum.dart';

class FileCardWidget extends StatelessWidget {
  final FileItem file;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final bool isDownloaded;

  const FileCardWidget({
    super.key,
    required this.file,
    this.onTap,
    this.onDownload,
    this.isDownloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linha superior: Ícone do arquivo + Botão de download
            Row(
              children: [
                // Ícone do tipo de arquivo
                _buildFileIcon(),
                const Spacer(),
                // Botão de download - apenas se já foi baixado
                if (!file.isFolder && isDownloaded)
                  Container(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.download_done,
                      size: 20.sp,
                      color: const Color(0xFF66BB6A),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            // Nome do arquivo/pasta
            Text(
              file.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF484848),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            // Linha inferior: Tipo • Tamanho
            Row(
              children: [
                // Tipo do item
                Text(
                  _getFileTypeLabel(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF828282),
                  ),
                ),
                // Ponto separador
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF828282),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Tamanho
                Expanded(
                  child: Text(
                    file.fileSizeFormatted,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF828282),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    IconData iconData;
    Color iconColor;

    if (file.isFolder) {
      iconData = Icons.folder;
      iconColor = const Color(0xFFFFA726);
    } else {
      final type = file.fileType;

      if (type == FileTypeEnum.docx) {
        iconData = Icons.description;
        iconColor = const Color(0xFF2B579A);
      } else if (type == FileTypeEnum.pptx) {
        iconData = Icons.slideshow;
        iconColor = const Color(0xFFD24726);
      } else if (type == FileTypeEnum.xlsx) {
        iconData = Icons.table_chart;
        iconColor = const Color(0xFF217346);
      } else if (type == FileTypeEnum.pdf) {
        iconData = Icons.picture_as_pdf;
        iconColor = const Color(0xFFD32F2F);
      } else if (file.isImage) {
        iconData = Icons.image;
        iconColor = const Color(0xFF66BB6A);
      } else if (file.isVideo) {
        iconData = Icons.video_library;
        iconColor = const Color(0xFFE91E63);
      } else if (file.isAudio) {
        iconData = Icons.audio_file;
        iconColor = const Color(0xFF9C27B0);
      } else if (file.isArchive) {
        iconData = Icons.folder_zip;
        iconColor = const Color(0xFF795548);
      } else {
        iconData = Icons.insert_drive_file;
        iconColor = const Color(0xFF757575);
      }
    }

    return Icon(
      iconData,
      size: 32.sp,
      color: iconColor,
    );
  }

  String _getFileTypeLabel() {
    if (file.isFolder) {
      return 'Pasta';
    }

    if (file.isDocument) {
      return 'Documento';
    } else if (file.isImage) {
      return 'Imagem';
    } else if (file.isVideo) {
      return 'Vídeo';
    } else if (file.isAudio) {
      return 'Áudio';
    } else if (file.isArchive) {
      return 'Compactado';
    } else {
      return 'Arquivo';
    }
  }
}
