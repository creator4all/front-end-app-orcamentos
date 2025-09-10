import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum TagType { pending, approved, notApproved, expired, archived }

class StatusTagWidget extends StatelessWidget {
  final TagType type;
  final String? customText;

  const StatusTagWidget({
    super.key,
    required this.type,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final tagData = _getTagData(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: tagData.backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        customText ?? tagData.label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
          color: tagData.textColor,
        ),
      ),
    );
  }

  _TagData _getTagData(TagType type) {
    switch (type) {
      case TagType.pending:
        return _TagData(
          textColor: const Color(0xFF0C498E),
          backgroundColor: const Color(0xFFE0F0FF),
          label: 'pendente',
        );
      case TagType.approved:
        return _TagData(
          textColor: const Color(0xFF0E5210),
          backgroundColor: const Color(0xFFB6FFAD),
          label: 'aprovado',
        );
      case TagType.notApproved:
        return _TagData(
          textColor: const Color(0xFF571414),
          backgroundColor: const Color(0xFFEEB8B8),
          label: 'não aprovado',
        );
      case TagType.expired:
        return _TagData(
          textColor: const Color(0xFF573502),
          backgroundColor: const Color(0xFFF1DAB7),
          label: 'expirado',
        );
      case TagType.archived:
        return _TagData(
          textColor: const Color(0xFFFFFFFF),
          backgroundColor: const Color(0xFF0E3562),
          label: 'arquivado',
        );
    }
  }
}

class _TagData {
  final Color textColor;
  final Color backgroundColor;
  final String label;

  _TagData({
    required this.textColor,
    required this.backgroundColor,
    required this.label,
  });
}
