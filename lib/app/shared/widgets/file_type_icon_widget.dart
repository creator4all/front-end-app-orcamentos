import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/file_model.dart';

class FileTypeIconWidget extends StatelessWidget {
  final FileType type;
  final double size;

  const FileTypeIconWidget({
    super.key,
    required this.type,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Icon(
        _getIcon(),
        color: Colors.white,
        size: (size * 0.6).sp,
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.docx:
      case FileType.xlsx:
      case FileType.pptx:
        return Icons.description;
      case FileType.mp4:
        return Icons.play_circle_filled;
      case FileType.jpg:
      case FileType.png:
        return Icons.image;
      case FileType.folder:
        return Icons.folder;
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case FileType.pdf:
        return const Color(0xFFDC2626); // Vermelho
      case FileType.docx:
        return const Color(0xFF2563EB); // Azul
      case FileType.xlsx:
        return const Color(0xFF16A34A); // Verde
      case FileType.pptx:
        return const Color(0xFFD97706); // Laranja
      case FileType.mp4:
        return const Color(0xFF7C3AED); // Roxo
      case FileType.jpg:
      case FileType.png:
        return const Color(0xFF0891B2); // Ciano
      case FileType.folder:
        return const Color(0xFFF59E0B); // Âmbar
    }
  }
}
