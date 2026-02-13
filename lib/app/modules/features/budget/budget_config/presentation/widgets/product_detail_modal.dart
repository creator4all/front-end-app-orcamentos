import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product_entity.dart';
import 'indicadores_etapa_section.dart';

class ProductDetailModal extends StatefulWidget {
  final ProductEntity product;
  final Function(int quantity, String? observations)? onSave;

  const ProductDetailModal({
    super.key,
    required this.product,
    this.onSave,
  });

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  late int _quantity;
  late TextEditingController _observationsController;

  @override
  void initState() {
    super.initState();
    _quantity = widget.product.quantidade;
    _observationsController = TextEditingController(
      text: widget.product.observacoes ?? '',
    );
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Nome do Produto', widget.product.solucao),
                    _buildSection('Código', widget.product.codigo),
                    _buildSection('Indicação', widget.product.indicacao),
                    _buildSection('Tipo', widget.product.tipo),
                    _buildSection(
                        'Tipo de Produto', widget.product.tipoProduto),
                    _buildSection(
                        'Valor Unitário', widget.product.formattedValue),

                    SizedBox(height: 16.h),

                    _buildQuantitySection(),

                    SizedBox(height: 16.h),

                    _buildTotalSection(),

                    SizedBox(height: 16.h),

                    _buildObservationsSection(),

                    if (widget.product.indicadoresEtapa.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      IndicadoresEtapaSection(
                        indicadores: widget.product.indicadoresEtapa,
                      ),
                    ],

                    if (widget.product.hasAnyOverride) ...[
                      SizedBox(height: 16.h),
                      _buildOverrideInfo(),
                    ],
                  ],
                ),
              ),
            ),

            if (widget.onSave != null) _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF117BBD),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: Colors.white,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Detalhes do Produto',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantidade',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle, size: 32.sp),
              onPressed: _quantity > 1
                  ? () {
                      setState(() {
                        _quantity--;
                      });
                    }
                  : null,
              color: const Color(0xFF117BBD),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 60.w,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF117BBD),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            IconButton(
              icon: Icon(Icons.add_circle, size: 32.sp),
              onPressed: () {
                setState(() {
                  _quantity++;
                });
              },
              color: const Color(0xFF117BBD),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    final total = widget.product.valor * _quantity;
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF117BBD).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Valor Total:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            formatter.format(total),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF117BBD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _observationsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Adicione observações sobre este produto...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
      ],
    );
  }

  Widget _buildOverrideInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange[700],
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Este produto possui valores ou status customizados',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF117BBD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF117BBD),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onSave?.call(
                  _quantity,
                  _observationsController.text.isEmpty
                      ? null
                      : _observationsController.text,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF117BBD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
