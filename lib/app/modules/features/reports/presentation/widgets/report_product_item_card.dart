import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:multimidiaapp/app/modules/features/reports/presentation/widgets/readonly_checkbox.dart';

import '../../../../../shared/utils/string_utils.dart';
import '../../../budget/budget_config/domain/entities/product_entity.dart';

/// Card de produto individual para visualização em relatórios (READONLY)
///
/// Clone exato do ProductItemCard do budget_config, apenas sem callbacks de edição.
///
/// Layout:
/// - Row com checkbox visual + informações + ícone info
/// - Checkbox customizado visual (17x17) - apenas leitura
/// - Nome do produto
/// - Qtde, Preço unitário, Valor total
/// - Ícone de informação (22x22)
///
/// Estados visuais:
/// - Selecionado: borda azul (#2830F2)
/// - Não selecionado: borda cinza (#D9D9D9)
class ReportProductItemCard extends StatelessWidget {
  /// Produto a ser exibido
  final ProductEntity product;

  /// Callback quando o ícone de info é clicado
  final VoidCallback? onInfoTap;

  const ReportProductItemCard({
    super.key,
    required this.product,
    this.onInfoTap,
  });

  /// Formata valor para padrão brasileiro
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = product.selecionado;
    final borderColor =
        isSelected ? const Color(0xFF2830F2) : const Color(0xFFD9D9D9);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox visual readonly (cinza)
          ReadonlyCheckbox(
            value: isSelected,
          ),

          SizedBox(width: 12.w),

          // Informações do produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome do produto
                Text(
                  capitalizeFirstLetter(product.solucao),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF484848),
                  ),
                ),

                SizedBox(height: 4.h),

                // Qtde, Preço, Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qtde: ${product.quantidade}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    Text(
                      _formatCurrency(product.valor),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    Text(
                      _formatCurrency(product.totalValue),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Ícone de informação
          GestureDetector(
            onTap: onInfoTap,
            child: Icon(
              Icons.info_outline,
              size: 22.sp,
              color: const Color(0xFF2830F2),
            ),
          ),
        ],
      ),
    );
  }
}
