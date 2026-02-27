import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/indicador_etapa_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../stores/budget_config_store.dart';
import 'indicadores_etapa_section.dart';

class ProductInfoModal extends StatefulWidget {
  final int? categoryId;
  final int? subcategoryId;
  final int? productId;
  final dynamic store;
  final ProductEntity? product;
  final VoidCallback? onSave;

  const ProductInfoModal({
    super.key,
    this.categoryId,
    this.subcategoryId,
    this.productId,
    this.store,
    this.product,
    this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    int? categoryId,
    int? subcategoryId,
    int? productId,
    dynamic store,
    ProductEntity? product,
    VoidCallback? onSave,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Informações',
      content: ProductInfoModal(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        productId: productId,
        store: store,
        product: product,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ProductInfoModal> createState() => _ProductInfoModalState();
}

class _ProductInfoModalState extends State<ProductInfoModal> {
  late TextEditingController _valueController;
  late TextEditingController _horasController;

  bool get _isStoreMode =>
      widget.categoryId != null &&
      widget.subcategoryId != null &&
      widget.productId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeValueController();
    });
  }

  void _initializeValueController() {
    setState(() {
      _valueController = TextEditingController();
      _horasController = TextEditingController();
    });
  }

  bool _isServico(ProductEntity product) {
    final tipo = product.tipoProduto.toLowerCase();
    return tipo == 'servico' || tipo == 'serviço';
  }

  void _handleSave() {
    if (_isStoreMode) {
      final storeInstance = widget.store ?? Modular.get<BudgetConfigStore>();

      String cleanValue =
          _valueController.text.replaceAll(RegExp(r'[^\d.,]'), '');
      cleanValue = cleanValue.replaceAll(',', '.');

      final newValue = double.tryParse(cleanValue);

      if (newValue != null) {
        storeInstance.updateProductValue(widget.productId!, newValue);
      }
    } else {
      widget.onSave?.call();
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
          _buildInfoRow(
              'Valor total', CurrencyUtils.formatBRL(product.totalValue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStoreMode && widget.product == null) {
      return const Center(child: Text('Erro: Produto não fornecido'));
    }

    if (_isStoreMode) {
      return _buildStoreContent();
    } else {
      return _buildStandaloneContent();
    }
  }

  Widget _buildStandaloneContent() {
    final product = widget.product!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductInfo(product, 'N/A', 'N/A'),
        SizedBox(height: 24.h),
        if (product.indicadoresEtapa.isNotEmpty) ...[
          IndicadoresEtapaSection(
            indicadores: product.indicadoresEtapa,
            onToggle: (indicadorId, valor) {
              setState(() {
                final index = product.indicadoresEtapa
                    .indexWhere((i) => i.produtoIndicadorId == indicadorId);
                if (index != -1) {
                  final oldInd = product.indicadoresEtapa[index];
                  final newInd = oldInd.copyWith(selecionado: valor);

                  final newList =
                      List<IndicadorEtapaEntity>.from(product.indicadoresEtapa);
                  newList[index] = newInd;
                }
              });
            },
          ),
          SizedBox(height: 24.h),
        ],
        _buildValueField(product),
        SizedBox(height: 24.h),
        _buildSaveButton(),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildStoreContent() {
    final storeInstance = widget.store ?? Modular.get<BudgetConfigStore>();

    return Observer(
      builder: (_) {
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
            _buildProductInfo(product, category.nome, subcategory.nome),
            SizedBox(height: 24.h),
            if (_isServico(product)) ...[
              _buildHorasField(product, storeInstance),
              SizedBox(height: 24.h),
            ] else if (product.indicadoresEtapa.isNotEmpty) ...[
              IndicadoresEtapaSection(
                indicadores: product.indicadoresEtapa,
                onToggle: (indicadorId, valor) {
                  storeInstance.toggleProductIndicator(product.id, indicadorId);
                },
              ),
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

  Widget _buildHorasField(ProductEntity product, dynamic storeInstance) {
    if (_horasController.text.isEmpty && product.quantidade > 0) {
      _horasController.text = product.quantidade.toString();
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
        TextField(
          controller: _horasController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final horas = int.tryParse(value) ?? 0;
            if (horas > 0) {
              storeInstance.updateProductQuantity(product.id, horas);
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
              borderSide: const BorderSide(color: Color(0xFF2830F2)),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              borderSide: const BorderSide(color: Color(0xFF2830F2)),
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
