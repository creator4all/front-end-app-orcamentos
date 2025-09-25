import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/budget_summary_card.dart';
import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/product_category.dart';
import '../../../../shared/widgets/school_census.dart';
import 'package:multimidiaapp/entities/censo_entity.dart';
import '../../../../shared/widgets/books_modal.dart';
import '../../../../shared/widgets/technology_products_modal.dart';
import '../../presentation/stores/category_store.dart';
import '../../presentation/stores/subcategory_store.dart';
import '../../presentation/stores/product_store.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product_selection.dart';
import '../../domain/models/budget_create.dart';
import '../../external/services/budget_service.dart';


class ConfigNewBudgetPage extends StatefulWidget {
  const ConfigNewBudgetPage({super.key});

  @override
  State<ConfigNewBudgetPage> createState() => _ConfigNewBudgetPageState();
}

class _ConfigNewBudgetPageState extends State<ConfigNewBudgetPage> {
  // Cache for the censo data to persist between screen navigations
  CensoData? _cachedCensoData;

  bool isLivrosSelected = true;
  bool isPortalSelected = false;
  bool isGamificacaoSelected = false;
  bool isAvaliacaoSelected = false;
  bool isServicosSelected = false;

  // Estado para controlar subcategorias selecionadas (id -> selecionado)
  final Map<int, bool> _selectedSubcategories = {};

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataOrcamentoController.text = DateTime.now().toString().split(' ')[0];
    final defaultValid = DateTime.now().add(const Duration(days: 60));
    _validadeOrcamentoController.text = defaultValid.toString().split(' ')[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Modular.get<CategoryStore>().fetchCategorias();
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
        title: 'Novo orçamento',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Observer(builder: (_) {
                final prodStore = Modular.get<ProductStore>();
                return BudgetSummaryCard(
                  budgetValue: prodStore.total,
                  selectedProductsCount: prodStore.selectedCount,
                );
              }),
              const SizedBox(height: 12),
              // Use a StatefulBuilder to be able to update this widget when census data changes
              StatefulBuilder(
                builder: (context, setBuilderState) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final censo = _cachedCensoData ??
                      (args != null ? args['censo'] as CensoData? : null);
                  return SchoolCensus(
                    leadingIcon:
                        const Icon(Icons.school, color: Colors.black54),
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
                        final updatedCenso =
                            result['updatedCenso'] as CensoData;
                        setState(() {
                          _cachedCensoData = updatedCenso;
                        });
                        setBuilderState(() {});
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              Observer(
                builder: (_) {
                  final catStore = Modular.get<CategoryStore>();
                  final subStore = Modular.get<SubcategoryStore>();
                  
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
                  final outras = catStore.categorias
                      .where((c) => c.nome.toLowerCase().trim() != 'livros')
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (livrosCat.id != -1)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Observer(
                            builder: (_) {
                              final selectedSubcategoriesCount = _selectedSubcategories.values.where((selected) => selected).length;
                              final totalSubcategories = _selectedSubcategories.length;
                              final prodStore = Modular.get<ProductStore>();
                              final totalValue = prodStore.total;
                              
                              return ProductCategory(
                                categoryIcon:
                                    const Icon(Icons.menu_book, color: Colors.black54),
                                title: 'Livros',
                                value: 'R\$ ${totalValue.toStringAsFixed(2)}',
                                selectedCount: selectedSubcategoriesCount,
                                totalCount: totalSubcategories,
                                isSelected: isLivrosSelected,
                                onCheckboxChanged: (bool? value) {
                                  setState(() {
                                    isLivrosSelected = value ?? false;
                                    // Quando marcar livros, desmarcar todas as subcategorias
                                    if (value == true) {
                                      _selectedSubcategories.clear();
                                      prodStore.unselectAll(); // Desmarcar todos os produtos
                                    }
                                  });
                                },
                                onActionTap: () async {
                                  await BooksModal.show(
                                    context: context,
                                    categoriaId: livrosCat.id,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      Text(
                        'Tecnologias',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF117BBD),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Para cada categoria que não é livros, buscar e mostrar suas subcategorias
                      ...outras.map((cat) {
                        return Observer(
                          builder: (_) {
                            // Buscar subcategorias desta categoria
                            if (subStore.lastCategoriaId != cat.id && !subStore.isLoading) {
                              subStore.fetchSubcategorias(cat.id);
                            }
                            
                            if (subStore.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            // Inicializar estado das subcategorias se ainda não foi feito
                            if (!_selectedSubcategories.containsKey(subStore.subcategorias.firstOrNull?.id ?? -1)) {
                              for (final sub in subStore.subcategorias) {
                                if (!_selectedSubcategories.containsKey(sub.id)) {
                                  _selectedSubcategories[sub.id] = false;
                                }
                              }
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Mostrar cada subcategoria como um ProductCategory
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
                                          isSelected: _selectedSubcategories[sub.id] ?? false,
                                          onCheckboxChanged: (bool? value) {
                                            setState(() {
                                              final isCurrentlySelected = _selectedSubcategories[sub.id] ?? false;
                                              _selectedSubcategories[sub.id] = !isCurrentlySelected;
                                              // Quando marcar a subcategoria, desmarcar todos os produtos dela
                                              if (!isCurrentlySelected) {
                                                prodStore.unselectAllForSubcategory(sub.id);
                                              }
                                            });
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
                                }),
                              ],
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),

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
                      // TODO: Mostrar informação sobre a data do orçamento
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                      // TODO: Mostrar informação sobre a validade do orçamento
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      _validadeOrcamentoController.text =
                          selectedDate.toString().split(' ')[0];
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () async {
                    final validadeStr = _validadeOrcamentoController.text;
                    if (validadeStr.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecione a validade do orçamento')),
                      );
                      return;
                    }
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

                    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                    final cidadeId = args?['cidadeId'] as int? ?? args?['cidade_id'] as int? ?? 0;
                    final usuarioId = args?['usuarioId'] as int? ?? args?['usuario_id'] as int? ?? 0;
                    if (cidadeId <= 0 || usuarioId <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dados de cidade/usuário ausentes')),
                      );
                      return;
                    }

                    final prodStore = Modular.get<ProductStore>();
                    final allProducts = prodStore.produtos;
                    final productSelections = allProducts.map((p) => ProductSelectionDto(
                      produtoId: p.id,
                      selected: prodStore.isSelected(p.id),
                      price: p.valor,
                    )).toList();

                    final service = Modular.get<BudgetService>();
                    try {
                      await service.criar(BudgetCreateDto(
                        diasValidade: dias,
                        usuarioId: usuarioId,
                        cidades: [cidadeId],
                        cidadePrincipalId: cidadeId,
                        total: prodStore.total,
                        products: productSelections,
                      ));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orçamento salvo com sucesso!'),
                          backgroundColor: Color(0xFF56B34A),
                        ),
                      );
                      Modular.to.pop();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF56B34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Salvar Orçamento',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Espaço no final para scroll
            ],
          ),
        ),
      ),
    );
  }
}
