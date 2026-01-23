import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Checkbox readonly customizado para modo somente leitura (relatórios)
///
/// Features:
/// - Tamanho: 17x17
/// - Cor checked: #9E9E9E (cinza) - indica readonly
/// - Cor unchecked: #BDBDBD (cinza claro)
/// - Fundo branco
/// - Ícone check cinza quando marcado
/// - Bordas arredondadas (5.r)
/// - Não interativo (sempre disabled)
class ReadonlyCheckbox extends StatelessWidget {
  /// Se o checkbox está marcado
  final bool value;

  /// Tamanho do checkbox (padrão: 17)
  final double? size;

  const ReadonlyCheckbox({
    super.key,
    required this.value,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 17.0;

    return Container(
      width: effectiveSize.w,
      height: effectiveSize.h,
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF9E9E9E)
            : Colors.white, // Cinza quando checked
        border: Border.all(
          color: value
              ? const Color(0xFF9E9E9E)
              : const Color(0xFFBDBDBD), // Borda cinza
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
    );
  }
}
