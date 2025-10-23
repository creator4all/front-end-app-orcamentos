import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../stores/budget_config_store.dart';
import '../widgets/product_detail_modal.dart';
import '../widgets/school_census_card.dart';
import '../widgets/subcategories_modal.dart';
import '../widgets/subcategory_products_modal.dart';

class ConfigNewBudgetPage extends StatefulWidget {
  final int budgetId;

  const ConfigNewBudgetPage({
    super.key,
    required this.budgetId,
  });

  @override
  State<ConfigNewBudgetPage> createState() => _ConfigNewBudgetPageState();
}

class _ConfigNewBudgetPageState extends State<ConfigNewBudgetPage> {
  late final BudgetConfigStore store;

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    store = Modular.get<BudgetConfigStore>();

    // Define a data atual para o campo "Data do orçamento" no formato brasileiro
    _dataOrcamentoController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Define o valor padrão para "Validade do orçamento"
    _validadeOrcamentoController.text = '60';

    // Inicializa a store com o budgetId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.initialize(widget.budgetId);
    });
  }

  @override
  void dispose() {
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final result = await store.finalizeBudget();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Configurar Orçamento',
        showBackButton: true,
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    selectedProductsCount: store.selectedCategoriesCount,
                  ),

                  SizedBox(height: 12.h),

                  // ✅ Card do Censo Escolar
                  if (store.budgetDetail?.cityIds.isNotEmpty ?? false)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: SchoolCensusCard(
                        numberOfCities: store.budgetDetail?.cityIds.length ?? 0,
                        citiesData: _extractCitiesData(),
                      ),
                    ),

                  SizedBox(height: 12.h),

                  // ✅ Categorias Dinâmicas
                  if (store.hasCategories)
                    ...store.categories.map((category) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildCategoryFromEntity(category),
                      );
                    }),

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

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: store.isSaving || !store.canFinalize
                          ? null
                          : _handleSave,
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
    print('🔍 [ConfigPage] Abrindo modal de subcategorias: ${category.nome}');
    print('   📦 Subcategorias: ${category.subcategorias.length}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubcategoriesModal(
        category: category,
        onSubcategoryTap: (subcategory) {
          print(
              '🔍 [ConfigPage] Subcategoria selecionada: ${subcategory.nome}');
          Navigator.pop(context);
          _showProductsModal(category, subcategory);
        },
      ),
    );
  }

  void _showProductsModal(
      CategoryEntity category, SubcategoryEntity subcategory) {
    print('🔍 [ConfigPage] Abrindo modal de produtos: ${subcategory.nome}');
    print('   📦 Produtos ativos: ${subcategory.activeProductsCount}');

    // Usar o helper estático que encapsula CustomModal.show
    // Agora recebe categoryId para buscar dados reativos da store
    SubcategoryProductsModal.show(
      context: context,
      subcategory: subcategory,
      categoryId: category.id,
    );
  }

  void _showProductDetailModal(ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => ProductDetailModal(
        product: product,
        onSave: (quantity, observations) {
          store.updateProductQuantity(product.id, quantity);
          store.updateProductObservations(product.id, observations);
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
        return ProductCategory(
          categoryIcon: Icon(
            _getCategoryIcon(category.nome),
            color: Colors.black54,
          ),
          title: category.nome,
          value: category.formattedTotalValue,
          selectedCount: category.selectedProductsCount,
          totalCount: category.totalActiveProducts,
          isSelected: category.hasSelectedProducts,
          onCheckboxChanged: null, // Não permitir toggle direto da categoria
          onActionTap: () {
            print('👆 [ConfigPage] Categoria clicada: ${category.nome}');
            _showSubcategoriesModal(category);
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
