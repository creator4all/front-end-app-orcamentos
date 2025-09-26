import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../modules/budget/presentation/stores/product_store.dart';
import 'custom_modal.dart';
import 'product_info_modal.dart';
import 'technology_item.dart';

class TechnologyProductsModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required int subcategoriaId,
    required String title,
  }) {
    final prodStore = Modular.get<ProductStore>();
    if (prodStore.lastSubcategoriaId != subcategoriaId &&
        !prodStore.isLoading) {
      // Make sure we're fetching products with the correct subcategory ID
      prodStore.fetchProdutos(subcategoriaId);
    }

    return CustomModal.show<T>(
      context: context,
      title: title,
      content: Observer(
        builder: (_) {
          if (prodStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prodStore.error != null) {
            return Text(
              'Erro: ${prodStore.error}',
              style: const TextStyle(color: Colors.red),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter products to ensure we only show products from the current subcategory
              ...prodStore.produtos
                  .where((p) => p.subcategoriaId == subcategoriaId)
                  .map((p) {
                final unitValue = p.valor != null
                    ? 'R\$ ${p.valor!.toStringAsFixed(2)}'
                    : '—';
                final selected = prodStore.isSelected(p.id);
                return TechnologyItem(
                  itemName: p.nome,
                  text1: unitValue,
                  text2: p.tipo ?? '',
                  text3: p.codigo ?? '',
                  isSelected: selected,
                  onCheckboxChanged: (v) {
                    prodStore.setSelected(p.id, v ?? false);
                  },
                  onActionTap: () {
                    ProductInfoModal.show(
                      context: context,
                      productInfo: {
                        'Grupo': 'Tecnologias',
                        'Sub-grupo': title,
                        'Solução': p.nome,
                        'Indicação': p.indicacao ?? '—',
                        'Tipo': p.tipo ?? '—',
                        'Valor Total': unitValue,
                      },
                      checkboxGroups: const [],
                      unitValue: unitValue,
                      onSave: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title salvos com sucesso!'),
                            backgroundColor: const Color(0xFF56B34A),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$title salvos com sucesso!'),
                        backgroundColor: const Color(0xFF56B34A),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF56B34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.save,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
