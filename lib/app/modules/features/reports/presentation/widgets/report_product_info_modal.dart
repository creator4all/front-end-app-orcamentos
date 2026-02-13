import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import '../../../../../shared/utils/string_utils.dart';
import '../../../../../shared/widgets/custom_modal.dart';
import '../../../budget/budget_config/domain/entities/category_entity.dart';
import '../../../budget/budget_config/domain/entities/product_entity.dart';
import '../../../budget/budget_config/domain/entities/subcategory_entity.dart';
import '../../../budget/budget_config/presentation/widgets/indicadores_etapa_section.dart';

class ReportProductInfoModal extends StatelessWidget {
  final CategoryEntity category;

  final SubcategoryEntity subcategory;

  final ProductEntity product;

  const ReportProductInfoModal({
    super.key,
    required this.category,
    required this.subcategory,
    required this.product,
  });

  static Future<void> show({
    required BuildContext context,
    required CategoryEntity category,
    required SubcategoryEntity subcategory,
    required ProductEntity product,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Informações',
      content: ReportProductInfoModal(
        category: category,
        subcategory: subcategory,
        product: product,
      ),
    );
  }

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

  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Grupo', capitalizeFirstLetter(category.nome)),
          SizedBox(height: 8.h),
          _buildInfoRow('Sub-grupo', capitalizeFirstLetter(subcategory.nome)),
          SizedBox(height: 8.h),
          _buildInfoRow('Solução', capitalizeFirstLetter(product.solucao)),
          SizedBox(height: 8.h),
          _buildInfoRow('Indicação', product.indicacao),
          SizedBox(height: 8.h),
          _buildInfoRow('Tipo', product.tipo),
          SizedBox(height: 8.h),
          _buildInfoRow(
              'Valor total', CurrencyUtils.formatBRL(product.totalValue)),
        ],
      ),
    );
  }

  Widget _buildValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Valor Unitário: ',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: CurrencyUtils.formatBRL(product.valor),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            border: Border.all(color: const Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            CurrencyUtils.formatBRL(product.valor),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF484848),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Horas de Serviço: ',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: '${product.quantidade} hora(s)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            border: Border.all(color: const Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '${product.quantidade}',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF484848),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0E3562),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Fechar',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  bool _isServico() {
    final tipo = product.tipoProduto.toLowerCase();
    return tipo == 'servico' || tipo == 'serviço';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductInfo(),
        SizedBox(height: 24.h),
        if (_isServico()) ...[
          _buildHorasField(),
          SizedBox(height: 24.h),
        ] else if (product.indicadoresEtapa.isNotEmpty) ...[
          IndicadoresEtapaSection(
            indicadores: product.indicadoresEtapa,
            onToggle: null,
          ),
          SizedBox(height: 24.h),
        ],
        _buildValueField(),
        SizedBox(height: 24.h),
        _buildCloseButton(context),
        SizedBox(height: 16.h),
      ],
    );
  }
}
