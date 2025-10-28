import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/custom_checkbox.dart';
import '../../domain/entities/product_entity.dart';

/// Card de produto individual para seleção em orçamento
///
/// Layout:
/// - Row com checkbox + informações + ícone info
/// - Checkbox customizado (17x17)
/// - Nome do produto
/// - Qtde, Preço unitário, Valor total
/// - Ícone de informação (22x22)
///
/// Estados visuais:
/// - Selecionado: borda azul (#2830F2)
/// - Não selecionado: borda cinza (#D9D9D9)
class ProductItemCard extends StatelessWidget {
  /// Produto a ser exibido
  final ProductEntity product;

  /// Callback quando o checkbox é clicado
  final ValueChanged<bool>? onToggle;

  /// Callback quando o ícone de info é clicado
  final VoidCallback? onInfoTap;

  const ProductItemCard({
    super.key,
    required this.product,
    this.onToggle,
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
          // Checkbox
          CustomCheckbox(
            value: isSelected,
            onChanged: onToggle,
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
