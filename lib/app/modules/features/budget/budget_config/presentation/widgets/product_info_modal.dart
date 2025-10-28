import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/product_entity.dart';
import '../stores/budget_config_store.dart';
import 'indicadores_etapa_section.dart';

/// Modal de informações detalhadas do produto
///
/// Exibe:
/// - Informações básicas (Grupo, Sub-grupo, Solução, etc.)
/// - Indicadores de etapa agrupados com checkboxes
/// - Botão Salvar
class ProductInfoModal extends StatefulWidget {
  /// ID da categoria
  final int categoryId;

  /// ID da subcategoria
  final int subcategoryId;

  /// ID do produto
  final int productId;

  /// Store a ser usada (pode ser BudgetConfigStore ou BudgetEditStore)
  final dynamic store;

  const ProductInfoModal({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    required this.productId,
    this.store,
  });

  /// Mostra a modal
  static Future<void> show({
    required BuildContext context,
    required int categoryId,
    required int subcategoryId,
    required int productId,
    dynamic store,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Informações',
      content: ProductInfoModal(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        productId: productId,
        store: store,
      ),
    );
  }

  @override
  State<ProductInfoModal> createState() => _ProductInfoModalState();
}

class _ProductInfoModalState extends State<ProductInfoModal> {
  /// Formata valor para padrão brasileiro
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Salva as alterações (fecha a modal)
  void _handleSave() {
    // Fechar modal
    Navigator.pop(context);
  }

  /// Constrói linha de informação
  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
              fontFamily: 'Roboto',
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF000000),
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói container com informações do produto
  Widget _buildProductInfo(
    ProductEntity product,
    String categoryName,
    String subcategoryName,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Grupo', capitalizeFirstLetter(categoryName)),
          SizedBox(height: 8.h),
          _buildInfoRow('Sub-grupo', capitalizeFirstLetter(subcategoryName)),
          SizedBox(height: 8.h),
          _buildInfoRow('Solução', capitalizeFirstLetter(product.solucao)),
          SizedBox(height: 8.h),
          _buildInfoRow('Indicação', product.indicacao),
          SizedBox(height: 8.h),
          _buildInfoRow('Tipo', product.tipo),
          SizedBox(height: 8.h),
          _buildInfoRow('Valor total', _formatCurrency(product.totalValue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeInstance = widget.store ?? Modular.get<BudgetConfigStore>();

    return Observer(
      builder: (_) {
        // Busca dados da store
        final category = storeInstance.categories.firstWhere(
          (c) => c.id == widget.categoryId,
          orElse: () => throw Exception('Categoria não encontrada'),
        );

        final subcategory = category.subcategorias.firstWhere(
          (s) => s.id == widget.subcategoryId,
          orElse: () => throw Exception('Subcategoria não encontrada'),
        );

        final product = subcategory.produtos.firstWhere(
          (p) => p.id == widget.productId,
          orElse: () => throw Exception('Produto não encontrado'),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção 1: Informações do Produto
            _buildProductInfo(product, category.nome, subcategory.nome),

            SizedBox(height: 24.h),

            // Seção 2: Indicadores de Etapa
            if (product.indicadoresEtapa.isNotEmpty) ...[
              IndicadoresEtapaSection(
                indicadores: product.indicadoresEtapa,
              ),
              SizedBox(height: 24.h),
            ],

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(
                  Icons.save,
                  color: Color(0xFFFFFFFF),
                ),
                label: Text(
                  'Salvar',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56B34A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}
