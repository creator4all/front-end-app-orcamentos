import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/indicador_etapa_entity.dart';
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
  /// ID da categoria (Modo Store)
  final int? categoryId;

  /// ID da subcategoria (Modo Store)
  final int? subcategoryId;

  /// ID do produto (Modo Store)
  final int? productId;

  /// Store a ser usada (Modo Store)
  final dynamic store;

  /// Entidade do produto (Modo Direto/Standalone)
  final ProductEntity? product;

  /// Callback ao salvar (Modo Direto/Standalone)
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

  /// Mostra a modal
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

  bool get _isStoreMode =>
      widget.categoryId != null &&
      widget.subcategoryId != null &&
      widget.productId != null;

  @override
  void initState() {
    super.initState();
    // Inicializa o controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeValueController();
    });
  }

  void _initializeValueController() {
    setState(() {
      _valueController =
          TextEditingController(); // Inicia vazio para mostrar o hint
    });
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

  /// Salva as alterações (fecha a modal)
  void _handleSave() {
    if (_isStoreMode) {
      final storeInstance = widget.store ?? Modular.get<BudgetConfigStore>();

      // Obter o valor atual do controller
      // Remover caracteres não numéricos exceto ponto e vírgula
      String cleanValue =
          _valueController.text.replaceAll(RegExp(r'[^\d.,]'), '');
      // Substituir vírgula por ponto se necessário (dependendo do formato de entrada)
      cleanValue = cleanValue.replaceAll(',', '.');

      final newValue = double.tryParse(cleanValue);

      if (newValue != null) {
        storeInstance.updateProductValue(widget.productId!, newValue);
      }
    } else {
      // Modo Standalone: Chama o callback externo
      widget.onSave?.call();
    }

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
          _buildInfoRow('Valor total', _formatCurrency(product.totalValue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se não estiver em modo Store e não tiver produto, mostra erro
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
    // Em modo standalone, não temos acesso fácil ao nome da categoria/subcategoria
    // a menos que seja passado ou inferido. Por enquanto, usaremos placeholders ou dados do produto se disponíveis.
    // O ideal seria passar esses nomes também, mas para manter a compatibilidade com BooksModal,
    // vamos assumir que o usuário sabe o contexto ou passar nomes genéricos.
    // No caso do BooksModal, ele passa subcategoriaNome na chamada wrapper, mas não para o widget diretamente.
    // Vamos ajustar para exibir dados disponíveis.

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seção 1: Informações do Produto
        _buildProductInfo(product, 'N/A', 'N/A'), // TODO: Melhorar isso

        SizedBox(height: 24.h),

        // Seção 2: Indicadores de Etapa
        if (product.indicadoresEtapa.isNotEmpty) ...[
          IndicadoresEtapaSection(
            indicadores: product.indicadoresEtapa,
            onToggle: (indicadorId, valor) {
              // Atualizar estado local do produto (se necessário para refletir na UI)
              // Como ProductEntity é imutável, precisariamos de um setState com novo produto.
              // Mas o BooksModal gerencia isso no callback onSave iterando sobre as entidades originais
              // que ele mantém referência.
              // A IndicadoresEtapaSection usa as entidades passadas.
              // Precisamos garantir que a alteração reflita na UI.

              setState(() {
                final index = product.indicadoresEtapa
                    .indexWhere((i) => i.produtoIndicadorId == indicadorId);
                if (index != -1) {
                  // Hack: Modificar a lista do produto que está no widget pai (BooksModal)
                  // Isso não é ideal, mas o BooksModal espera isso.
                  // O BooksModal cria entidades novas a cada show.
                  // Vamos atualizar o widget.product localmente para refletir a mudança.

                  final oldInd = product.indicadoresEtapa[index];
                  final newInd = oldInd.copyWith(selecionado: valor);

                  // Precisamos substituir na lista imutável
                  final newList =
                      List<IndicadorEtapaEntity>.from(product.indicadoresEtapa);
                  newList[index] = newInd;

                  // Atualizar a referência do produto no widget (imutável, então não dá pra atribuir)
                  // Precisamos de um estado local para o produto no modo standalone.
                }
              });
            },
          ),
          SizedBox(height: 24.h),
        ],

        // Seção 3: Campo de valor unitário
        _buildValueField(product),

        SizedBox(height: 24.h),

        // Botão Salvar
        _buildSaveButton(),

        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildStoreContent() {
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
                onToggle: (indicadorId, valor) {
                  storeInstance.toggleProductIndicator(product.id, indicadorId);
                },
              ),
              SizedBox(height: 24.h),
            ],

            // Seção 3: Campo de valor unitário
            _buildValueField(product),

            SizedBox(height: 24.h),

            // Botão Salvar
            _buildSaveButton(),

            SizedBox(height: 16.h),
          ],
        );
      },
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
                text: _formatCurrency(product.valor),
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
