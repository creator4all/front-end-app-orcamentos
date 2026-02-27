import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Checkbox customizado reutilizável seguindo design system do projeto
///
/// Features:
/// - Tamanho: 17x17
/// - Cor checked: #2830F2 (azul)
/// - Cor unchecked: #D9D9D9 (cinza)
/// - Fundo branco
/// - Ícone check branco quando marcado
/// - Bordas arredondadas (5.r)
class CustomCheckbox extends StatelessWidget {
  /// Se o checkbox está marcado
  final bool value;

  /// Callback quando o estado muda
  final ValueChanged<bool>? onChanged;

  /// Tamanho do checkbox (padrão: 17)
  final double? size;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 17.0;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Container(
        width: effectiveSize.w,
        height: effectiveSize.h,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF2830F2) : Colors.white,
          border: Border.all(
            color: value ? const Color(0xFF2830F2) : const Color(0xFFD9D9D9),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: value
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: (effectiveSize * 0.8).sp,
              )
            : null,
      ),
    );
  }
}
