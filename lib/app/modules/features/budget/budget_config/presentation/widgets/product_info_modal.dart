import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../shared/widgets/custom_checkbox.dart';
import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/product_entity.dart';
import '../stores/budget_config_store.dart';

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

  const ProductInfoModal({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    required this.productId,
  });

  /// Mostra a modal
  static Future<void> show({
    required BuildContext context,
    required int categoryId,
    required int subcategoryId,
    required int productId,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Informações',
      content: ProductInfoModal(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        productId: productId,
      ),
    );
  }

  @override
  State<ProductInfoModal> createState() => _ProductInfoModalState();
}

class _ProductInfoModalState extends State<ProductInfoModal> {
  // Mapa para armazenar indicadores selecionados
  // Key: grupo, Value: lista de indicadores selecionados
  final Map<String, List<String>> _selectedIndicators = {};

  @override
  void initState() {
    super.initState();
    // Inicializar indicadores selecionados do produto
    _initializeSelectedIndicators();
  }

  void _initializeSelectedIndicators() {
    // TODO: Carregar indicadores já selecionados do produto
    // Por enquanto, inicializa vazio
  }

  /// Formata valor para padrão brasileiro
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Verifica se um indicador está selecionado
  bool _isIndicatorSelected(String group, String indicator) {
    return _selectedIndicators[group]?.contains(indicator) ?? false;
  }

  /// Alterna seleção de um indicador
  void _toggleIndicator(String group, String indicator, bool selected) {
    setState(() {
      if (selected) {
        // Adiciona o indicador
        if (_selectedIndicators[group] == null) {
          _selectedIndicators[group] = [];
        }
        if (!_selectedIndicators[group]!.contains(indicator)) {
          _selectedIndicators[group]!.add(indicator);
        }
      } else {
        // Remove o indicador
        _selectedIndicators[group]?.remove(indicator);
        // Remove o grupo se estiver vazio
        if (_selectedIndicators[group]?.isEmpty ?? false) {
          _selectedIndicators.remove(group);
        }
      }
    });
  }

  /// Salva as alterações
  void _handleSave() {
    final store = Modular.get<BudgetConfigStore>();

    // Salvar indicadores selecionados
    store.updateProductIndicators(widget.productId, _selectedIndicators);

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
          _buildInfoRow('Valor total', _formatCurrency(product.totalValue)),
        ],
      ),
    );
  }

  /// Constrói grupo de indicadores
  Widget _buildIndicatorGroup(String groupName, List<dynamic> indicators) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título do grupo
        Text(
          groupName,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF000000),
          ),
        ),
        SizedBox(height: 8.h),

        // Lista de indicadores
        ...indicators.map((indicator) {
          final indicatorName = indicator.toString();
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                CustomCheckbox(
                  value: _isIndicatorSelected(groupName, indicatorName),
                  onChanged: (value) {
                    _toggleIndicator(groupName, indicatorName, value);
                  },
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    indicatorName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        SizedBox(height: 16.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = Modular.get<BudgetConfigStore>();

    return Observer(
      builder: (_) {
        // Busca dados da store
        final category = store.categories.firstWhere(
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
              // Parsear e exibir indicadores agrupados
              ...(() {
                final List<Widget> indicatorWidgets = [];

                for (var indicatorGroup in product.indicadoresEtapa) {
                  if (indicatorGroup is Map) {
                    final groupName =
                        indicatorGroup['grupo']?.toString() ?? 'Sem grupo';
                    final itens = indicatorGroup['itens'] as List? ?? [];

                    if (itens.isNotEmpty) {
                      indicatorWidgets
                          .add(_buildIndicatorGroup(groupName, itens));
                    }
                  }
                }

                return indicatorWidgets;
              })(),
            ],

            SizedBox(height: 24.h),

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
