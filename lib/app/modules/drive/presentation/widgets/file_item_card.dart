import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/models/file_item.dart';

class FileItemCard extends StatelessWidget {
  final FileItem file;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onOpenWith;
  final VoidCallback? onViewDetails;
  final bool isDownloading;
  final double? downloadProgress;

  const FileItemCard({
    super.key,
    required this.file,
    this.onTap,
    this.onDownload,
    this.onOpenWith,
    this.onViewDetails,
    this.isDownloading = false,
    this.downloadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Ícone do arquivo
              _buildFileIcon(),
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF484848),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),

                    // Informações adicionais
                    Row(
                      children: [
                        // Tipo/Tamanho
                        Text(
                          file.isFolder
                              ? file.fileExtension
                              : '${file.fileExtension} • ${file.fileSizeFormatted}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (file.uploaderName != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              file.uploaderName!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Data
                    Text(
                      _formatDate(file.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress indicator ou menu de ações
              if (isDownloading && downloadProgress != null)
                _buildDownloadProgress()
              else
                _buildActionsMenu(context),
            ],
          ),
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
    } else if (file.isPdf) {
      iconData = Icons.picture_as_pdf;
      iconColor = const Color(0xFFE53935);
    } else if (file.fileType.extension == 'DOCX' ||
        file.fileType.extension == 'DOC') {
      iconData = Icons.description;
      iconColor = const Color(0xFF1976D2);
    } else if (file.fileType.extension == 'XLSX' ||
        file.fileType.extension == 'XLS') {
      iconData = Icons.table_chart;
      iconColor = const Color(0xFF388E3C);
    } else if (file.fileType.extension == 'PPTX' ||
        file.fileType.extension == 'PPT') {
      iconData = Icons.slideshow;
      iconColor = const Color(0xFFD84315);
    } else if (file.isVideo) {
      iconData = Icons.video_library;
      iconColor = const Color(0xFF7B1FA2);
    } else if (file.isImage) {
      iconData = Icons.image;
      iconColor = const Color(0xFF00897B);
    } else if (file.isAudio) {
      iconData = Icons.audio_file;
      iconColor = const Color(0xFFF57C00);
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey[600]!;
    }

    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 28.sp,
      ),
    );
  }

  Widget _buildDownloadProgress() {
    return SizedBox(
      width: 40.w,
      height: 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: downloadProgress,
            strokeWidth: 3.w,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1C94DF)),
          ),
          Text(
            '${(downloadProgress! * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C94DF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
        size: 24.sp,
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            if (file.isMedia && onTap != null) {
              onTap!();
            }
            break;
          case 'download':
            if (onDownload != null) onDownload!();
            break;
          case 'open_with':
            if (onOpenWith != null) onOpenWith!();
            break;
          case 'details':
            if (onViewDetails != null) onViewDetails!();
            break;
          case 'open_folder':
            if (file.isFolder && onTap != null) onTap!();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        if (file.isFolder) {
          items.add(
            PopupMenuItem<String>(
              value: 'open_folder',
              child: Row(
                children: [
                  Icon(Icons.folder_open,
                      size: 20.sp, color: const Color(0xFF1C94DF)),
                  SizedBox(width: 12.w),
                  const Text('Abrir pasta'),
                ],
              ),
            ),
          );
        } else {
          if (file.isMedia) {
            items.add(
              PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility,
                        size: 20.sp, color: const Color(0xFF1C94DF)),
                    SizedBox(width: 12.w),
                    const Text('Visualizar'),
                  ],
                ),
              ),
            );
          }

          items.add(
            PopupMenuItem<String>(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download,
                      size: 20.sp, color: const Color(0xFF4CAF50)),
                  SizedBox(width: 12.w),
                  const Text('Baixar'),
                ],
              ),
            ),
          );

          if (file.isDocument) {
            items.add(
              PopupMenuItem<String>(
                value: 'open_with',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new,
                        size: 20.sp, color: const Color(0xFFFF9800)),
                    SizedBox(width: 12.w),
                    const Text('Abrir com...'),
                  ],
                ),
              ),
            );
          }
        }

        items.add(
          PopupMenuItem<String>(
            value: 'details',
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20.sp, color: Colors.grey[700]),
                SizedBox(width: 12.w),
                const Text('Detalhes'),
              ],
            ),
          ),
        );

        return items;
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje às ${DateFormat.Hm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Ontem às ${DateFormat.Hm().format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
