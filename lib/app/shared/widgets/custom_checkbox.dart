import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCheckbox extends StatelessWidget {
  /// Se o checkbox está marcado
  final bool value;

  /// Callback quando o estado muda
  final ValueChanged<bool>? onChanged;

  final double size;

  final Color? checkedColor;

  final Color? uncheckedBorderColor;

  final Color? disabledColor;

  /// Controla a aparência habilitada/desabilitada do checkbox.
  ///
  /// Quando o toque é tratado por um widget externo (ex.: zonas de toque do
  /// card), `onChanged` é nulo mas o checkbox ainda deve parecer habilitado.
  /// Se nulo, a aparência segue `onChanged != null`.
  final bool? enabled;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 24,
    this.checkedColor,
    this.disabledColor,
    this.uncheckedBorderColor,
    this.enabled,
  });

  static const _defaultCheckedColor = Color(0xFF117BBD);
  static const _defaultDisabledColor = Color(0xFFBDBDBD);
  static const _defaultUncheckedBorderColor = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    final enabled = this.enabled ?? (onChanged != null);

    final effectiveCheckedColor = checkedColor ?? _defaultCheckedColor;
    final effectiveDisabledColor = disabledColor ?? _defaultDisabledColor;
    final effectiveUncheckedBorderColor =
        uncheckedBorderColor ?? _defaultUncheckedBorderColor;

    final fillColor = value
        ? enabled
            ? effectiveCheckedColor
            : effectiveDisabledColor
        : Colors.white;

    final borderColor = enabled
        ? value
            ? effectiveCheckedColor
            : effectiveUncheckedBorderColor
        : effectiveDisabledColor;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Container(
        width: size.w,
        height: size.h,
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: value
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: (size * 0.75).sp,
              )
            : null,
      ),
    );
  }
}
