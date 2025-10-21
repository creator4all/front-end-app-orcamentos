import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'action_button.dart';

/// Um componente base reutilizável para cards com layout flexível.
///
/// Estrutura:
/// - Row com 3 colunas (flex: 2, 7, 2) ~ 20%, 60-66%, 20%.
/// - Col 1: Widget customizável (checkbox + ícone, ou apenas ícone, etc)
/// - Col 2: Widget customizável (coluna de textos, etc)
/// - Col 3: Widget customizável para contador + ActionButton
class CardLayout extends StatelessWidget {
  /// Widget da primeira coluna (~20% da largura)
  final Widget? firstColumn;

  /// Widget da segunda coluna (~60-66% da largura)
  final Widget? secondColumn;

  /// Widget da terceira coluna (~20% da largura) acima do ActionButton
  final Widget? thirdColumnTop;

  /// Se deve mostrar o ActionButton
  final bool showActionButton;

  /// Callback do ActionButton
  final VoidCallback? onActionTap;

  /// Se deve exibir checkbox na primeira coluna
  final bool showCheckbox;

  /// Valor do checkbox
  final bool isChecked;

  /// Callback de mudança do checkbox
  final ValueChanged<bool?>? onCheckboxChanged;

  /// Ícone da primeira coluna (após checkbox se houver)
  final Widget? icon;

  /// Se deve exibir borda
  final bool showBorder;

  /// Cor da borda (quando showBorder = true)
  final Color borderColor;

  /// Se deve exibir drop-shadow
  final bool showShadow;

  /// Cor do shadow
  final Color shadowColor;

  /// Cor de fundo do card
  final Color backgroundColor;

  /// Border radius do card
  final double borderRadius;

  /// Altura máxima do card
  final double maxHeight;

  /// Padding do card
  final EdgeInsets padding;

  const CardLayout({
    super.key,
    this.firstColumn,
    this.secondColumn,
    this.thirdColumnTop,
    this.showActionButton = true,
    this.onActionTap,
    this.showCheckbox = true,
    this.isChecked = false,
    this.onCheckboxChanged,
    this.icon,
    this.showBorder = true,
    this.borderColor = const Color(0xFFE0E0E0),
    this.showShadow = false,
    this.shadowColor = const Color(0xFF000000),
    this.backgroundColor = Colors.white,
    this.borderRadius = 10,
    this.maxHeight = 85,
    this.padding =
        const EdgeInsets.only(left: 12, top: 12, right: 0, bottom: 0),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: padding,
      constraints: BoxConstraints(maxHeight: maxHeight.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: borderColor, width: 1.0) : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: SizedBox(
        height: 70.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Primeira coluna: checkbox + ícone (~20%)
            if (firstColumn != null || showCheckbox || icon != null)
              Expanded(
                flex: showCheckbox ? 2 : 1,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: showCheckbox ? 12.w : 0,
                    bottom: 12.h,
                  ),
                  child: firstColumn ??
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Checkbox
                          if (showCheckbox)
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: Checkbox(
                                value: isChecked,
                                onChanged: onCheckboxChanged,
                                activeColor: const Color(0xFF117BBD),
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return const Color(0xFF117BBD);
                                    }
                                    return Colors.white;
                                  },
                                ),
                                side: BorderSide(
                                  color: isChecked
                                      ? const Color(0xFF117BBD)
                                      : Colors.grey[300]!,
                                  width: 2.0,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          if (showCheckbox && icon != null)
                            SizedBox(width: 8.w),
                          // Ícone
                          if (icon != null)
                            Flexible(
                              child: icon!,
                            ),
                        ],
                      ),
                ),
              ),

            // Segunda coluna: conteúdo customizável (~60-66%)
            if (secondColumn != null)
              Expanded(
                flex: showCheckbox ? 7 : 8,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                  child: secondColumn!,
                ),
              ),

            // Terceira coluna: contador + ActionButton (~20%)
            if (thirdColumnTop != null || showActionButton)
              Expanded(
                flex: 2,
                child: Container(
                  height: 70.h,
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Widget customizável da terceira coluna (topo)
                      if (thirdColumnTop != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h, right: 8.w),
                          child: thirdColumnTop!,
                        ),
                      // ActionButton (fundo)
                      if (showActionButton)
                        ActionButton(
                          onTap: onActionTap,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
