import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../../../../auth/presentation/stores/auth_store.dart';
import '../../../budget_create/domain/entities/budget_draft_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../stores/budget_config_store.dart';
import '../widgets/budget_skeleton.dart';
import '../widgets/product_edit_modal.dart';
import '../widgets/product_remark_confirmation_modal.dart';
import '../widgets/school_census_card.dart';
import '../widgets/subcategories_modal.dart';
import '../widgets/subcategory_products_modal.dart';

class ConfigNewBudgetPage extends StatefulWidget {
  final int budgetId;
  final BudgetDraftEntity? initialDraft;
  final String? cityName;
  final String? stateName;

  const ConfigNewBudgetPage({
    super.key,
    required this.budgetId,
    this.initialDraft,
    this.cityName,
    this.stateName,
  });

  @override
  State<ConfigNewBudgetPage> createState() => _ConfigNewBudgetPageState();
}

class _ConfigNewBudgetPageState extends State<ConfigNewBudgetPage> {
  late final BudgetConfigStore store;
  late final AuthStore _authStore;

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    store = Modular.get<BudgetConfigStore>();
    _authStore = Modular.get<AuthStore>();

    _dataOrcamentoController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());

    _validadeOrcamentoController.text = '60';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Modular.args.data;
      BudgetDraftEntity? initialDraft;

      // Extrair draft do novo formato de arguments
      if (args is Map<String, dynamic> && args.containsKey('budget')) {
        initialDraft = args['budget'] as BudgetDraftEntity?;
      } else if (args is BudgetDraftEntity) {
        initialDraft = args;
      } else {
        initialDraft = widget.initialDraft;
      }

      if (initialDraft != null) {
        store.initializeWithDraft(initialDraft);
      } else {
        store.initialize(widget.budgetId);
      }
    });
  }

  @override
  void dispose() {
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

  /// Gera título do header baseado na localização
  String _getHeaderTitle() {
    if (widget.cityName != null && widget.stateName != null) {
      return '${widget.cityName} - ${widget.stateName}';
    }
    return 'Configurar Orçamento';
  }

  Future<void> _handleSave() async {
    final result = await store.saveBudget();

    result.fold(
      (failure) {
        // Erro já foi definido na store
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (budget) {
        // Sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orçamento salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar de volta para a lista
        Modular.to.navigate('/budget/');
      },
    );
  }

  /// Valida orçamento antes de salvar e mostra feedback apropriado
  Future<void> _handleSaveWithValidation() async {
    // 1️⃣ Validar data de validade
    if (store.validityDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, defina a data de validade do orçamento'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 2️⃣ Validar produtos selecionados (Dialog de confirmação se vazio)
    if (store.totalSelectedProducts == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Orçamento sem produtos'),
          content: const Text(
            'Você não adicionou nenhum produto ao orçamento.\n\n'
            'Deseja salvar mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF117BBD),
              ),
              child: const Text('Salvar mesmo assim'),
            ),
          ],
        ),
      );

      // Se usuário cancelou, não prosseguir
      if (confirm != true) return;
    }

    // 3️⃣ Todas as validações passaram, prosseguir com save
    await _handleSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: _getHeaderTitle(),
        showBackButton: true,
        authStore: _authStore,
      ),
      body: Observer(
        builder: (_) {
          // Mostrar skeleton enquanto carrega dados completos
          if (!store.isFullyLoaded) {
            return const BudgetSkeleton();
          }

          if (store.error != null && !store.hasData) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      store.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => store.initialize(widget.budgetId),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!store.hasData) {
            return const Center(child: Text('Nenhum dado disponível'));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Resumo do orçamento
                  BudgetSummaryCard(
                    budgetValue: store.totalValue,
                    selectedProductsCount: store.selectedItemsCount,
                  ),

                  SizedBox(height: 12.h),

                  // ✅ Card do Censo Escolar
                  if (store.budgetDetail?.cityIds.isNotEmpty ?? false)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: SchoolCensusCard(
                        numberOfCities: store.budgetDetail?.cityIds.length ?? 0,
                        citiesData: _extractCitiesData(),
                        onTap: () async {
                          print(
                              '👆 [ConfigPage] Navegando para edição do Censo Escolar');

                          final cityId =
                              store.budgetDetail?.cityIds.firstOrNull;
                          if (cityId == null) return;

                          // Navegar para tela de edição do censo passando budgetId e callback
                          final result = await Modular.to.pushNamed(
                            '/budget/census/$cityId',
                            arguments: {
                              'censoEscolar': store.censoEscolar,
                              'budgetId': widget.budgetId,
                              'onCensusUpdated': (updatedCenso) {
                                // Atualizar censo no store local
                                store.updateCensoEscolar(updatedCenso);
                              },
                            },
                          );

                          // Ao retornar da tela, verificar se houve atualização (retorna true)
                          if (result == true) {
                            print(
                                '✅ [ConfigPage] Censo editado, recarregando produtos...');

                            // Recarregar produtos com quantidades recalculadas
                            await store.reloadProductsAfterCensusEdit();

                            // Verificar se há produtos que precisam de remarcação
                            if (store.productsNeedingRemark.isNotEmpty) {
                              print(
                                  '🔔 [ConfigPage] ${store.productsNeedingRemark.length} produtos precisam de remarcação');

                              // Mostrar modal de confirmação
                              await ProductRemarkConfirmationModal.show(
                                context: context,
                                productsToRemark: store.productsNeedingRemark,
                                onConfirm: () {
                                  store.confirmProductRemark();
                                },
                                onCancel: () {
                                  store.rejectProductRemark();
                                },
                              );
                            }

                            print(
                                '✅ [ConfigPage] Produtos atualizados com sucesso!');
                          }
                        },
                      ),
                    ),

                  SizedBox(height: 12.h),

                  // ✅ Categorias Dinâmicas (baseadas no campo "expandido")
                  if (store.hasCategories) ...[
                    ...store.categories.map((category) {
                      if (category.expandido) {
                        // Exibir como categoria expandida (header + subcategorias visíveis)
                        return [
                          _buildExpandedCategoryHeader(category),
                          ..._buildExpandedSubcategories(category),
                        ];
                      } else {
                        // Exibir como card único (abre modal ao clicar)
                        return [
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildCategoryFromEntity(category),
                          ),
                        ];
                      }
                    }).expand((widgets) => widgets),
                  ],

                  // Mensagem se não houver categorias
                  if (!store.hasCategories)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Text(
                        'Nenhuma categoria disponível',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Data do orçamento',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.info,
                                  color: const Color(0xFF117BBD),
                                  size: 16.sp,
                                ),
                              ],
                            ),
                            TextField(
                              controller: _dataOrcamentoController,
                              readOnly: true,
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                              ),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Validade do orç. *',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.info,
                                  color: const Color(0xFF117BBD),
                                  size: 16.sp,
                                ),
                              ],
                            ),
                            TextField(
                              controller: _validadeOrcamentoController,
                              keyboardType: TextInputType.number,
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                              ),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Mensagem de erro
                  if (store.error != null)
                    Container(
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              store.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botão Salvar (sempre habilitado, exceto quando salvando)
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed:
                          store.isSaving ? null : _handleSaveWithValidation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF117BBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: store.isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Salvar Orçamento',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ========== MÉTODOS AUXILIARES ==========

  /// Constrói o header para categorias expandidas
  Widget _buildExpandedCategoryHeader(CategoryEntity category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.nome,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF117BBD),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                  decimalDigits: 2,
                ).format(category.totalValue),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói a lista de subcategorias expandidas
  /// Ordena por campo "ordem" do backend
  List<Widget> _buildExpandedSubcategories(CategoryEntity category) {
    // Ordenar subcategorias por ordem
    final sortedSubcategories = category.subcategorias.toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return sortedSubcategories.map((subcategory) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSubcategoryCard(subcategory, category),
      );
    }).toList();
  }

  /// Constrói um card para subcategoria usando ProductCategory widget
  Widget _buildSubcategoryCard(
      SubcategoryEntity subcategory, CategoryEntity parentCategory) {
    return Observer(
      builder: (_) {
        // ✅ Buscar categoria atualizada da store
        final currentCategory = store.categories.firstWhere(
          (c) => c.id == parentCategory.id,
          orElse: () => parentCategory,
        );

        // ✅ Buscar subcategoria atualizada dentro da categoria
        final currentSubcategory = currentCategory.subcategorias.firstWhere(
          (s) => s.id == subcategory.id,
          orElse: () => subcategory,
        );

        return ProductCategory(
          categoryIcon: const Icon(
            Icons.layers_outlined,
            color: Colors.black54,
          ),
          title: currentSubcategory.nome,
          value: currentSubcategory.formattedTotalValue,
          selectedCount: currentSubcategory.selectedProductsCount,
          totalCount: currentSubcategory.activeProductsCount,
          isSelected: currentSubcategory.selectedProductsCount > 0,
          onCheckboxChanged: (selected) {
            if (selected == null) return;
            print(
                '✅ [ConfigPage] Checkbox subcategoria ${currentSubcategory.nome}: ${selected ? "MARCAR" : "DESMARCAR"}');
            store.toggleSubcategoryWithCascade(
              currentCategory.id,
              currentSubcategory.id,
              selected,
            );
          },
          onCardTap: () {
            print(
                '👆 [ConfigPage] Card subcategoria clicado: ${currentSubcategory.nome}');
            _showProductsModal(currentCategory, currentSubcategory);
          },
          onActionTap: () {
            print(
                '👆 [ConfigPage] Botão ação subcategoria: ${currentSubcategory.nome}');
            _showProductsModal(currentCategory, currentSubcategory);
          },
        );
      },
    );
  }

  /// Extrai dados das cidades para o card do Censo Escolar
  /// Retorna lista de mapas com {id, nome, indicadores}
  List<Map<String, dynamic>> _extractCitiesData() {
    if (store.budgetDetail == null) {
      return [];
    }

    // Usar dados das cidades já parseadas do DTO
    return store.budgetDetail!.citiesData;
  }

  // ========== MÉTODOS PARA MODAIS ==========

  void _showSubcategoriesModal(CategoryEntity category) {
    // 🔒 GUARD: Não permitir abertura enquanto produtos estão carregando
    if (store.isLoadingProducts) {
      print('⚠️ [ConfigPage] Modal bloqueado - produtos ainda carregando');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde, carregando produtos...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('🔍 [ConfigPage] Abrindo modal de subcategorias: ${category.nome}');
    print('   📦 Subcategorias: ${category.subcategorias.length}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Observer(
        builder: (_) {
          // ✅ Buscar categoria atualizada da store
          final currentCategory = store.categories.firstWhere(
            (c) => c.id == category.id,
            orElse: () => category,
          );

          return SubcategoriesModal(
            category: currentCategory,
            onSubcategoryTap: (subcategory) {
              print(
                  '🔍 [ConfigPage] Subcategoria selecionada: ${subcategory.nome}');
              Navigator.pop(context);
              _showProductsModal(currentCategory, subcategory);
            },
            onCheckboxChanged: (categoryId, subcategoryId, selected) {
              print(
                  '✅ [ConfigPage] Checkbox subcategoria (modal): categoryId=$categoryId, subcategoryId=$subcategoryId, selected=$selected');
              store.toggleSubcategoryWithCascade(
                categoryId,
                subcategoryId,
                selected,
              );
            },
          );
        },
      ),
    );
  }

  void _showProductsModal(
      CategoryEntity category, SubcategoryEntity subcategory) {
    // 🔒 GUARD: Não permitir abertura enquanto produtos estão carregando
    if (store.isLoadingProducts) {
      print('⚠️ [ConfigPage] Modal de produtos bloqueado - ainda carregando');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde, carregando produtos...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('🔍 [ConfigPage] Abrindo modal de produtos: ${subcategory.nome}');
    print('   📦 Produtos ativos: ${subcategory.activeProductsCount}');

    // Usar o helper estático que encapsula CustomModal.show
    // Agora recebe category completa para exibir título composto
    SubcategoryProductsModal.show(
      context: context,
      category: category,
      subcategory: subcategory,
    );
  }

  void _showProductDetailModal(ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => ProductEditModal(
        product: product,
        onSave: (updatedProduct) {
          // Atualizar produto na store
          store.updateProductFromModal(updatedProduct);
        },
        onClose: () {
          // Modal fechado sem salvar
        },
      ),
    );
  }

  // ========== HELPER PARA ÍCONES ==========

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'livros':
        return Icons.menu_book;
      case 'tecnologias':
        return Icons.computer;
      default:
        return Icons.category;
    }
  }

  // ========== BUILD CATEGORIA DINÂMICA ==========

  Widget _buildCategoryFromEntity(CategoryEntity category) {
    print('🏗️ [ConfigPage] Construindo categoria: ${category.nome}');
    print('   - Produtos ativos: ${category.totalActiveProducts}');
    print('   - Produtos selecionados: ${category.selectedProductsCount}');
    print('   - Valor total: ${category.formattedTotalValue}');

    return Observer(
      builder: (_) {
        // ✅ Buscar categoria atualizada da store dentro do Observer
        final currentCategory = store.categories.firstWhere(
          (c) => c.id == category.id,
          orElse: () => category,
        );

        return ProductCategory(
          categoryIcon: Icon(
            _getCategoryIcon(currentCategory.nome),
            color: Colors.black54,
          ),
          title: currentCategory.nome,
          value: currentCategory.formattedTotalValue,
          selectedCount: currentCategory.selectedProductsCount,
          totalCount: currentCategory.totalActiveProducts,
          isSelected: currentCategory.hasSelectedProducts,
          onCheckboxChanged: (bool? value) {
            print(
                '☑️ [ConfigPage] Checkbox categoria: ${currentCategory.nome} = $value');
            store.toggleCategoryWithCascade(currentCategory.id, value ?? false);
          },
          onCardTap: () {
            print(
                '👆 [ConfigPage] Card categoria clicado: ${currentCategory.nome}');
            _showSubcategoriesModal(currentCategory);
          },
          onActionTap: () {
            print(
                '👆 [ConfigPage] Botão ação categoria: ${currentCategory.nome}');
            _showSubcategoriesModal(currentCategory);
          },
        );
      },
    );
  }

  // ========== BUILD CATEGORIA ANTIGA (MANTER PARA COMPATIBILIDADE) ==========

  Widget _buildCategory(String key, String title, IconData icon) {
    return Observer(
      builder: (_) {
        final isSelected = store.categoryStates[key] ?? false;

        // Mock de dados - em produção viriam do budgetDetail
        const value = 'R\$ 0,00';
        const selectedCount = 0;
        const totalCount = 0;

        return ProductCategory(
          categoryIcon: Icon(icon, color: Colors.black54),
          title: title,
          value: value,
          selectedCount: selectedCount,
          totalCount: totalCount,
          isSelected: isSelected,
          onCheckboxChanged: (bool? value) {
            store.toggleCategory(key);
          },
        );
      },
    );
  }
}
