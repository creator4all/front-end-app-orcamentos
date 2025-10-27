import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Imports compartilhados
import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/export_pdf_modal.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../../../../../../shared/widgets/status_tag_widget.dart';
// Imports de serviços
import '../../../../../budget/external/services/budget_service.dart';
// Imports da feature
import '../../../budget_config/domain/entities/category_entity.dart';
import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../budget_config/domain/entities/subcategory_entity.dart';
// Imports dos widgets do budget_config (reutilização)
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

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  /// Formata valor monetário para padrão brasileiro
  /// Ex: 17049856.20 -> R$ 17.049.856,20
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Sincroniza campo de texto de validade com a store
  void _syncValidityFieldWithStore() {
    if (store.validityDate != null) {
      // Calcular dias a partir da data de validade existente
      final hoje = DateTime.now();
      final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
      final dias = store.validityDate!.difference(hojeDate).inDays;
      _validadeOrcamentoController.text = dias.toString();
    } else {
      // Se não tem data, usar 60 dias como padrão
      _validadeOrcamentoController.text = '60';
      _updateValidityDate(60);
    }
  }

  /// Atualiza validityDate na store quando usuário digita
  void _onValidityDaysChanged() {
    final text = _validadeOrcamentoController.text;
    if (text.isNotEmpty) {
      final dias = int.tryParse(text);
      if (dias != null && dias > 0) {
        _updateValidityDate(dias);
      }
    }
  }

  /// Calcula e seta nova data de validade baseado nos dias
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

    // Define a data atual para o campo "Data do orçamento" no formato brasileiro
    _dataOrcamentoController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());

    // ✅ Listener para mudanças no campo de validade
    _validadeOrcamentoController.addListener(_onValidityDaysChanged);

    // Inicializa a store com o budgetId
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await store.initialize(widget.budgetId);

      // ✅ Após carregar, sincronizar campo com store
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

  /// Valida orçamento antes de salvar e mostra feedback apropriado
  Future<void> _handleSaveWithValidation() async {
    // 1️⃣ Validar data de validade
    if (store.validityDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, defina a data de validade do orçamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2️⃣ Validar se data não está no passado
    if (store.validityDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data de validade não pode ser no passado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 3️⃣ Validar produtos selecionados
    if (store.selectedProductsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um produto para o orçamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 4️⃣ Validar se orçamento pode ser editado (não aprovado)
    if (store.budgetData != null && !store.budgetData!.canBeEdited) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este orçamento não pode mais ser editado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 5️⃣ Todas validações passaram, salvar
    await _handleSaveChanges();
  }

  Future<void> _handleSaveChanges() async {
    final result = await store.saveBudgetWithDto();

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
            content: Text('Orçamento atualizado com sucesso!'),
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
        title: 'Editar Orçamento',
        showBackButton: true,
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
                  // 🏷️ Status Header (Tags + Compartilhar) - PRIMEIRO
                  _buildStatusHeader(),

                  // Resumo do orçamento
                  BudgetSummaryCard(
                    budgetValue: store.totalValue,
                    selectedProductsCount: store.selectedCategoriesCount,
                  ),

                  SizedBox(height: 12.h),

                  // Card do Censo Escolar
                  if (store.budgetData?.cityIds.isNotEmpty ?? false)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: SchoolCensusCard(
                        numberOfCities: store.budgetData?.cityIds.length ?? 0,
                        citiesData: _extractCitiesData(),
                      ),
                    ),

                  SizedBox(height: 12.h),

                  // Categorias Dinâmicas
                  if (store.hasCategories) ...[
                    // 1. LIVROS (sempre primeiro, se existir)
                    if (_getLivrosCategory() != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildCategoryFromEntity(_getLivrosCategory()!),
                      ),

                    // 2. TECNOLOGIAS (header + subcategorias expandidas)
                    if (_getTecnologiasCategory() != null) ...[
                      _buildTecnologiasHeader(_getTecnologiasCategory()!),
                      ..._buildTecnologiasSubcategories(
                          _getTecnologiasCategory()!),
                    ],
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

                  SizedBox(height: 4.h),

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

                  // 🎛️ Controles de Status e Arquivamento
                  _buildStatusControls(),

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

  // ========== MÉTODOS AUXILIARES ==========

  /// Busca a categoria "Livros" nas categorias disponíveis
  CategoryEntity? _getLivrosCategory() {
    if (!store.hasCategories) return null;
    try {
      return store.categories.firstWhere(
        (cat) => cat.nome.toLowerCase() == 'livros',
      );
    } catch (_) {
      return null;
    }
  }

  /// Busca a categoria "Tecnologias" nas categorias disponíveis
  CategoryEntity? _getTecnologiasCategory() {
    if (!store.hasCategories) return null;
    try {
      return store.categories.firstWhere(
        (cat) => cat.nome.toLowerCase() == 'tecnologias',
      );
    } catch (_) {
      return null;
    }
  }

  /// Constrói o header customizado para Tecnologias
  Widget _buildTecnologiasHeader(CategoryEntity tecnologias) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tecnologias',
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
                ).format(tecnologias.totalValue),
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

  /// Constrói a lista de subcategorias de Tecnologias
  List<Widget> _buildTecnologiasSubcategories(CategoryEntity tecnologias) {
    final sortedSubcategories =
        List<SubcategoryEntity>.from(tecnologias.subcategorias)
          ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return sortedSubcategories.map((subcategory) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSubcategoryCard(subcategory, tecnologias),
      );
    }).toList();
  }

  /// Constrói um card para subcategoria usando ProductCategory widget
  Widget _buildSubcategoryCard(
      SubcategoryEntity subcategory, CategoryEntity parentCategory) {
    return Observer(
      builder: (_) {
        // Buscar categoria atualizada da store
        final currentCategory = store.categories.firstWhere(
          (c) => c.id == parentCategory.id,
          orElse: () => parentCategory,
        );

        // Buscar subcategoria atualizada dentro da categoria
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

  /// Extrai dados das cidades para o card do Censo Escolar
  List<Map<String, dynamic>> _extractCitiesData() {
    if (store.budgetData == null) {
      return [];
    }

    // Retorna os dados completos das cidades (com indicadores) que vêm da API
    return store.budgetData!.citiesDataRaw;
  }

  // ========== MÉTODOS PARA MODAIS ==========

  void _showSubcategoriesModal(CategoryEntity category) {
    // Guard: Não permitir abertura enquanto produtos estão carregando
    if (store.isLoadingProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde, carregando produtos...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Observer(
        builder: (_) {
          // Buscar categoria atualizada da store
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
      categoryId: category.id,
      subcategory: subcategory,
      store: store, // Passa a store do BudgetEdit
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
    return Observer(
      builder: (_) {
        // Buscar categoria atualizada da store dentro do Observer
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

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Censo Escolar (se disponível)
            if (store.hasCensusData && store.budgetData != null) ...[
              SchoolCensusCard(
                numberOfCities: store.budgetData!.cityIds.length,
                citiesData: store.budgetData!.categoriesData['citiesData']
                        as List<Map<String, dynamic>>? ??
                    [],
              ),
              SizedBox(height: 16.h),
            ],

            // Resumo do Orçamento
            Observer(
              builder: (_) => BudgetSummaryCard(
                budgetValue: store.totalValue,
                selectedProductsCount: store.selectedProductsCount,
              ),
            ),

            SizedBox(height: 24.h),

            // Título da seção de categorias
            Text(
              'Categorias de Produtos',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF484848),
              ),
            ),

            SizedBox(height: 12.h),

            // Lista de Categorias
            _buildCategoriesList(),

            // Espaço para botão flutuante
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Observer(
      builder: (_) {
        // Loading de produtos
        if (store.isLoadingProducts) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // Sem categorias
        if (store.categories.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 48.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Nenhuma categoria disponível',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Lista de categorias
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: store.categories.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final category = store.categories[index];

            return ProductCategory(
              categoryIcon: Icon(
                Icons.category,
                size: 24.sp,
                color: const Color(0xFF117BBD),
              ),
              title: category.nome,
              value: _formatCurrency(category.totalValue),
              selectedCount: category.selectedProductsCount,
              totalCount: category.totalActiveProducts,
              isSelected: category.hasSelectedProducts,
              onCheckboxChanged: (selected) {
                // TODO: Implementar seleção/desseleção de toda categoria
              },
              onCardTap: () => _handleCategoryTap(category),
              onActionTap: () => _handleCategoryTap(category),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCategoryTap(CategoryEntity category) async {
    // Selecionar categoria na store
    store.selectCategory(category);

    // TODO: Implementar navegação para produtos da categoria
    // Por enquanto, apenas mostra dialog informativo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subcategorias: ${category.subcategorias.length}'),
            SizedBox(height: 8.h),
            Text(
                'Produtos selecionados: ${category.selectedProductsCount}/${category.totalActiveProducts}'),
            SizedBox(height: 8.h),
            Text('Valor: ${_formatCurrency(category.totalValue)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// 🏷️ Widget de Status Header (Tags + Botão Compartilhar)
  Widget _buildStatusHeader() {
    return Observer(
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tags de status
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
            // Botão compartilhar (iOS style)
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

  /// 🎛️ Widget de Controles de Status (Dropdowns)
  Widget _buildStatusControls() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 12.h),
      child: Row(
        children: [
          // Dropdown Status
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
          // Dropdown Arquivado
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

  /// 🔄 Mapeia status string para TagType enum
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

  /// 📤 Abre modal para exportar e compartilhar PDF do orçamento
  Future<void> _handleShare() async {
    if (store.budgetData == null) return;

    try {
      // Obter BudgetService do Modular
      final budgetService = Modular.get<BudgetService>();
      print('✅ BudgetService obtido via Modular');

      // Abrir modal de exportação de PDF
      await ExportPdfModal.show(
        context: context,
        orcamentoId: widget.budgetId,
        budgetService: budgetService,
      );
    } catch (e) {
      print('❌ Erro ao abrir modal de compartilhamento: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir modal de compartilhamento: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 🏷️ Retorna label legível para o status
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
