import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../modules/budget/presentation/stores/books_subcategory_store.dart';
import '../../modules/budget/presentation/stores/product_store.dart';
import '../../modules/budget/presentation/stores/card_selection_store.dart';
import '../../modules/budget/presentation/stores/budget_edit_store.dart';
import '../../modules/budget/external/services/budget_service.dart';
import 'book_item.dart';
import 'custom_modal.dart';
import 'product_info_modal.dart';
import 'technology_item.dart';

class BooksModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required int categoriaId,
  }) {
    final subStore = Modular.get<BooksSubcategoryStore>();
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
                return Observer(
                  builder: (_) {
                    final prodStore = Modular.get<ProductStore>();
                    final selectedCount = prodStore.getSelectedCountForSubcategory(sub.id);
                    final totalCount = prodStore.getTotalCountForSubcategory(sub.id);
                    final totalValue = prodStore.getTotalValueForSubcategory(sub.id);
                    
                    final cardStore = Modular.get<CardSelectionStore>();
                    final isSubcategorySelected = selectedCount > 0;
                    
                    return BookItem(
                      title: sub.nome,
                      value: 'R\$ ${totalValue.toStringAsFixed(2)}',
                      quantity: '$selectedCount/$totalCount',
                      isSelected: isSubcategorySelected,
                      onCheckboxChanged: (value) {
                        // Marcar/desmarcar a subcategoria
                        cardStore.setSubcategorySelected(sub.id, value ?? false);
                        
                        // Usar o novo método da ProductStore que garante isolamento por subcategoria
                        prodStore.selectAllForSubcategory(sub.id, value ?? false);
                      },
                      onTap: () => showBookProducts(
                        context: context,
                        subcategoriaId: sub.id,
                        subcategoriaNome: sub.nome,
                      ),
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
                      const SnackBar(
                        content: Text('Livros salvos com sucesso!'),
                        backgroundColor: Color(0xFF56B34A),
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

  static void _showProductInfo(
    BuildContext context,
    dynamic produto,
    String subcategoriaNome,
    String unitValue,
  ) {
    print('🔍 _showProductInfo chamado para produto: ${produto.id}');
    print('🔍 Produto: ${produto.nome}');
    print('🔍 indicadoresEtapa: ${produto.indicadoresEtapa}');
    
    // Processar indicadores_etapa do produto
    final indicadoresEtapa = produto.indicadoresEtapa ?? [];
    
    print('🔍 Total de indicadores: ${indicadoresEtapa.length}');
    
    // Agrupar indicadores por grupo_nome
    final Map<String, List<Map<String, dynamic>>> indicadoresPorGrupo = {};
    
    for (final ind in indicadoresEtapa) {
      final grupoNome = ind['grupo_nome'] as String? ?? 'Sem Grupo';
      if (!indicadoresPorGrupo.containsKey(grupoNome)) {
        indicadoresPorGrupo[grupoNome] = [];
      }
      indicadoresPorGrupo[grupoNome]!.add(ind);
    }
    
    // Converter para CheckboxGroups
    final checkboxGroups = indicadoresPorGrupo.entries.map((entry) {
      return CheckboxGroup(
        title: entry.key,
        items: entry.value.map((ind) {
          return CheckboxItem(
            label: ind['indicador_nome'] as String? ?? '',
            isSelected: ind['selecionado'] as bool? ?? false,
            data: ind, // Guardar dados completos para salvar depois
          );
        }).toList(),
      );
    }).toList();
    
    ProductInfoModal.show(
      context: context,
      productInfo: {
        'Categoria': 'Livros',
        'Subcategoria': subcategoriaNome,
        'Tipo': produto.tipo ?? '—',
        'Código': produto.codigo ?? '—',
        'ISBN': produto.isbn ?? '—',
        'Valor Total': unitValue,
      },
      checkboxGroups: checkboxGroups,
      unitValue: unitValue,
      onSave: () async {
        // Coletar indicadores modificados
        final indicadoresParaSalvar = <Map<String, dynamic>>[];
        
        for (final group in checkboxGroups) {
          for (final item in group.items) {
            final indData = item.data as Map<String, dynamic>;
            indicadoresParaSalvar.add({
              'produto_indicador_id': indData['produto_indicador_id'],
              'selecionado': item.isSelected,
            });
          }
        }
        
        // Buscar orçamento ID e salvar
        final budgetEditStore = Modular.get<BudgetEditStore>();
        final orcamentoId = budgetEditStore.budgetData?['id'] as int?;
        
        if (orcamentoId != null) {
          try {
            final budgetService = Modular.get<BudgetService>();
            await budgetService.salvarIndicadoresProduto(
              orcamentoId,
              produto.id,
              indicadoresParaSalvar,
            );
            
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$subcategoriaNome - Indicadores salvos com sucesso!'),
                  backgroundColor: const Color(0xFF56B34A),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao salvar indicadores: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
    );
  }

  static Future<T?> showBookProducts<T>({
    required BuildContext context,
    required int subcategoriaId,
    required String subcategoriaNome,
  }) {
    final prodStore = Modular.get<ProductStore>();
    
    // Não buscar produtos novamente se já existem na subcategoria
    // (evita sobrescrever dados do orçamento que incluem indicadores)
    final produtosExistentes = prodStore.getProdutosPorSubcategoria(subcategoriaId);
    if (produtosExistentes.isEmpty && prodStore.lastSubcategoriaId != subcategoriaId && !prodStore.isLoading) {
      print('🔄 Buscando produtos da subcategoria $subcategoriaId...');
      prodStore.fetchProdutos(subcategoriaId);
    } else {
      print('✅ Usando produtos já carregados da subcategoria $subcategoriaId (${produtosExistentes.length} produtos)');
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
              ...prodStore.getProdutosPorSubcategoria(subcategoriaId).map((p) {
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
                    _showProductInfo(context, p, subcategoriaNome, unitValue);
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
