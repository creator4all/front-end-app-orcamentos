import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_list/presentation/stores/budget_list_store.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';

import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/export_pdf_modal.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../../../../../../shared/widgets/status_tag_widget.dart';
import '../../../../auth/presentation/stores/auth_store.dart';
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

  const EditBudgetPage({
    super.key,
    required this.budgetId,
  });

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  late final BudgetEditStore store;
  late final AuthStore _authStore;

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  void _syncValidityFieldWithStore() {
    if (store.validityDate != null) {
      final hoje = DateTime.now();
      final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
      final dias = store.validityDate!.difference(hojeDate).inDays;
      _validadeOrcamentoController.text = dias.toString();
    } else {
      _validadeOrcamentoController.text = '60';
      _updateValidityDate(60);
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

  @override
  void initState() {
    super.initState();
    store = Modular.get<BudgetEditStore>();
    _authStore = Modular.get<AuthStore>();

    _dataOrcamentoController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());

    _validadeOrcamentoController.addListener(_onValidityDaysChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await store.initialize(widget.budgetId);

      _syncValidityFieldWithStore();
    });
  }

  @override
  void dispose() {
    _validadeOrcamentoController.removeListener(_onValidityDaysChanged);
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveWithValidation() async {
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

    if (store.budgetData != null && !store.budgetData!.canBeEdited) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Ação não permitida',
        message: 'Este orçamento não pode mais ser editado',
      );
      return;
    }

    await _handleSaveChanges();
  }

  Future<void> _handleSaveChanges() async {
    final result = await store.saveBudgetWithDto();

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
          message: 'Orçamento atualizado com sucesso!',
        );

        final listStore = Modular.get<BudgetListStore>();
        await listStore.refresh();
        Modular.to.navigate('/budget/');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Editar Orçamento',
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

                          final censusUpdated = await Modular.to.pushNamed(
                            '/budget/census/$cityId',
                            arguments: {
                              'censoEscolar': store.censoEscolar,
                              'budgetId': widget.budgetId,
                              'isMultiCityMode': isMultiCity,
                              'onCensusUpdated': (updatedCenso) {
                                store.updateCensoEscolar(updatedCenso);
                              },
                            },
                          );

                          if (censusUpdated == true) {
                            await store.reloadProductsAfterCensusEdit();
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
                  if (!store.isArchived)
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

  List<Widget> _buildExpandedSubcategories(CategoryEntity category) {
    final sortedSubcategories = category.subcategorias.toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return sortedSubcategories.map((subcategory) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSubcategoryCard(subcategory, category),
      );
    }).toList();
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
          isReadOnly: store.isArchived,
          onCheckboxChanged: store.isArchived
              ? null
              : (selected) {
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
            isReadOnly: store.isArchived,
            onSubcategoryTap: (subcategory) {
              Navigator.pop(context);
              _showProductsModal(currentCategory, subcategory);
            },
            onCheckboxChanged: store.isArchived
                ? null
                : (categoryId, subcategoryId, selected) {
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
      store: store,
      isReadOnly: store.isArchived,
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
          isReadOnly: store.isArchived,
          onCheckboxChanged: store.isArchived
              ? null
              : (bool? value) {
                  store.toggleCategoryWithCascade(
                      currentCategory.id, value ?? false);
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
                color: const Color(0xFF0C498E),
              ),
              onPressed: _handleShare,
              tooltip: 'Compartilhar orçamento',
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
                        value: 'rascunho',
                        child: Text(
                          'Rascunho',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
      orcamentoId: widget.budgetId,
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
