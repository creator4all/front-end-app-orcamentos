import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/custom_modal.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../stores/budget_config_store.dart';
import 'product_info_modal.dart';
import 'product_item_card.dart';

/// Modal para exibir os produtos de uma subcategoria
///
/// Permite ao usuário:
/// - Visualizar todos os produtos da subcategoria
/// - Selecionar/desselecionar produtos
/// - Ver detalhes de cada produto (ícone info)
class SubcategoryProductsModal extends StatelessWidget {
  /// ID da categoria
  final int categoryId;

  /// ID da subcategoria
  final int subcategoryId;

  /// Store a ser usada (pode ser BudgetConfigStore ou BudgetEditStore)
  final dynamic store;

  const SubcategoryProductsModal({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    this.store,
  });

  /// Mostra a modal usando showModalBottomSheet
  static Future<void> show({
    required BuildContext context,
    required SubcategoryEntity subcategory,
    required int categoryId,
    dynamic store,
  }) {
    return CustomModal.show(
      context: context,
      title: subcategory.nome,
      content: SubcategoryProductsModal(
        categoryId: categoryId,
        subcategoryId: subcategory.id,
        store: store,
      ),
    );
  }

  void _handleInfoTap(BuildContext context, ProductEntity product) {
    // Abre modal de informações do produto
    ProductInfoModal.show(
      context: context,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      productId: product.id,
      store: store, // Passa a mesma store
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usa a store passada ou busca do Modular como fallback
    final storeInstance = store ?? Modular.get<BudgetConfigStore>();

    return Observer(
      builder: (_) {
        // Busca a subcategoria atualizada da store
        final category = storeInstance.categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => throw Exception('Categoria não encontrada'),
        );

        final subcategory = category.subcategorias.firstWhere(
          (s) => s.id == subcategoryId,
          orElse: () => throw Exception('Subcategoria não encontrada'),
        );

        print(
            '🔍 [SubcategoryProductsModal] Subcategoria: ${subcategory.nome}');
        print('   📦 Total produtos: ${subcategory.produtos.length}');
        print('   ✅ Produtos ativos: ${subcategory.activeProdutos.length}');
        print(
            '   📊 Produtos selecionados: ${subcategory.selectedProdutos.length}');

        final activeProducts = subcategory.activeProdutos;

        // Se não houver produtos ativos
        if (activeProducts.isEmpty) {
          print('   ⚠️ LISTA VAZIA - Nenhum produto ativo encontrado!');
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Text(
                'Nenhum produto disponível',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }

        // Lista de produtos + botão salvar
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lista de produtos
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeProducts.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final product = activeProducts[index];

                return ProductItemCard(
                  product: product,
                  onToggle: (isSelected) {
                    storeInstance.toggleProduct(product.id, isSelected);
                  },
                  onInfoTap: () => _handleInfoTap(context, product),
                );
              },
            ),

            SizedBox(height: 24.h),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
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
