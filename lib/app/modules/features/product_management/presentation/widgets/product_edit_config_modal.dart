import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_info_dialog.dart';
import '../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/indicator_group_entity.dart';
import '../../domain/entities/product_config_entity.dart';

class ProductEditConfigModal extends StatefulWidget {
  final ProductConfigEntity product;
  final String categoryName;
  final String subcategoryName;
  final List<IndicatorGroupEntity> indicatorGroups;
  final Future<String?> Function(ProductConfigEntity) onSave;

  const ProductEditConfigModal({
    super.key,
    required this.product,
    required this.categoryName,
    required this.subcategoryName,
    required this.indicatorGroups,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required ProductConfigEntity product,
    required String categoryName,
    required String subcategoryName,
    required List<IndicatorGroupEntity> indicatorGroups,
    required Future<String?> Function(ProductConfigEntity) onSave,
  }) {
    return CustomModal.show(
      context: context,
      title: product.solucao,
      content: ProductEditConfigModal(
        product: product,
        categoryName: categoryName,
        subcategoryName: subcategoryName,
        indicatorGroups: indicatorGroups,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ProductEditConfigModal> createState() => _ProductEditConfigModalState();
}

class _ProductEditConfigModalState extends State<ProductEditConfigModal> {
  late TextEditingController _solucaoController;
  late TextEditingController _indicacaoController;
  late String _selectedTipo;
  static const _tipoOptions = ['mensal', 'anual', 'horas'];
  late TextEditingController _isbnController;
  late TextEditingController _percentController;
  late Map<String, bool> _indicadores;
  late bool _ativo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _solucaoController = TextEditingController(text: widget.product.solucao);
    _indicacaoController =
        TextEditingController(text: widget.product.indicacao);
    _selectedTipo = _tipoOptions.contains(widget.product.tipo.toLowerCase())
        ? widget.product.tipo.toLowerCase()
        : _tipoOptions.first;
    _isbnController = TextEditingController(text: widget.product.isbn ?? '');
    _percentController = TextEditingController(
      text: widget.product.percent?.toString() ?? '',
    );
    _indicadores = Map.from(widget.product.indicadores);
    _ativo = widget.product.ativo;
  }

  @override
  void dispose() {
    _solucaoController.dispose();
    _indicacaoController.dispose();

    _isbnController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReadOnlyField(
          'Grupo:',
          widget.categoryName,
          'Sub-grupo:',
          widget.subcategoryName,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'Solução:',
          controller: _solucaoController,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'Indicação:',
          controller: _indicacaoController,
        ),
        SizedBox(height: 16.h),
        _buildTipoDropdown(),
        if (widget.product.isLivro) ...[
          SizedBox(height: 16.h),
          _buildTextField(
            label: 'ISBN:',
            controller: _isbnController,
          ),
        ],
        if (widget.product.isServico) ...[
          SizedBox(height: 16.h),
          _buildTextField(
            label: 'Percentual de horas:',
            controller: _percentController,
            keyboardType: TextInputType.number,
          ),
        ],
        SizedBox(height: 16.h),
        _buildStatusDropdown(),
        SizedBox(height: 24.h),
        if (!widget.product.isServico) _buildIndicatorsSection(),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0028C1),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildReadOnlyField(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF484848)),
              children: [
                TextSpan(
                  text: '$label1 ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value1),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF484848)),
              children: [
                TextSpan(
                  text: '$label2 ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF484848),
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF0028C1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Marcado:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF484848),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.info_outline,
                size: 18.sp,
                color: const Color(0xFF0028C1),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButton<bool>(
            value: _ativo,
            isExpanded: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: true, child: Text('Ativo')),
              DropdownMenuItem(value: false, child: Text('Inativo')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _ativo = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.indicatorGroups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.nome,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF484848),
              ),
            ),
            SizedBox(height: 8.h),
            ...group.indicadores.map((indicator) {
              final isChecked = _indicadores[indicator.nome] ?? false;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildCustomCheckbox(
                  value: isChecked,
                  label: indicator.titulo,
                  onChanged: (value) {
                    setState(() {
                      _indicadores[indicator.nome] = value;
                    });
                  },
                ),
              );
            }),
            SizedBox(height: 16.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCustomCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
    bool isBold = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF0028C1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6.h),
              border: Border.all(
                color:
                    value ? const Color(0xFF0028C1) : const Color(0xFFD9D9D9),
                width: 1,
              ),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 14.sp,
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF484848),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF484848),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButton<String>(
            value: _selectedTipo,
            isExpanded: true,
            underline: const SizedBox(),
            items: _tipoOptions
                .map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(
                        tipo[0].toUpperCase() + tipo.substring(1),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTipo = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final updatedProduct = widget.product.copyWith(
      solucao: _solucaoController.text,
      indicacao: _indicacaoController.text,
      tipo: _selectedTipo,
      isbn: widget.product.isLivro ? _isbnController.text : null,
      percent: widget.product.isServico
          ? double.tryParse(_percentController.text)
          : null,
      ativo: _ativo,
      indicadores: _indicadores,
    );

    final error = await widget.onSave(updatedProduct);

    setState(() => _isSaving = false);

    if (error == null && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao salvar',
        message: error!,
      );
    }
  }
}
