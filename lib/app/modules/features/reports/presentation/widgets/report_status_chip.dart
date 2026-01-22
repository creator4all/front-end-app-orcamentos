import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Chip de filtro de status com contagem.
///
/// Exibe um chip selecionável com o nome do status e a quantidade
/// de orçamentos nesse status.
class ReportStatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? textColor;
  final Color? selectedTextColor;

  const ReportStatusChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textColor,
    this.selectedTextColor,
  });

  /// Retorna as cores padrão baseadas no status
  static Map<String, Map<String, Color>> get statusColors => {
        'aprovado': {
          'background': const Color(0xFFB6FFAD),
          'text': const Color(0xFF0E5210),
        },
        'pendente': {
          'background': const Color(0xFFE0F0FF),
          'text': const Color(0xFF0C498E),
        },
        'expirado': {
          'background': const Color(0xFFF1DAB7),
          'text': const Color(0xFF573502),
        },
        'nao_aprovado': {
          'background': const Color(0xFFEEB8B8),
          'text': const Color(0xFF571414),
        },
        'arquivado': {
          'background': const Color(0xFF0E3562),
          'text': Colors.white,
        },
      };

  Color _getBackgroundColor() {
    if (isSelected) {
      return selectedBackgroundColor ??
          statusColors[label.toLowerCase()]?['text'] ??
          const Color(0xFF0E3562);
    }
    return backgroundColor ??
        statusColors[label.toLowerCase()]?['background'] ??
        const Color(0xFFF5F5F5);
  }

  Color _getTextColor() {
    if (isSelected) {
      return selectedTextColor ?? Colors.white;
    }
    return textColor ??
        statusColors[label.toLowerCase()]?['text'] ??
        const Color(0xFF484848);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? _getBackgroundColor()
                : _getBackgroundColor().withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatLabel(label),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: _getTextColor(),
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : _getTextColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(String label) {
    // Converter para formato legível
    switch (label.toLowerCase()) {
      case 'aprovado':
        return 'Aprovados';
      case 'pendente':
        return 'Pendentes';
      case 'expirado':
        return 'Expirados';
      case 'nao_aprovado':
        return 'Reprovados';
      case 'arquivado':
        return 'Arquivados';
      default:
        return label;
    }
  }
}
