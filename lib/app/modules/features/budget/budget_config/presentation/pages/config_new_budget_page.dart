import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';

import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../../../../../../shared/widgets/select_all_card.dart';
import '../../../../auth/presentation/stores/auth_store.dart';
import '../../../budget_create/domain/entities/budget_draft_entity.dart';
import '../../../budget_list/presentation/stores/budget_list_store.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../stores/budget_config_store.dart';
import '../widgets/budget_skeleton.dart';
import '../widgets/product_edit_modal.dart';
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

    _validadeOrcamentoController.addListener(_onValidityDaysChanged);

    _updateValidityDate(60);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Modular.args.data;

      BudgetDraftEntity? initialDraft;

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

  void _onValidityDaysChanged() {
    final text = _validadeOrcamentoController.text;
    if (text.isNotEmpty) {
      final dias = int.tryParse(text);
      if (dias != null && dias > 0) {
        _updateValidityDate(dias);
      }
    }
  }

  void _updateValidityDate(int dias) {
    final hoje = DateTime.now();
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    final novaData = hojeDate.add(Duration(days: dias));
    store.setValidityDate(novaData);
  }

  @override
  void dispose() {
    _validadeOrcamentoController.removeListener(_onValidityDaysChanged);
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

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
        CustomInfoDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Erro ao salvar',
          message: failure.message,
        );
      },
      (budget) async {
        await CustomInfoDialog.show(
          context: context,
          type: DialogType.success,
          title: 'Sucesso',
          message: 'Orçamento salvo com sucesso!',
        );

        final listStore = Modular.get<BudgetListStore>();
        await listStore.refresh();
        Modular.to.navigate('/budget/');
      },
    );
  }

  Future<void> _handleSaveWithValidation() async {
    final diasText = _validadeOrcamentoController.text;
    final dias = int.tryParse(diasText);
    if (dias == null || dias < 1 || dias > 365) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Atenção',
        message: 'Validade do orçamento deve estar entre 1 e 365 dias',
      );
      return;
    }

    if (store.validityDate == null) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Atenção',
        message: 'Por favor, defina a data de validade do orçamento',
      );
      return;
    }

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

      if (confirm != true) return;
    }

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
                  BudgetSummaryCard(
                    budgetValue: store.totalValue,
                    selectedProductsCount: store.selectedItemsCount,
                  ),
                  SizedBox(height: 12.h),
                  if ((store.budgetDetail?.cityIds.isNotEmpty ?? false) ||
                      (store.budgetDetail?.citiesData.isNotEmpty ?? false))
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: SchoolCensusCard(
                        numberOfCities: store.budgetDetail?.citiesData.length ??
                            store.budgetDetail?.cityIds.length ??
                            0,
                        citiesData: _extractCitiesData(),
                        censoAgregado: store.censoEscolar?.valoresPorEtapa,
                        onTap: () async {
                          final isMultiCity =
                              (store.budgetDetail?.cityIds.length ?? 0) > 1;
                          final cityId =
                              store.budgetDetail?.cityIds.firstOrNull ?? 0;

                          await Modular.to.pushNamed(
                            '/budget/census/$cityId',
                            arguments: {
                              'censoEscolar': store.censoEscolar,
                              'budgetId': widget.budgetId,
                              'isMultiCityMode': isMultiCity,
                              'onCensusUpdated': (updatedCenso) {
                                store.updateCensoEscolar(updatedCenso);
                              },
                              'onCensusSaved': () =>
                                  store.reloadProductsAfterCensusEdit(),
                            },
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 12.h),
                  if (store.hasCategories) ...[
                    ...(store.categories.toList()
                          ..sort((a, b) => a.ordem.compareTo(b.ordem)))
                        .map((category) {
                      if (category.expandido) {
                        return [
                          _buildExpandedCategoryHeader(category),
                          ..._buildExpandedSubcategories(category),
                        ];
                      } else {
                        return [
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildCategoryFromEntity(category),
                          ),
                        ];
                      }
                    }).expand((widgets) => widgets),
                  ],
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
                                GestureDetector(
                                  onTap: () => CustomInfoDialog.show(
                                    context: context,
                                    type: DialogType.info,
                                    title: 'Data do orçamento',
                                    message:
                                        'A data do orçamento será atualizada sempre que você fizer e salvar modificações. O orçamento antigo será arquivado.',
                                  ),
                                  child: Icon(
                                    Icons.info,
                                    color: const Color(0xFF117BBD),
                                    size: 16.sp,
                                  ),
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
                                GestureDetector(
                                  onTap: () => CustomInfoDialog.show(
                                    context: context,
                                    type: DialogType.info,
                                    title: 'Validade do orçamento',
                                    message:
                                        'Validade definida em dias, caso queira, coloque outra quantidade de dias.',
                                  ),
                                  child: Icon(
                                    Icons.info,
                                    color: const Color(0xFF117BBD),
                                    size: 16.sp,
                                  ),
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
                CurrencyUtils.formatBRL(category.totalValue),
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

  Widget _buildSelectAllCategoryCard(CategoryEntity category) {
    return Observer(
      builder: (_) {
        final currentCategory = store.categories.firstWhere(
          (c) => c.id == category.id,
          orElse: () => category,
        );

        return SelectAllCard(
          value: currentCategory.allActiveSubcategoriesSelected,
          onChanged: (selected) {
            store.toggleCategoryWithCascade(currentCategory.id, selected);
          },
        );
      },
    );
  }

  List<Widget> _buildExpandedSubcategories(CategoryEntity category) {
    final sortedSubcategories = category.subcategorias.toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return [
      Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSelectAllCategoryCard(category),
      ),
      ...sortedSubcategories.map((subcategory) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildSubcategoryCard(subcategory, category),
        );
      }),
    ];
  }

  Widget _buildSubcategoryCard(
      SubcategoryEntity subcategory, CategoryEntity parentCategory) {
    return Observer(
      builder: (_) {
        final currentCategory = store.categories.firstWhere(
          (c) => c.id == parentCategory.id,
          orElse: () => parentCategory,
        );

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
            store.toggleSubcategoryWithCascade(
              currentCategory.id,
              currentSubcategory.id,
              selected,
            );
          },
          onCardTap: () {
            _showProductsModal(currentCategory, currentSubcategory);
          },
          onActionTap: () {
            _showProductsModal(currentCategory, currentSubcategory);
          },
          splitTapZones: true,
        );
      },
    );
  }

  List<Map<String, dynamic>> _extractCitiesData() {
    if (store.budgetDetail == null) {
      return [];
    }

    return store.budgetDetail!.citiesData;
  }

  void _showSubcategoriesModal(CategoryEntity category) {
    if (store.isLoadingProducts) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.info,
        title: 'Aguarde',
        message: 'Carregando produtos...',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Observer(
        builder: (_) {
          final currentCategory = store.categories.firstWhere(
            (c) => c.id == category.id,
            orElse: () => category,
          );

          return SubcategoriesModal(
            category: currentCategory,
            onSubcategoryTap: (subcategory) {
              Navigator.pop(context);
              _showProductsModal(currentCategory, subcategory);
            },
            onCheckboxChanged: (categoryId, subcategoryId, selected) {
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
    if (store.isLoadingProducts) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.info,
        title: 'Aguarde',
        message: 'Carregando produtos...',
      );
      return;
    }

    SubcategoryProductsModal.show(
      context: context,
      category: category,
      subcategory: subcategory,
      resolveCategory: (categoryId) {
        return store.categories.firstWhere(
          (item) => item.id == categoryId,
          orElse: () => category,
        );
      },
      resolveSubcategory: (categoryId, subcategoryId) {
        final resolvedCategory = store.categories.firstWhere(
          (item) => item.id == categoryId,
          orElse: () => category,
        );
        return resolvedCategory.subcategorias.firstWhere(
          (item) => item.id == subcategoryId,
          orElse: () => subcategory,
        );
      },
      onToggleProduct: store.toggleProduct,
      onUpdateProductValue: store.updateProductValue,
      onUpdateProductQuantity: store.updateProductQuantity,
      onToggleProductIndicator: store.toggleProductIndicator,
      onToggleAllProducts: store.toggleSubcategoryWithCascade,
    );
  }

  void _showProductDetailModal(ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => ProductEditModal(
        product: product,
        onSave: (updatedProduct) {
          store.updateProductFromModal(updatedProduct);
        },
      ),
    );
  }

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

  Widget _buildCategoryFromEntity(CategoryEntity category) {
    return Observer(
      builder: (_) {
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
            store.toggleCategoryWithCascade(currentCategory.id, value ?? false);
          },
          onCardTap: () {
            _showSubcategoriesModal(currentCategory);
          },
          onActionTap: () {
            _showSubcategoriesModal(currentCategory);
          },
          splitTapZones: true,
        );
      },
    );
  }

  Widget _buildCategory(String key, String title, IconData icon) {
    return Observer(
      builder: (_) {
        final isSelected = store.categoryStates[key] ?? false;

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
