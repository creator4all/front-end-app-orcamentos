import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/brl_currency_input_formatter.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import '../../../../../../shared/widgets/custom_info_dialog.dart';
import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/product_entity.dart';
import 'indicadores_etapa_section.dart';

class ProductInfoModal extends StatefulWidget {
  final ProductEntity Function() getProduct;
  final String Function() getCategoryName;
  final String Function() getSubcategoryName;
  final ValueChanged<double>? onValueChanged;
  final ValueChanged<double>? onQuantityChanged;
  final ValueChanged<int>? onIndicatorToggled;

  /// Define a quantidade manualmente (ativa o modo manual).
  final ValueChanged<double>? onManualQuantityChanged;

  /// Alterna entre quantidade manual (true) e cálculo por indicadores (false).
  final ValueChanged<bool>? onQuantityModeChanged;

  const ProductInfoModal({
    super.key,
    required this.getProduct,
    required this.getCategoryName,
    required this.getSubcategoryName,
    this.onValueChanged,
    this.onQuantityChanged,
    this.onIndicatorToggled,
    this.onManualQuantityChanged,
    this.onQuantityModeChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required ProductEntity Function() getProduct,
    required String Function() getCategoryName,
    required String Function() getSubcategoryName,
    ValueChanged<double>? onValueChanged,
    ValueChanged<double>? onQuantityChanged,
    ValueChanged<int>? onIndicatorToggled,
    ValueChanged<double>? onManualQuantityChanged,
    ValueChanged<bool>? onQuantityModeChanged,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Informações',
      content: ProductInfoModal(
        getProduct: getProduct,
        getCategoryName: getCategoryName,
        getSubcategoryName: getSubcategoryName,
        onValueChanged: onValueChanged,
        onQuantityChanged: onQuantityChanged,
        onIndicatorToggled: onIndicatorToggled,
        onManualQuantityChanged: onManualQuantityChanged,
        onQuantityModeChanged: onQuantityModeChanged,
      ),
    );
  }

  @override
  State<ProductInfoModal> createState() => _ProductInfoModalState();
}

class _ProductInfoModalState extends State<ProductInfoModal> {
  late final TextEditingController _valueController;
  late final TextEditingController _horasController;
  late final TextEditingController _quantidadeController;
  final FocusNode _quantidadeFocus = FocusNode();
  final FocusNode _valueFocus = FocusNode();
  final FocusNode _horasFocus = FocusNode();
  final GlobalKey _quantidadeFieldKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final product = widget.getProduct();
    _valueController = TextEditingController(
      text: CurrencyUtils.formatBRLNoSymbol(product.valor),
    );
    _horasController = TextEditingController(
      text: product.quantidade > 0 ? product.formattedQuantidade : '',
    );
    _quantidadeController = TextEditingController(
      text: product.quantidade > 0 ? product.formattedQuantidade : '',
    );
    _quantidadeFocus.addListener(_handleFieldFocus);
    _valueFocus.addListener(_handleFieldFocus);
    _horasFocus.addListener(_handleFieldFocus);
  }

  void _handleFieldFocus() {
    if (!_quantidadeFocus.hasFocus &&
        !_valueFocus.hasFocus &&
        !_horasFocus.hasFocus) {
      return;
    }

    // Aguarda a animação do teclado antes de rolar, para manter o campo focado
    // e o botão "Salvar" visíveis logo acima do teclado.
    Future.delayed(const Duration(milliseconds: 300), () {
      final keyContext = _saveButtonKey.currentContext;
      if (!mounted || keyContext == null || !keyContext.mounted) return;
      Scrollable.ensureVisible(
        keyContext,
        alignment: 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _horasController.dispose();
    _quantidadeController.dispose();
    _quantidadeFocus.removeListener(_handleFieldFocus);
    _quantidadeFocus.dispose();
    _valueFocus.removeListener(_handleFieldFocus);
    _valueFocus.dispose();
    _horasFocus.removeListener(_handleFieldFocus);
    _horasFocus.dispose();
    super.dispose();
  }

  bool _isServico(ProductEntity product) {
    final tipo = product.tipoProduto.toLowerCase();
    return tipo == 'servico' || tipo == 'serviço';
  }

  double? _parseValueInput() {
    final text = _valueController.text;
    if (text.isEmpty) return null;
    final value = BrlCurrencyInputFormatter.parseToDouble(text);
    return value > 0 ? value : null;
  }

  void _handleSave() {
    final product = widget.getProduct();

    final newValue = _parseValueInput();
    if (newValue != null) {
      widget.onValueChanged?.call(newValue);
    }

    if (_isServico(product)) {
      final horasText = _horasController.text;
      final horas = int.tryParse(horasText) ?? 0;
      if (horas > 0) {
        widget.onQuantityChanged?.call(horas.toDouble());
      }
    }

    Navigator.pop(context);
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

  Widget _buildProductInfo(
    ProductEntity product,
    String categoryName,
    String subcategoryName,
  ) {
    return Container(
      width: double.infinity,
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
          _buildInfoRow('Grupo', categoryName),
          SizedBox(height: 8.h),
          _buildInfoRow('Sub-grupo', subcategoryName),
          SizedBox(height: 8.h),
          _buildInfoRow('Solução', product.solucao),
          SizedBox(height: 8.h),
          _buildInfoRow('Indicação', product.indicacao),
          SizedBox(height: 8.h),
          _buildInfoRow('Tipo', product.tipo),
          SizedBox(height: 8.h),
          _buildInfoRow(
            'Valor total',
            CurrencyUtils.formatBRL(product.totalValue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final product = widget.getProduct();
        final categoryName = widget.getCategoryName();
        final subcategoryName = widget.getSubcategoryName();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductInfo(product, categoryName, subcategoryName),
            SizedBox(height: 24.h),
            if (_isServico(product)) ...[
              _buildHorasField(product),
              SizedBox(height: 24.h),
            ] else if (product.indicadoresEtapa.isNotEmpty) ...[
              IndicadoresEtapaSection(
                indicadores: product.indicadoresEtapa,
                enabled: !product.quantidadeManual,
                onToggle: (indicadorId, valor) {
                  widget.onIndicatorToggled?.call(indicadorId);
                },
                onBlockedTap: product.quantidadeManual
                    ? () => _showBlockedDialog(context)
                    : null,
              ),
              SizedBox(height: 8.h),
              _buildQuantidadeField(product),
              SizedBox(height: 24.h),
            ],
            _buildValueField(product),
            SizedBox(height: 24.h),
            _buildSaveButton(),
            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }

  Widget _buildHorasField(ProductEntity product) {
    if (_horasController.text.isEmpty && product.quantidade > 0) {
      _horasController.text = product.formattedQuantidade;
    }

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
                text: '${product.formattedQuantidade} hora(s)',
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
        TextField(
          controller: _horasController,
          focusNode: _horasFocus,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final horas = int.tryParse(value) ?? 0;
            if (horas > 0) {
              widget.onQuantityChanged?.call(horas.toDouble());
            }
          },
          decoration: InputDecoration(
            hintText: 'Insira a quantidade de horas',
            hintStyle: TextStyle(
              color: const Color(0xFF8C8C8C),
              fontSize: 14.sp,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
              borderSide: const BorderSide(color: Color(0xFF117BBD)),
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  void _showBlockedDialog(BuildContext context) {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.info,
      title: 'Quantidade definida manualmente',
      message:
          'Você digitou uma quantidade personalizada para este produto, por isso os itens de cálculo automático estão desativados.\n\nPara voltar a calcular a quantidade automaticamente pelos indicadores, toque no ícone de recarregar (↺) que aparece dentro do campo de quantidade.',
      buttonText: 'Entendi',
    );
  }

  Widget _buildQuantidadeField(ProductEntity product) {
    // Mantém o campo sincronizado com a quantidade atual quando não está em foco
    // (ex.: após recálculo), sem atrapalhar a digitação do usuário.
    if (!_quantidadeFocus.hasFocus) {
      final text = product.quantidade > 0 ? product.formattedQuantidade : '';
      if (_quantidadeController.text != text) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_quantidadeFocus.hasFocus) {
            _quantidadeController.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          }
        });
      }
    }

    final isReadOnly = widget.onManualQuantityChanged == null;

    return Column(
      key: _quantidadeFieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Quantidade: ',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: product.formattedQuantidade,
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
        TextField(
          controller: _quantidadeController,
          focusNode: _quantidadeFocus,
          keyboardType: TextInputType.number,
          readOnly: isReadOnly,
          onChanged: (value) {
            final qtd = double.tryParse(value) ?? 0;
            if (qtd > 0) {
              widget.onManualQuantityChanged?.call(qtd);
            }
          },
          decoration: InputDecoration(
            hintText: 'Insira a quantidade',
            hintStyle: TextStyle(
              color: const Color(0xFF8C8C8C),
              fontSize: 14.sp,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            suffixIcon:
                product.quantidadeManual && widget.onQuantityModeChanged != null
                    ? IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFF117BBD),
                        ),
                        tooltip: 'Voltar ao cálculo automático',
                        onPressed: () => widget.onQuantityModeChanged!(false),
                      )
                    : null,
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
              borderSide: const BorderSide(color: Color(0xFF117BBD)),
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildValueField(ProductEntity product) {
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
        TextField(
          controller: _valueController,
          focusNode: _valueFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [BrlCurrencyInputFormatter()],
          decoration: InputDecoration(
            hintText: 'Insira o novo valor',
            hintStyle: TextStyle(
              color: const Color(0xFF8C8C8C),
              fontSize: 14.sp,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
              borderSide: const BorderSide(color: Color(0xFF117BBD)),
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      key: _saveButtonKey,
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF56B34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Salvar',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
