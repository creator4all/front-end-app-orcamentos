import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/file_model.dart';
import 'file_type_icon_widget.dart';
import 'shared_info_widget.dart';
import 'video_thumbnail_widget.dart';

class FileItemWidget extends StatelessWidget {
  final FileModel file;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const FileItemWidget({
    super.key,
    required this.file,
    this.onTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: file.canOpen ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 0.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFD9D9D9),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            // Thumbnail ou ícone
            if (file.type == FileType.mp4 && file.thumbnailUrl != null)
              VideoThumbnailWidget(thumbnailUrl: file.thumbnailUrl!)
            else if ((file.type == FileType.jpg || file.type == FileType.png) &&
                file.thumbnailUrl != null)
              Container(
                width: 60.w,
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  image: DecorationImage(
                    image: NetworkImage(file.thumbnailUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              FileTypeIconWidget(
                  type: file.type, size: file.isFolder ? 50 : 40),

            SizedBox(width: 12.w),

            // Informações do arquivo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do arquivo
                  Text(
                    file.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF484848),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Tipo e extensão ou número de itens (para pastas)
                  Text(
                    file.isFolder && file.itemCount != null
                        ? '${file.itemCount} ${file.itemCount == 1 ? 'item' : 'itens'}'
                        : file.extension,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF828282),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Informações de compartilhamento
                  SharedInfoWidget(
                    sharedDate: file.sharedDate,
                    sharedBy: file.sharedBy,
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Botão de download (apenas para arquivos)
            if (!file.isFolder)
              IconButton(
                onPressed: onDownload,
                icon: Icon(
                  Icons.download,
                  color: const Color(0xFF1C94DF),
                  size: 20.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
