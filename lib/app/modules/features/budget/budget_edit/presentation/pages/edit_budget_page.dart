import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';
import 'package:multimidiaapp/app/shared/utils/date_utils.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';

import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/export_pdf_modal.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../../../../../../shared/widgets/select_all_card.dart';
import '../../../../../../shared/widgets/status_tag_widget.dart';
import '../../../../auth/presentation/stores/auth_store.dart';
import '../../../budget_config/domain/entities/budget_detail_entity.dart';
import '../../../budget_config/domain/entities/category_entity.dart';
import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../budget_config/domain/entities/subcategory_entity.dart';
import '../../../budget_config/presentation/widgets/budget_skeleton.dart';
import '../../../budget_config/presentation/widgets/product_detail_modal.dart';
import '../../../budget_config/presentation/widgets/school_census_card.dart';
import '../../../budget_config/presentation/widgets/subcategories_modal.dart';
import '../../../budget_config/presentation/widgets/subcategory_products_modal.dart';
import '../stores/budget_edit_store.dart';

class EditBudgetPage extends StatefulWidget {
  final int budgetId;
  final String? initialTitle;
  final BudgetDetailEntity? initialConfiguredBudget;

  const EditBudgetPage({
    super.key,
    required this.budgetId,
    this.initialTitle,
    this.initialConfiguredBudget,
  });

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  late final BudgetEditStore store;
  late final AuthStore _authStore;
  bool _shouldRefreshBudgetList = false;
  String? _lastShownLoadErrorMessage;
  Map<String, dynamic>? _budgetListPatch;

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  void _syncValidityFieldWithStore() {
    _validadeOrcamentoController.removeListener(_onValidityDaysChanged);

    try {
      if (store.validityDate != null) {
        final dias = nonNegativeDaysUntil(store.validityDate!);
        _validadeOrcamentoController.text = dias.toString();
      } else {
        _validadeOrcamentoController.text = '60';
        _updateValidityDate(60);
      }
    } finally {
      _validadeOrcamentoController.addListener(_onValidityDaysChanged);
    }
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

  String _buildHeaderTitle() {
    final loadedTitle = store.budgetName?.trim();
    String title;

    if (loadedTitle != null && loadedTitle.isNotEmpty) {
      title = loadedTitle;
    } else {
      final initialTitle = widget.initialTitle?.trim();
      title = (initialTitle != null && initialTitle.isNotEmpty)
          ? initialTitle
          : 'Editar orçamento';
    }

    return store.hasChanges ? '$title *' : title;
  }

  void _closePage({Map<String, dynamic>? budgetListPatch}) {
    if (budgetListPatch != null) {
      _budgetListPatch = budgetListPatch;
    }

    if (!_shouldRefreshBudgetList) {
      Navigator.of(context).pop(false);
      return;
    }

    final result = <String, dynamic>{
      'shouldRefresh': true,
    };

    if (_budgetListPatch != null) {
      result['budgetPatch'] = Map<String, dynamic>.from(_budgetListPatch!);
    }

    Navigator.of(context).pop(result);
  }

  Map<String, dynamic> _createBudgetListPatch({
    required int budgetId,
    String? name,
    required int validityDays,
    DateTime? validityDate,
    required String status,
    required bool isArchived,
    required double total,
  }) {
    return {
      'id': budgetId,
      'nome': name,
      'diasValidade': validityDays,
      'dataValidade': validityDate,
      'status': status,
      'isArchived': isArchived,
      'total': total,
    };
  }

  void _capturePersistedBudgetListPatchFromStore() {
    final budget = store.budgetData;
    if (budget == null) return;

    _budgetListPatch = _createBudgetListPatch(
      budgetId: budget.id,
      name: budget.name,
      validityDays: budget.validityDays,
      validityDate: budget.validityDate,
      status: budget.status,
      isArchived: budget.isArchived,
      total: store.totalValue,
    );
  }

  Future<void> _retryLoadBudget() async {
    _lastShownLoadErrorMessage = null;
    await store.initialize(widget.budgetId);
  }

  String _buildUserFriendlyLoadErrorMessage(String? error) {
    final normalizedError = error?.toLowerCase() ?? '';

    if (normalizedError.contains('401') ||
        normalizedError.contains('403') ||
        normalizedError.contains('não autorizado') ||
        normalizedError.contains('nao autorizado') ||
        normalizedError.contains('sem permissão') ||
        normalizedError.contains('sem permissao')) {
      return 'Você não tem permissão para acessar este orçamento.';
    }

    if (normalizedError.contains('404') ||
        normalizedError.contains('não encontrado') ||
        normalizedError.contains('nao encontrado')) {
      return 'Este orçamento não foi encontrado ou não está mais disponível.';
    }

    if (normalizedError.contains('sem conexão') ||
        normalizedError.contains('sem conexao') ||
        normalizedError.contains('connection') ||
        normalizedError.contains('timeout') ||
        normalizedError.contains('network')) {
      return 'Não foi possível carregar o orçamento por causa da conexão. Verifique sua internet e tente novamente.';
    }

    return 'Não foi possível carregar o orçamento agora. Tente novamente em instantes.';
  }

  void _showLoadErrorDialogIfNeeded(String message) {
    if (_lastShownLoadErrorMessage == message) {
      return;
    }

    _lastShownLoadErrorMessage = message;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao carregar orçamento',
        message: message,
      );
    });
  }

  Widget _buildLoadErrorState() {
    final message = _buildUserFriendlyLoadErrorMessage(store.error);

    _showLoadErrorDialogIfNeeded(message);

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
              'Não foi possível abrir este orçamento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tente novamente para continuar a edição.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _retryLoadBudget,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    store = Modular.get<BudgetEditStore>();
    _authStore = Modular.get<AuthStore>();
    store.reset();

    _dataOrcamentoController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());

    _validadeOrcamentoController.addListener(_onValidityDaysChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final initialConfiguredBudget = widget.initialConfiguredBudget;
      if (initialConfiguredBudget != null) {
        store.initializeWithConfiguredBudget(initialConfiguredBudget);
      } else {
        await store.initialize(widget.budgetId);
      }

      if (!mounted) return;

      _syncValidityFieldWithStore();
    });
  }

  @override
  void dispose() {
    _validadeOrcamentoController.removeListener(_onValidityDaysChanged);
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    store.reset();
    super.dispose();
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

    if (store.validityDate!.isBefore(DateTime.now())) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Atenção',
        message: 'Data de validade não pode ser no passado',
      );
      return;
    }

    if (store.totalSelectedProducts == 0) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Atenção',
        message: 'Selecione pelo menos um produto para o orçamento',
      );
      return;
    }

    await _handleSaveChanges();
  }

  Future<void> _handleSaveChanges() async {
    final result = await store.saveBudgetWithDto();

    result.fold((failure) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao salvar',
        message: failure.message,
      );
    }, (budget) async {
      _shouldRefreshBudgetList = true;

      _capturePersistedBudgetListPatchFromStore();

      await store.loadBudgetForEdit(budget.id);

      if (store.error != null) {
        final reloadError = store.error;
        store.clearError();
        if (mounted) {
          await CustomInfoDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Erro ao recarregar após salvar',
            message: reloadError ?? 'Não foi possível recarregar o orçamento.',
          );
        }
        return;
      }

      _syncValidityFieldWithStore();

      if (!mounted) return;

      await CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Sucesso',
        message: 'Orçamento atualizado com sucesso!',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _closePage();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Observer(
            builder: (_) => CustomTopBar(
              title: _buildHeaderTitle(),
              showBackButton: true,
              onBackPressed: _closePage,
              authStore: _authStore,
            ),
          ),
        ),
        body: Observer(
          builder: (_) {
            if (store.error == null || store.hasData) {
              _lastShownLoadErrorMessage = null;
            }

            if (!store.isFullyLoaded) {
              return const BudgetSkeleton();
            }

            if (store.error != null && !store.hasData) {
              return _buildLoadErrorState();
            }

            if (!store.hasData) {
              return const Center(child: Text('Nenhum dado disponível'));
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildStatusHeader(),
                    BudgetSummaryCard(
                      budgetValue: store.totalValue,
                      selectedProductsCount: store.selectedItemsCount,
                    ),
                    SizedBox(height: 12.h),
                    if (store.budgetData?.cityIds.isNotEmpty ?? false)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: SchoolCensusCard(
                          numberOfCities: store.budgetData?.cityIds.length ?? 0,
                          citiesData: _extractCitiesData(),
                          censoAgregado: store.censoEscolar?.valoresPorEtapa,
                          onTap: () async {
                            final isMultiCity =
                                (store.budgetData?.cityIds.length ?? 0) > 1;
                            final cityId =
                                store.budgetData?.cityIds.firstOrNull ?? 0;

                            final censusSaved =
                                await Modular.to.pushNamed<bool>(
                              '/budget/census/$cityId',
                              arguments: {
                                'censoEscolar': store.censoEscolar,
                                'budgetId':
                                    store.budgetData?.id ?? widget.budgetId,
                                'isMultiCityMode': isMultiCity,
                                'onCensusUpdated': (updatedCenso) {
                                  store.updateCensoEscolar(updatedCenso);
                                },
                                'onCensusSaved': () =>
                                    store.reloadProductsAfterCensusEdit(),
                              },
                            );

                            if (censusSaved == true) {
                              _shouldRefreshBudgetList = true;
                              _capturePersistedBudgetListPatchFromStore();
                            }
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
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
                    _buildStatusControls(),
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
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Salvar Alterações',
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
        );
      },
    );
  }

  List<Map<String, dynamic>> _extractCitiesData() {
    if (store.budgetData == null || store.budgetData!.citiesDataRaw.isEmpty) {
      return [];
    }

    final result = <Map<String, dynamic>>[];

    for (final cityData in store.budgetData!.citiesDataRaw) {
      final cityId = cityData['id'] ?? cityData['idCidades'] ?? 0;
      final cityName = cityData['nome'] ?? cityData['nome_cidade'] ?? '';

      final indicadoresRaw = cityData['indices'] as List? ??
          cityData['indicadores'] as List? ??
          cityData['cidades_has_indice_etapa'] as List? ??
          [];

      final indicadores = indicadoresRaw.map((ind) {
        if (ind is! Map<String, dynamic>) return <String, dynamic>{};

        final grupoObj = ind['grupo'] as Map<String, dynamic>?;
        final nomeGrupo = ind['grupo_nome'] ??
            grupoObj?['nome'] ??
            grupoObj?['nome_grupo'] ??
            '';
        final idGrupo =
            ind['grupo_id'] ?? grupoObj?['id'] ?? grupoObj?['grupo_id'] ?? 0;
        final pivot = ind['pivot'] as Map<String, dynamic>?;

        final valorRaw =
            ind['valor'] ?? pivot?['etapa_valor'] ?? ind['etapa_valor'] ?? 0;
        final valor = valorRaw is num
            ? valorRaw
            : double.tryParse(valorRaw.toString()) ?? 0;

        return {
          'id': ind['id'] ?? ind['idindice_etapa'],
          'nome': ind['nome_etapa'] ?? ind['nome'] ?? '',
          'valor': valor,
          'grupo_id': idGrupo,
          'grupo_nome': nomeGrupo,
        };
      }).toList();

      result.add({
        'id': cityId,
        'nome': cityName,
        'indicadores': indicadores,
      });
    }

    return result;
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
      onUpdateProductManualQuantity: store.setProductManualQuantity,
      onUpdateProductQuantityMode: store.setProductQuantityMode,
      onToggleProductIndicator: store.toggleProductIndicator,
      onToggleAllProducts: store.toggleSubcategoryWithCascade,
    );
  }

  void _showProductDetailModal(ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => ProductDetailModal(
        product: product,
        onSave: (quantity, observations) {
          store.updateProductQuantity(product.id, quantity);
          if (observations != null) {
            store.updateProductObservations(product.id, observations);
          }
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
        );
      },
    );
  }

  Widget _buildStatusHeader() {
    return Observer(
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                StatusTagWidget(
                  type: _mapStatusToTagType(store.selectedStatus),
                ),
                if (store.isArchived) ...[
                  SizedBox(width: 8.w),
                  const StatusTagWidget(type: TagType.archived),
                ],
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.ios_share,
                size: 24.sp,
                color: store.hasChanges ? Colors.grey : const Color(0xFF0C498E),
              ),
              onPressed: store.hasChanges ? _handleShareBlocked : _handleShare,
              tooltip: store.hasChanges
                  ? 'Salve antes de exportar'
                  : 'Compartilhar orçamento',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusControls() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Orçamento',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Observer(
                  builder: (_) => DropdownButtonFormField<String>(
                    value: store.selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pendente',
                        child: Text(
                          'Pendente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'aprovado',
                        child: Text(
                          'Aprovado',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'expirado',
                        child: Text(
                          'Expirado',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'nao_aprovado',
                        child: Text(
                          'Não Aprovado',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        store.setStatus(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arquivado',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Observer(
                  builder: (_) => DropdownButtonFormField<bool>(
                    value: store.isArchived,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                          'Não',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text(
                          'Sim',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        store.setArchived(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TagType _mapStatusToTagType(String status) {
    switch (status) {
      case 'pendente':
        return TagType.pending;
      case 'aprovado':
        return TagType.approved;
      case 'nao_aprovado':
        return TagType.notApproved;
      case 'expirado':
        return TagType.expired;
      default:
        return TagType.pending;
    }
  }

  Future<void> _handleShare() async {
    if (store.budgetData == null) return;

    await ExportPdfModal.show(
      context: context,
      orcamentoId: store.budgetData!.id,
    );
  }

  void _handleShareBlocked() {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.warning,
      title: 'Alterações pendentes',
      message: 'Salve as alterações antes de exportar o PDF',
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'aprovado':
        return 'Aprovado';
      case 'expirado':
        return 'Expirado';
      case 'nao_aprovado':
        return 'Não Aprovado';
      default:
        return status;
    }
  }
}
