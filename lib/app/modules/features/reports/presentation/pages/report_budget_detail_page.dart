import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import '../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../shared/widgets/export_pdf_modal.dart';
import '../../../../../shared/widgets/product_category.dart';
import '../../../../../shared/widgets/status_tag_widget.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../../../budget/budget_config/domain/entities/category_entity.dart';
import '../../../budget/budget_config/domain/entities/subcategory_entity.dart';
import '../../../budget/budget_config/presentation/widgets/budget_skeleton.dart';
import '../../../budget/budget_config/presentation/widgets/school_census_card.dart';
import '../stores/report_budget_detail_store.dart';
import '../widgets/report_products_modal.dart';
import '../widgets/report_subcategories_modal.dart';

class ReportBudgetDetailPage extends StatefulWidget {
  final int budgetId;
  final String? partnerName;
  final String? userName;

  const ReportBudgetDetailPage({
    super.key,
    required this.budgetId,
    this.partnerName,
    this.userName,
  });

  @override
  State<ReportBudgetDetailPage> createState() => _ReportBudgetDetailPageState();
}

class _ReportBudgetDetailPageState extends State<ReportBudgetDetailPage> {
  late final ReportBudgetDetailStore _store;
  late final AuthStore _authStore;

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ReportBudgetDetailStore>();
    _authStore = Modular.get<AuthStore>();

    _store.loadBudgetDetails(widget.budgetId);
  }

  @override
  void dispose() {
    _store.clear();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  TagType _getTagType(String status) {
    switch (status.toLowerCase()) {
      case 'aprovado':
        return TagType.approved;
      case 'pendente':
      case 'rascunho':
        return TagType.pending;
      case 'expirado':
        return TagType.expired;
      case 'nao_aprovado':
      case 'não aprovado':
        return TagType.notApproved;
      case 'arquivado':
        return TagType.archived;
      default:
        return TagType.pending;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Pendente';
      case 'aprovado':
        return 'Aprovado';
      case 'expirado':
        return 'Expirado';
      case 'nao_aprovado':
        return 'Não Aprovado';
      case 'rascunho':
        return 'Rascunho';
      default:
        return status;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Detalhes do Orçamento',
        showBackButton: true,
        authStore: _authStore,
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const BudgetSkeleton();
          }

          if (_store.error != null && _store.budgetDetail == null) {
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
                      _store.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () =>
                          _store.loadBudgetDetails(widget.budgetId),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_store.budgetDetail == null) {
            return const Center(child: Text('Orçamento não encontrado'));
          }

          final budget = _store.budgetDetail!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyUserHeader(),
                  _buildStatusHeader(),
                  BudgetSummaryCard(
                    budgetValue: budget.calculatedTotal,
                    selectedProductsCount: _store.selectedItemsCount,
                  ),
                  SizedBox(height: 12.h),
                  if (_store.hasCensus)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: SchoolCensusCard(
                        numberOfCities: budget.cityIds.length,
                        citiesData: _extractCitiesData(),
                        censoAgregado: _store.censoEscolar?.censoAgregado,
                        onTap: _openCensusPage,
                      ),
                    ),
                  SizedBox(height: 12.h),
                  if (budget.hasCategories) ...[
                    ...budget.categories.map((category) {
                      if (category.expandido) {
                        return [
                          _buildExpandedCategoryHeader(category),
                          ..._buildExpandedSubcategories(category),
                        ];
                      } else {
                        return [
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildCategoryCard(category),
                          ),
                        ];
                      }
                    }).expand((widgets) => widgets),
                  ],
                  if (!budget.hasCategories)
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
                        child: _buildReadonlyField(
                          'Data do orçamento',
                          _formatDate(budget.creationDate),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildReadonlyField(
                          'Validade do orç.',
                          '${budget.validityDays} dias',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildReadonlyStatusControls(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompanyUserHeader() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.partnerName ?? 'Empresa',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E3562),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.userName ?? 'Usuário',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF828282),
            ),
          ),
        ],
      ),
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
                  type: _getTagType(_store.budgetDetail?.status ?? 'pendente'),
                ),
                if (_store.budgetDetail?.isDraft ?? false) ...[
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

  Widget _buildReadonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            border: Border.all(color: const Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF484848),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadonlyStatusControls() {
    final budget = _store.budgetDetail;
    if (budget == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: _buildReadonlyField(
              'Status Orçamento',
              _getStatusLabel(budget.status),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildReadonlyField(
              'Arquivado',
              'Não',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedCategoryHeader(CategoryEntity category) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
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
    return ProductCategory(
      isReadOnly: true,
      categoryIcon: const Icon(Icons.layers_outlined, color: Colors.black54),
      title: subcategory.nome,
      value: subcategory.formattedTotalValue,
      selectedCount: subcategory.selectedProductsCount,
      totalCount: subcategory.activeProductsCount,
      isSelected: subcategory.selectedProductsCount > 0,
      onCardTap: () => _showProductsModal(parentCategory, subcategory),
      onActionTap: () => _showProductsModal(parentCategory, subcategory),
    );
  }

  Widget _buildCategoryCard(CategoryEntity category) {
    return ProductCategory(
      isReadOnly: true,
      categoryIcon: Icon(
        _getCategoryIcon(category.nome),
        color: Colors.black54,
      ),
      title: category.nome,
      value: category.formattedTotalValue,
      selectedCount: category.selectedProductsCount,
      totalCount: category.totalActiveProducts,
      isSelected: category.hasSelectedProducts,
      onCardTap: () => _showSubcategoriesModal(category),
      onActionTap: () => _showSubcategoriesModal(category),
    );
  }

  void _showSubcategoriesModal(CategoryEntity category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportSubcategoriesModal(
        category: category,
        onSubcategoryTap: (subcategory) {
          Navigator.pop(context);
          _showProductsModal(category, subcategory);
        },
      ),
    );
  }

  void _showProductsModal(
      CategoryEntity category, SubcategoryEntity subcategory) {
    ReportProductsModal.show(
      context: context,
      category: category,
      subcategory: subcategory,
    );
  }

  void _openCensusPage() {
    Modular.to.pushNamed(
      '/reports/budget/${widget.budgetId}/census',
      arguments: {'censoData': _store.censoEscolar},
    );
  }

  Future<void> _handleShare() async {
    await ExportPdfModal.show(
      context: context,
      orcamentoId: widget.budgetId,
    );
  }

  /// Extrai dados das cidades para o SchoolCensusCard
  List<Map<String, dynamic>> _extractCitiesData() {
    final budget = _store.budgetDetail;
    if (budget == null || budget.citiesData.isEmpty) {
      return [];
    }
    return budget.citiesData;
  }
}
