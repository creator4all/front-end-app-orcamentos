import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../shared/widgets/status_tag_widget.dart';
import '../stores/report_budget_detail_store.dart';

/// Página de visualização de detalhes de um orçamento em modo somente leitura.
///
/// Mostra informações do orçamento, censo escolar e categorias de produtos,
/// tudo em modo de visualização sem opções de edição.
class ReportBudgetDetailPage extends StatefulWidget {
  final int budgetId;

  const ReportBudgetDetailPage({
    super.key,
    required this.budgetId,
  });

  @override
  State<ReportBudgetDetailPage> createState() => _ReportBudgetDetailPageState();
}

class _ReportBudgetDetailPageState extends State<ReportBudgetDetailPage> {
  late final ReportBudgetDetailStore _store;

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ReportBudgetDetailStore>();
    _store.loadBudgetDetails(widget.budgetId);
  }

  @override
  void dispose() {
    _store.clear();
    super.dispose();
  }

  void _openCensusPage() {
    Modular.to.pushNamed(
      '/reports/budget/${widget.budgetId}/census',
      arguments: {'censoData': _store.censoEscolar},
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Observer(
              builder: (_) => CustomTopBar(
                title: _store.budgetName,
                showBackButton: true,
                onBackPressed: () => Modular.to.pop(),
              ),
            ),

            // Conteúdo
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0E3562),
                      ),
                    );
                  }

                  if (_store.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: const Color(0xFF828282),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _store.error!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF828282),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: _store.refresh,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  final budget = _store.budgetDetail;
                  if (budget == null) {
                    return const Center(
                      child: Text('Orçamento não encontrado'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _store.refresh,
                    color: const Color(0xFF0E3562),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card de resumo
                          BudgetSummaryCard(
                            budgetValue: budget.total,
                            selectedProductsCount: budget.totalSelectedProducts,
                          ),

                          SizedBox(height: 16.h),

                          // Informações básicas
                          _buildInfoCard(
                            title: 'Informações do Orçamento',
                            children: [
                              _buildInfoRow(
                                'Status',
                                budget.status,
                                trailing: StatusTagWidget(
                                  type: _getTagType(budget.status),
                                ),
                              ),
                              _buildInfoRow(
                                'Data de criação',
                                _formatDate(budget.creationDate),
                              ),
                              _buildInfoRow(
                                'Validade',
                                '${budget.validityDays} dias',
                              ),
                              _buildInfoRow(
                                'Data de validade',
                                _formatDate(budget.validityDate),
                              ),
                              if (budget.isMultiCity)
                                _buildInfoRow(
                                  'Cidades',
                                  '${budget.cityIds.length} cidades',
                                ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Censo Escolar (clicável)
                          if (_store.hasCensus) _buildCensusCard(),

                          SizedBox(height: 16.h),

                          // Categorias de produtos
                          if (budget.hasCategories)
                            _buildCategoriesSection(budget),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0E3562),
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF828282),
            ),
          ),
          trailing ??
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF484848),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildCensusCard() {
    return GestureDetector(
      onTap: _openCensusPage,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF0E3562).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.school,
                color: const Color(0xFF0E3562),
                size: 24.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Censo Escolar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0E3562),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Toque para visualizar',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF828282),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF828282),
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(dynamic budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias de Produtos',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0E3562),
          ),
        ),
        SizedBox(height: 12.h),
        ...budget.categories.map<Widget>((category) {
          return _buildCategoryCard(category);
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryCard(dynamic category) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1C94DF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.category,
              color: const Color(0xFF1C94DF),
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name ?? 'Categoria',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF484848),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${category.selectedProductsCount} produtos selecionados',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF828282),
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
              decimalDigits: 2,
            ).format(category.totalValue),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E3562),
            ),
          ),
        ],
      ),
    );
  }
}
