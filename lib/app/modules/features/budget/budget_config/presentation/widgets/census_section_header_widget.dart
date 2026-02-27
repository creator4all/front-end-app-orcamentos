import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget para exibir o título de uma seção do censo escolar
/// Estilizado como texto sublinhado em azul
class CensusSectionHeaderWidget extends StatelessWidget {
  final String title;

  const CensusSectionHeaderWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF117BBD),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF117BBD),
        ),
      ),
    );
  }
}
