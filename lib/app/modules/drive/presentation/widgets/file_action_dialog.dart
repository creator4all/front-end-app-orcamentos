import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/models/file_item.dart';

class FileActionDialog extends StatelessWidget {
  final FileItem file;
  final String? sharedByName;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final bool isDownloaded;

  const FileActionDialog({
    super.key,
    required this.file,
    this.sharedByName,
    required this.onOpen,
    required this.onDownload,
    this.isDownloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do arquivo
            Row(
              children: [
                Icon(
                  _getFileIcon(),
                  size: 32.sp,
                  color: const Color(0xFF2830F2),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    file.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF484848),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Informações do arquivo
            _buildInfoRow('Tamanho', file.fileSizeFormatted),
            SizedBox(height: 8.h),
            _buildInfoRow('Tipo', _getFileTypeLabel()),

            if (sharedByName != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Compartilhado por', sharedByName!),
            ],

            SizedBox(height: 24.h),

            // Botões de ação
            Row(
              children: [
                // Botão Abrir
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpen();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2830F2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.open_in_new, size: 18.sp),
                    label: Text(
                      'Abrir',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Botão Baixar
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDownload();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2830F2),
                      side: const BorderSide(color: Color(0xFF2830F2)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(
                      isDownloaded ? Icons.check_circle : Icons.download,
                      size: 18.sp,
                    ),
                    label: Text(
                      isDownloaded ? 'Baixado' : 'Baixar',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF828282),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF484848),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon() {
    if (file.isPdf) return Icons.picture_as_pdf;
    if (file.isImage) return Icons.image;
    if (file.isVideo) return Icons.video_library;
    if (file.isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }

  String _getFileTypeLabel() {
    if (file.isPdf) return 'PDF';
    if (file.isImage) return 'Imagem';
    if (file.isVideo) return 'Vídeo';
    if (file.isDocument) return 'Documento';
    return 'Arquivo';
  }
}
