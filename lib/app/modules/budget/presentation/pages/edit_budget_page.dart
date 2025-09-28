import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/budget_summary_card.dart';
import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/product_category.dart';
import '../../../../shared/widgets/school_census.dart';
import '../../../../shared/widgets/status_tag_widget.dart';
import 'package:multimidiaapp/entities/censo_entity.dart';
import '../../../../shared/widgets/books_modal.dart';
import '../../../../shared/widgets/technology_products_modal.dart';
import '../../../../shared/widgets/export_pdf_modal.dart';
import '../../presentation/stores/category_store.dart';
import '../../presentation/stores/subcategory_store.dart';
import '../../presentation/stores/books_subcategory_store.dart';
import '../../presentation/stores/product_store.dart';
import '../../presentation/stores/card_selection_store.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product_selection.dart';
import '../../domain/models/budget_create.dart';
import '../../domain/models/budget_summary.dart';
import '../../external/services/budget_service.dart';

class EditBudgetPage extends StatefulWidget {
  final BudgetSummaryDto budget;
  
  const EditBudgetPage({
    super.key,
    required this.budget,
  });

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  // Cache for the censo data to persist between screen navigations
  CensoData? _cachedCensoData;

  // Usar a CardSelectionStore para gerenciar seleções
  late CardSelectionStore cardStore;
  
  // Controllers for form fields
  final TextEditingController _dataOrcamentoController = TextEditingController();
  final TextEditingController _validadeOrcamentoController = TextEditingController();
  
  // Status and archive dropdowns
  String _selectedStatus = 'pendente';
  bool _isArchived = false;
  
  bool _isLoadingInitialData = true;

  // Convenience properties for card selections
  bool get isLivrosSelected => cardStore.mainCardsSelection['livros'] ?? false;
  bool get isPortalSelected => cardStore.mainCardsSelection['portal'] ?? false;
  bool get isGamificacaoSelected => cardStore.mainCardsSelection['gamificacao'] ?? false;
  bool get isAvaliacaoSelected => cardStore.mainCardsSelection['avaliacao'] ?? false;
  bool get isServicosSelected => cardStore.mainCardsSelection['servicos'] ?? false;

  @override
  void initState() {
    super.initState();
    _initializeBudgetData();
  }

  void _initializeBudgetData() {
    // Initialize form fields with budget data
    _dataOrcamentoController.text = DateTime.now().toString().split(' ')[0];
    
    // Calculate validity date from budget
    final validityDate = widget.budget.dataValidade ?? 
        DateTime.now().add(Duration(days: widget.budget.diasValidade));
    _validadeOrcamentoController.text = validityDate.toString().split(' ')[0];
    
    // Initialize status and archive from budget
    _selectedStatus = widget.budget.status.toLowerCase();
    _isArchived = widget.budget.status.toLowerCase() == 'arquivado';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cardStore = Modular.get<CardSelectionStore>();
    _loadAllInitialData();
  }

  @override
  void dispose() {
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Editar orçamento',
        showBackButton: true,
      ),
      body: SafeArea(
        child: _isLoadingInitialData
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Carregando dados do orçamento...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // TODO: Add status row with badge and share icon
                    _buildStatusRow(),
                    const SizedBox(height: 12),
                    
                    // TODO: Add budget summary card
                    _buildBudgetSummary(),
                    const SizedBox(height: 12),
                    
                    // TODO: Add school census section
                    _buildSchoolCensus(),
                    const SizedBox(height: 12),
                    
                    // TODO: Add product categories section
                    _buildProductCategories(),
                    const SizedBox(height: 12),
                    
                    // TODO: Add date fields
                    _buildDateFields(),
                    const SizedBox(height: 12),
                    
                    // TODO: Add status and archive dropdowns
                    _buildStatusDropdowns(),
                    const SizedBox(height: 24),
                    
                    // TODO: Add save button
                    _buildSaveButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  // Method to load all necessary data when opening the screen
  Future<void> _loadAllInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
    });
    
    try {
      print('🔄 Iniciando carregamento de dados para edição...');
      print('📋 Orçamento ID: ${widget.budget.id}');
      print('📋 Status atual: ${widget.budget.status}');
      
      // 1. Load categories first
      final categoryStore = Modular.get<CategoryStore>();
      await categoryStore.fetchCategorias();
      print('✅ Categorias carregadas: ${categoryStore.categorias.length}');
      
      // 2. Find Books and Technologies categories
      final livrosCategory = categoryStore.categorias.firstWhere(
        (cat) => cat.nome.toLowerCase().contains('livro'),
        orElse: () => CategoryDto(id: -1, nome: ''),
      );
      
      final tecnologiasCategory = categoryStore.categorias.firstWhere(
        (cat) => cat.nome.toLowerCase().contains('tecnologia'),
        orElse: () => CategoryDto(id: -1, nome: ''),
      );
      
      print('📚 Categoria Livros: ${livrosCategory.nome} (ID: ${livrosCategory.id})');
      print('💻 Categoria Tecnologias: ${tecnologiasCategory.nome} (ID: ${tecnologiasCategory.id})');
      
      // 3. Load Books subcategories
      if (livrosCategory.id != -1) {
        final booksSubStore = Modular.get<BooksSubcategoryStore>();
        await booksSubStore.fetchSubcategorias(livrosCategory.id);
        print('✅ Subcategorias de Livros carregadas: ${booksSubStore.subcategorias.length}');
        
        // 4. Load products for all Books subcategories
        final prodStore = Modular.get<ProductStore>();
        for (final sub in booksSubStore.subcategorias) {
          await prodStore.fetchProdutos(sub.id);
          print('✅ Produtos da subcategoria "${sub.nome}" carregados');
        }
      }
      
      // 5. Load Technologies subcategories
      if (tecnologiasCategory.id != -1) {
        final techSubStore = Modular.get<SubcategoryStore>();
        await techSubStore.fetchSubcategorias(tecnologiasCategory.id);
        print('✅ Subcategorias de Tecnologias carregadas: ${techSubStore.subcategorias.length}');
        
        // 6. Load products for all Technologies subcategories
        final prodStore = Modular.get<ProductStore>();
        for (final sub in techSubStore.subcategorias) {
          await prodStore.fetchProdutos(sub.id);
          print('✅ Produtos da subcategoria "${sub.nome}" carregados');
        }
      }
      
      // 7. Load existing budget products and selections
      // TODO: This will need to be implemented when we have the budget details API
      // For now, we'll initialize with empty selections
      await _loadExistingBudgetSelections();
      
      print('🎉 Todos os dados iniciais carregados com sucesso para edição!');
    } catch (e) {
      print('❌ Erro ao carregar dados iniciais: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  // Load existing budget selections and populate the stores
  Future<void> _loadExistingBudgetSelections() async {
    try {
      print('🔄 Carregando seleções existentes do orçamento...');
      
      // TODO: When we have the budget details API, we'll load the actual selections
      // For now, we'll initialize the stores with empty selections
      
      // Reset all selections in the card store
      // Note: We'll reset selections manually since clearAllSelections may not exist
      cardStore.setMainCardSelected('livros', false);
      cardStore.setMainCardSelected('portal', false);
      cardStore.setMainCardSelected('gamificacao', false);
      cardStore.setMainCardSelected('avaliacao', false);
      cardStore.setMainCardSelected('servicos', false);
      
      // Initialize subcategories selection state
      final techSubStore = Modular.get<SubcategoryStore>();
      for (final sub in techSubStore.subcategorias) {
        if (!cardStore.subcategoriesSelection.containsKey(sub.id)) {
          cardStore.setSubcategorySelected(sub.id, false);
        }
      }
      
      print('✅ Seleções do orçamento inicializadas');
    } catch (e) {
      print('❌ Erro ao carregar seleções do orçamento: $e');
    }
  }

  // Method to process Books selection (copied from original)
  Future<void> _processLivrosSelection(BooksSubcategoryStore booksSubStore, ProductStore prodStore, bool selected) async {
    // For each books subcategory
    for (final sub in booksSubStore.subcategorias) {
      // Register that this subcategory belongs to the "livros" card
      cardStore.registerSubcategoryToMainCard(sub.id, 'livros');
      
      // Mark/unmark the subcategory
      cardStore.setSubcategorySelected(sub.id, selected);
      
      // Load subcategory products if necessary
      if (!prodStore.produtosPorSubcategoria.containsKey(sub.id)) {
        await prodStore.fetchProdutos(sub.id);
      }
      
      // Use ProductStore method that ensures isolation by subcategory
      prodStore.selectAllForSubcategory(sub.id, selected);
    }
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Status badge and archive indicator
        Row(
          children: [
            // Status badge
            _buildStatusBadge(),
            
            // Archive indicator (only show if archived)
            if (_isArchived) ...[
              SizedBox(width: 8.w),
              const StatusTagWidget(
                type: TagType.archived,
                customText: 'Arquivado',
              ),
            ],
          ],
        ),
        
        // Right side - Share icon
        GestureDetector(
          onTap: _handleShareTap,
          child: Icon(
            Icons.ios_share,
            size: 24.sp,
            color: const Color(0xFF1C1B1F),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    TagType tagType;
    switch (_selectedStatus.toLowerCase()) {
      case 'aprovado':
        tagType = TagType.approved;
        break;
      case 'não aprovado':
      case 'nao aprovado':
      case 'reprovado':
        tagType = TagType.notApproved;
        break;
      case 'expirado':
        tagType = TagType.expired;
        break;
      default:
        tagType = TagType.pending;
    }

    return StatusTagWidget(type: tagType);
  }

  void _handleShareTap() {
    ExportPdfModal.show(context: context);
  }

  Widget _buildBudgetSummary() {
    // Use Observer to automatically update when stores change
    return Observer(builder: (_) {
      final prodStore = Modular.get<ProductStore>();
      final cardSelectionStore = Modular.get<CardSelectionStore>();
      
      return BudgetSummaryCard(
        budgetValue: prodStore.total,
        selectedProductsCount: cardSelectionStore.visibleCheckboxesCount,
      );
    });
  }

  Widget _buildSchoolCensus() {
    // Use a StatefulBuilder to be able to update this widget when census data changes
    return StatefulBuilder(
      builder: (context, setBuilderState) {
        final args = ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;
        final censo = _cachedCensoData ??
            (args != null ? args['censo'] as CensoData? : null);
        return SchoolCensus(
          leadingIcon: const Icon(Icons.school, color: Colors.black54),
          title: 'Censo Escolar',
          info1: censo != null
              ? 'estudantes: ${censo.cidadeData?.totalEstudantes ?? 0}'
              : '—',
          info2: censo != null
              ? 'turmas: ${censo.cidadeData?.quantidadeTurmas ?? 0}'
              : '—',
          onActionTap: () async {
            final result = await Navigator.pushNamed(
              context,
              '/budget/census',
              arguments: {'censo': censo},
            );
            if (result is Map<String, dynamic> &&
                result.containsKey('updatedCenso')) {
              final updatedCenso = result['updatedCenso'] as CensoData;
              setState(() {
                _cachedCensoData = updatedCenso;
              });
              setBuilderState(() {});
            }
          },
        );
      },
    );
  }

  Widget _buildProductCategories() {
    return Observer(
      builder: (_) {
        final catStore = Modular.get<CategoryStore>();
        
        if (catStore.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (catStore.error != null) {
          return Text(
            'Erro ao carregar categorias: ${catStore.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final livrosCat = catStore.categorias.firstWhere(
          (c) => c.nome.toLowerCase().trim() == 'livros',
          orElse: () => CategoryDto(id: -1, nome: 'Livros'),
        );
        final tecnologiasCat = catStore.categorias.firstWhere(
          (c) => c.nome.toLowerCase().trim() == 'tecnologias',
          orElse: () => CategoryDto(id: -1, nome: 'Tecnologias'),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Books Category Section
            if (livrosCat.id != -1)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Observer(
                  builder: (_) {
                    final prodStore = Modular.get<ProductStore>();
                    final booksSubStore = Modular.get<BooksSubcategoryStore>();
                    
                    // Calculate real count of books products
                    int selectedProductsCount = 0;
                    int totalProductsCount = 0;
                    double totalValue = 0.0;
                    
                    for (final sub in booksSubStore.subcategorias) {
                      selectedProductsCount += prodStore.getSelectedCountForSubcategory(sub.id);
                      totalProductsCount += prodStore.getTotalCountForSubcategory(sub.id);
                      totalValue += prodStore.getTotalValueForSubcategory(sub.id);
                    }
                    
                    return ProductCategory(
                      categoryIcon: const Icon(Icons.menu_book, color: Colors.black54),
                      title: 'Livros',
                      value: 'R\$ ${totalValue.toStringAsFixed(2)}',
                      selectedCount: selectedProductsCount,
                      totalCount: totalProductsCount,
                      isSelected: isLivrosSelected,
                      onCheckboxChanged: (bool? value) {
                        // Update the store
                        cardStore.setMainCardSelected('livros', value ?? false);
                        
                        // Get necessary stores
                        final booksSubStore = Modular.get<BooksSubcategoryStore>();
                        final prodStore = Modular.get<ProductStore>();
                        
                        // If we don't have subcategories loaded, load first
                        if (booksSubStore.subcategorias.isEmpty && !booksSubStore.isLoading) {
                          booksSubStore.fetchSubcategorias(livrosCat.id).then((_) async {
                            // After loading subcategories, mark/unmark all
                            await _processLivrosSelection(booksSubStore, prodStore, value ?? false);
                          });
                        } else {
                          // We already have subcategories loaded, mark/unmark all
                          _processLivrosSelection(booksSubStore, prodStore, value ?? false);
                        }
                      },
                      onActionTap: () async {
                        // Use BooksModal for books category, which shows subcategories
                        await BooksModal.show(
                          context: context,
                          categoriaId: livrosCat.id,
                        );
                      },
                    );
                  },
                ),
              ),
            
            // Technologies Section Title
            Text(
              'Tecnologias',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF117BBD),
              ),
            ),
            const SizedBox(height: 12),
            
            // Technologies Categories Section
            Observer(
              builder: (_) {
                // Use SubcategoryStore only for Technologies
                final subStore = Modular.get<SubcategoryStore>();
                
                // Load technology subcategories
                if (tecnologiasCat.id > 0 && subStore.lastCategoriaId != tecnologiasCat.id && !subStore.isLoading) {
                  subStore.fetchSubcategorias(tecnologiasCat.id);
                }
                
                if (subStore.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Initialize subcategories selection state if not done yet
                for (final sub in subStore.subcategorias) {
                  if (!cardStore.subcategoriesSelection.containsKey(sub.id)) {
                    cardStore.setSubcategorySelected(sub.id, false);
                  }
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show each subcategory as a ProductCategory
                    ...subStore.subcategorias.map((sub) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Observer(
                          builder: (_) {
                            final prodStore = Modular.get<ProductStore>();
                            final selectedCount = prodStore.getSelectedCountForSubcategory(sub.id);
                            final totalCount = prodStore.getTotalCountForSubcategory(sub.id);
                            final totalValue = prodStore.getTotalValueForSubcategory(sub.id);
                            
                            return ProductCategory(
                              categoryIcon: const Icon(Icons.widgets, color: Colors.black54),
                              title: sub.nome,
                              value: 'R\$ ${totalValue.toStringAsFixed(2)}',
                              selectedCount: selectedCount,
                              totalCount: totalCount,
                              isSelected: cardStore.subcategoriesSelection[sub.id] ?? false,
                              onCheckboxChanged: (bool? value) {
                                // Determine the new selection value (inverse of current)
                                final isCurrentlySelected = cardStore.subcategoriesSelection[sub.id] ?? false;
                                final newSelection = !isCurrentlySelected;
                                
                                // Update subcategory selection in store
                                cardStore.setSubcategorySelected(sub.id, newSelection);
                                
                                // Use ProductStore method that ensures isolation by subcategory
                                prodStore.selectAllForSubcategory(sub.id, newSelection);
                              },
                              onActionTap: () async {
                                await TechnologyProductsModal.show(
                                  context: context,
                                  subcategoriaId: sub.id,
                                  title: sub.nome,
                                );
                              },
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Data do orçamento
        Row(
          children: [
            Text(
              'Data do orçamento',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data em que o orçamento foi gerado'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Icon(
                Icons.info_outline,
                size: 16.sp,
                color: const Color(0xFF2830F2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34.h,
          child: TextFormField(
            controller: _dataOrcamentoController,
            enabled: false, // Campo sempre desabilitado
            decoration: InputDecoration(
              hintText: 'Data de geração do orçamento',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              fillColor: Colors.grey[100],
              filled: true,
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Validade do orçamento
        Row(
          children: [
            Text(
              'Validade do orçamento',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data até quando o orçamento é válido'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Icon(
                Icons.info_outline,
                size: 16.sp,
                color: const Color(0xFF2830F2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34.h,
          child: TextFormField(
            controller: _validadeOrcamentoController,
            decoration: InputDecoration(
              hintText: 'Selecione a data de validade',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF117BBD)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            readOnly: true,
            onTap: () async {
              // Abre o seletor de data
              final DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: widget.budget.dataValidade ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (selectedDate != null) {
                _validadeOrcamentoController.text = selectedDate.toString().split(' ')[0];
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status do orçamento dropdown
        Text(
          'Status do orçamento',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34.h,
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF117BBD)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            items: const [
              DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
              DropdownMenuItem(value: 'não aprovado', child: Text('Não aprovado')),
              DropdownMenuItem(value: 'aprovado', child: Text('Aprovado')),
              DropdownMenuItem(value: 'expirado', child: Text('Expirado')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStatus = newValue;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Arquivado dropdown
        Text(
          'Arquivado',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34.h,
          child: DropdownButtonFormField<bool>(
            value: _isArchived,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF117BBD)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            items: const [
              DropdownMenuItem(value: false, child: Text('Não')),
              DropdownMenuItem(value: true, child: Text('Sim')),
            ],
            onChanged: (bool? newValue) {
              if (newValue != null) {
                setState(() {
                  _isArchived = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: ElevatedButton(
        onPressed: () async {
          await _handleSaveChanges();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF56B34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'Salvar Alterações',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSaveChanges() async {
    try {
      // Validate validity date
      final validadeStr = _validadeOrcamentoController.text;
      if (validadeStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a validade do orçamento')),
        );
        return;
      }

      // Parse and validate date
      final hoje = DateTime.now();
      final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
      final parts = validadeStr.split('-');
      DateTime? validade;
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          validade = DateTime(y, m, d);
        }
      }
      if (validade == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data de validade inválida')),
        );
        return;
      }
      final dias = validade.difference(hojeDate).inDays;
      if (dias < 1 || dias > 365) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Validade deve estar entre 1 e 365 dias')),
        );
        return;
      }

      // Collect product selections
      final prodStore = Modular.get<ProductStore>();
      final allProducts = prodStore.allProducts;
      final productSelections = allProducts.map((p) => ProductSelectionDto(
        produtoId: p.id,
        selected: prodStore.isSelected(p.id),
        price: p.valor,
      )).toList();

      // Prepare update data
      final updateData = {
        'id': widget.budget.id,
        'diasValidade': dias,
        'status': _selectedStatus,
        'arquivado': _isArchived,
        'total': prodStore.total,
        'products': productSelections.map((p) => p.toMap()).toList(),
      };

      print('📋 Dados de atualização do orçamento:');
      print('   ID: ${widget.budget.id}');
      print('   Dias validade: $dias');
      print('   Status: $_selectedStatus');
      print('   Arquivado: $_isArchived');
      print('   Total: ${prodStore.total}');
      print('   Produtos selecionados: ${productSelections.length}');

      // Call update service
      final service = Modular.get<BudgetService>();
      final result = await service.atualizar(widget.budget.id, updateData);
      
      print('✅ Resultado da atualização: $result');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alterações salvas com sucesso!'),
          backgroundColor: Color(0xFF56B34A),
        ),
      );

      // Navigate back to budget list
      Modular.to.pushNamedAndRemoveUntil('/budget/list', (route) => false);

    } catch (e) {
      print('❌ Erro ao salvar alterações: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }
}
