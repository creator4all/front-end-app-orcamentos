import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../modules/budget/presentation/stores/product_store.dart';
import '../../modules/budget/presentation/stores/card_selection_store.dart';
import '../../modules/budget/presentation/stores/budget_edit_store.dart';
import '../../modules/budget/external/services/budget_service.dart';
import 'custom_modal.dart';
import 'product_info_modal.dart';
import 'technology_item.dart';

class TechnologyProductsModal {
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
        'Grupo': 'Tecnologias',
        'Sub-grupo': subcategoriaNome,
        'Solução': produto.nome,
        'Indicação': produto.indicacao ?? '—',
        'Tipo': produto.tipo ?? '—',
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

  static Future<T?> show<T>({
    required BuildContext context,
    required int subcategoriaId,
    required String title,
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
          // Obter produtos apenas desta subcategoria usando o cache
          final subcategoryProducts = prodStore.getProdutosPorSubcategoria(subcategoriaId);
          
          // Verificar se todos os produtos estão selecionados
          final allSelected = subcategoryProducts.isNotEmpty && 
              subcategoryProducts.every((p) => prodStore.isSelected(p.id));
          
          // Verificar se alguns produtos estão selecionados (para tristate)
          final someSelected = subcategoryProducts.any((p) => prodStore.isSelected(p.id));
          
          // Obter o CardSelectionStore para atualizar a seleção da subcategoria
          final cardStore = Modular.get<CardSelectionStore>();
          
          // Atualizar a seleção da subcategoria com base nos produtos selecionados
          if (allSelected) {
            cardStore.setSubcategorySelected(subcategoriaId, true);
          } else if (!someSelected) {
            cardStore.setSubcategorySelected(subcategoriaId, false);
          }
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Espaço apenas para manter layout consistente
              SizedBox(height: 5.h),
              // Mostrar produtos apenas desta subcategoria usando o cache
              ...subcategoryProducts.map((p) {
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
                    // Atualizar a seleção do produto
                    prodStore.setSelected(p.id, v ?? false);
                    
                    // Verificar se todos os produtos estão selecionados após a mudança
                    final allProductsSelected = subcategoryProducts
                        .every((prod) => prod.id == p.id ? (v ?? false) : prodStore.isSelected(prod.id));
                    
                    // Verificar se nenhum produto está selecionado após a mudança
                    final noProductsSelected = subcategoryProducts
                        .every((prod) => prod.id == p.id ? !(v ?? false) : !prodStore.isSelected(prod.id));
                    
                    // Atualizar a seleção da subcategoria com base nos produtos
                    if (allProductsSelected) {
                      cardStore.setSubcategorySelected(subcategoriaId, true);
                    } else if (noProductsSelected) {
                      cardStore.setSubcategorySelected(subcategoriaId, false);
                    }
                  },
                  onActionTap: () {
                    _showProductInfo(context, p, title, unitValue);
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
