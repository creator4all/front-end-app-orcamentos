import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../modules/budget/presentation/stores/subcategory_store.dart';
import '../../modules/budget/presentation/stores/product_store.dart';
import 'book_item.dart';
import 'custom_modal.dart';
import 'product_info_modal.dart';
import 'technology_item.dart';

class BooksModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required int categoriaId,
  }) {
    final subStore = Modular.get<SubcategoryStore>();
    if (subStore.lastCategoriaId != categoriaId && !subStore.isLoading) {
      subStore.fetchSubcategorias(categoriaId);
    }

    return CustomModal.show<T>(
      context: context,
      title: 'Livros',
      content: Observer(
        builder: (_) {
          if (subStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (subStore.error != null) {
            return Text(
              'Erro: ${subStore.error}',
              style: const TextStyle(color: Colors.red),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...subStore.subcategorias.map((sub) {
                return BookItem(
                  title: sub.nome,
                  text1: '',
                  text2: '',
                  text3: '',
                  isSelected: false,
                  onCheckboxChanged: (_) {},
                  onTap: () => showBookProducts(
                    context: context,
                    subcategoriaId: sub.id,
                    subcategoriaNome: sub.nome,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  static Future<T?> showBookProducts<T>({
    required BuildContext context,
    required int subcategoriaId,
    required String subcategoriaNome,
  }) {
    final prodStore = Modular.get<ProductStore>();
    if (prodStore.lastSubcategoriaId != subcategoriaId &&
        !prodStore.isLoading) {
      prodStore.fetchProdutos(subcategoriaId);
    }

    return CustomModal.show<T>(
      context: context,
      title: subcategoriaNome,
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
              ...prodStore.produtos.map((p) {
                final unitValue = p.valor != null
                    ? 'R\$ ${p.valor!.toStringAsFixed(2)}'
                    : '—';
                final selected = Modular.get<ProductStore>().isSelected(p.id);
                return TechnologyItem(
                  itemName: p.nome,
                  text1: p.indicacao ?? '',
                  text2: p.tipo ?? '',
                  text3: unitValue,
                  isSelected: selected,
                  onCheckboxChanged: (v) {
                    Modular.get<ProductStore>().setSelected(p.id, v ?? false);
                  },
                  onActionTap: () {
                    ProductInfoModal.show(
                      context: context,
                      productInfo: {
                        'Categoria': 'Livros',
                        'Subcategoria': subcategoriaNome,
                        'Tipo': p.tipo ?? '—',
                        'Código': p.codigo ?? '—',
                        'ISBN': p.isbn ?? '—',
                        'Valor Total': unitValue,
                      },
                      checkboxGroups: const [],
                      unitValue: unitValue,
                      onSave: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '$subcategoriaNome - Produtos salvos com sucesso!'),
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
                        content: Text(
                            '$subcategoriaNome - Produtos salvos com sucesso!'),
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
