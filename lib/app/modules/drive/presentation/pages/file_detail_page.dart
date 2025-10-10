import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/models/file_item.dart';

class FileDetailPage extends StatelessWidget {
  final FileItem file;

  const FileDetailPage({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Arquivo'),
        backgroundColor: const Color(0xFF0E3562),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone/Preview do arquivo
            Center(
              child: _buildFilePreview(),
            ),
            SizedBox(height: 24.h),

            // Nome do arquivo
            _buildInfoCard(
              title: 'Nome',
              content: file.name,
              icon: Icons.drive_file_rename_outline,
            ),
            SizedBox(height: 12.h),

            // Tipo
            _buildInfoCard(
              title: 'Tipo',
              content: file.fileType.displayName,
              icon: Icons.category,
            ),
            SizedBox(height: 12.h),

            // Tamanho
            if (!file.isFolder) ...[
              _buildInfoCard(
                title: 'Tamanho',
                content: file.fileSizeFormatted,
                icon: Icons.storage,
              ),
              SizedBox(height: 12.h),
            ],

            // Data de criação
            _buildInfoCard(
              title: 'Criado em',
              content: DateFormat('dd/MM/yyyy HH:mm').format(file.createdAt),
              icon: Icons.calendar_today,
            ),
            SizedBox(height: 12.h),

            // Enviado por
            if (file.uploaderName != null) ...[
              _buildInfoCard(
                title: 'Enviado por',
                content: file.uploaderName!,
                icon: Icons.person,
              ),
              SizedBox(height: 12.h),
            ],

            // Descrição
            if (file.description != null && file.description!.isNotEmpty) ...[
              _buildInfoCard(
                title: 'Descrição',
                content: file.description!,
                icon: Icons.description,
              ),
              SizedBox(height: 12.h),
            ],

            SizedBox(height: 24.h),

            // Ações
            if (!file.isFolder) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Trigger download
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Baixar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C94DF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  if (file.isDocument) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Trigger open with
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Abrir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E3562),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
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
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 64.sp,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1C94DF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1C94DF),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF484848),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
