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
import '../../presentation/stores/books_subcategory_store.dart';
import '../../presentation/stores/product_store.dart';
import '../../presentation/stores/card_selection_store.dart';
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

  // Usar a CardSelectionStore para gerenciar seleções
  late CardSelectionStore cardStore;
  // Propriedades de conveniência para facilitar o acesso ao estado
  bool get isLivrosSelected => cardStore.mainCardsSelection['livros'] ?? false;
  bool get isPortalSelected => cardStore.mainCardsSelection['portal'] ?? false;
  bool get isGamificacaoSelected => cardStore.mainCardsSelection['gamificacao'] ?? false;
  bool get isAvaliacaoSelected => cardStore.mainCardsSelection['avaliacao'] ?? false;
  bool get isServicosSelected => cardStore.mainCardsSelection['servicos'] ?? false;

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  bool _isLoadingInitialData = true;

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
    // Inicializar a store de seleção de cards
    cardStore = Modular.get<CardSelectionStore>();
    
    // Carregar todos os dados necessários
    _loadAllInitialData();
  }

  // Método para carregar todos os dados necessários ao abrir a tela
  Future<void> _loadAllInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
    });
    
    try {
      print('🔄 Iniciando carregamento de dados...');
      
      // 1. Carregar categorias primeiro
      final categoryStore = Modular.get<CategoryStore>();
      await categoryStore.fetchCategorias();
      print('✅ Categorias carregadas: ${categoryStore.categorias.length}');
      
      // 2. Encontrar categoria de Livros e Tecnologias
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
      
      // 3. Carregar subcategorias de Livros
      if (livrosCategory.id != -1) {
        final booksSubStore = Modular.get<BooksSubcategoryStore>();
        await booksSubStore.fetchSubcategorias(livrosCategory.id);
        print('✅ Subcategorias de Livros carregadas: ${booksSubStore.subcategorias.length}');
        
        // 4. Carregar produtos de todas as subcategorias de Livros
        final prodStore = Modular.get<ProductStore>();
        for (final sub in booksSubStore.subcategorias) {
          await prodStore.fetchProdutos(sub.id);
          print('✅ Produtos da subcategoria "${sub.nome}" carregados');
        }
      }
      
      // 5. Carregar subcategorias de Tecnologias
      if (tecnologiasCategory.id != -1) {
        final techSubStore = Modular.get<SubcategoryStore>();
        await techSubStore.fetchSubcategorias(tecnologiasCategory.id);
        print('✅ Subcategorias de Tecnologias carregadas: ${techSubStore.subcategorias.length}');
        
        // Subcategorias de tecnologias NÃO são registradas como pertencentes a um card principal
        // (cada uma é um checkbox individual na tela)
        
        // 6. Carregar produtos de todas as subcategorias de Tecnologias
        final prodStore = Modular.get<ProductStore>();
        for (final sub in techSubStore.subcategorias) {
          await prodStore.fetchProdutos(sub.id);
          print('✅ Produtos da subcategoria "${sub.nome}" carregados');
        }
      }
      
      print('🎉 Todos os dados iniciais carregados com sucesso!');
    } catch (e) {
      print('❌ Erro ao carregar dados iniciais: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }
  
  // Método para processar a seleção de subcategorias e produtos de livros
  Future<void> _processLivrosSelection(BooksSubcategoryStore booksSubStore, ProductStore prodStore, bool selected) async {
    // Para cada subcategoria de livros
    for (final sub in booksSubStore.subcategorias) {
      // Registrar que esta subcategoria pertence ao card "livros"
      cardStore.registerSubcategoryToMainCard(sub.id, 'livros');
      
      // Marcar/desmarcar a subcategoria (necessário para funcionalidade)
      cardStore.setSubcategorySelected(sub.id, selected);
      
      // Carregar produtos da subcategoria se necessário
      if (!prodStore.produtosPorSubcategoria.containsKey(sub.id)) {
        await prodStore.fetchProdutos(sub.id);
      }
      
      // Usar o novo método da ProductStore que garante isolamento por subcategoria
      prodStore.selectAllForSubcategory(sub.id, selected);
    }
  }

  // Não precisamos mais desta função, pois agora usamos cardStore.selectedCardsCount

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Novo orçamento',
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
              // Usar Observer para atualizar automaticamente quando a store mudar
              Observer(builder: (_) {
                final prodStore = Modular.get<ProductStore>();
                final cardSelectionStore = Modular.get<CardSelectionStore>();
                
                return BudgetSummaryCard(
                  budgetValue: prodStore.total,
                  selectedProductsCount: cardSelectionStore.visibleCheckboxesCount,
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
                  // Não carregamos o subStore aqui, cada seção terá sua própria store
                  
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
                      if (livrosCat.id != -1)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Observer(
                            builder: (_) {
                              final prodStore = Modular.get<ProductStore>();
                              final booksSubStore = Modular.get<BooksSubcategoryStore>();
                              
                              // Calcular contagem real de produtos de livros
                              int selectedProductsCount = 0;
                              int totalProductsCount = 0;
                              double totalValue = 0.0;
                              
                              for (final sub in booksSubStore.subcategorias) {
                                selectedProductsCount += prodStore.getSelectedCountForSubcategory(sub.id);
                                totalProductsCount += prodStore.getTotalCountForSubcategory(sub.id);
                                totalValue += prodStore.getTotalValueForSubcategory(sub.id);
                              }
                              
                              return ProductCategory(
                                categoryIcon:
                                    const Icon(Icons.menu_book, color: Colors.black54),
                                title: 'Livros',
                                value: 'R\$ ${totalValue.toStringAsFixed(2)}',
                                selectedCount: selectedProductsCount,
                                totalCount: totalProductsCount,
                                isSelected: isLivrosSelected,
                                onCheckboxChanged: (bool? value) {
                                  // Atualizar a store
                                  cardStore.setMainCardSelected('livros', value ?? false);
                                  
                                  // Obter as stores necessárias
                                  final booksSubStore = Modular.get<BooksSubcategoryStore>();
                                  final prodStore = Modular.get<ProductStore>();
                                  
                                  // Se não temos subcategorias carregadas, carregar primeiro
                                  if (booksSubStore.subcategorias.isEmpty && !booksSubStore.isLoading) {
                                    booksSubStore.fetchSubcategorias(livrosCat.id).then((_) async {
                                      // Depois de carregar as subcategorias, marcar/desmarcar todas
                                      await _processLivrosSelection(booksSubStore, prodStore, value ?? false);
                                    });
                                  } else {
                                    // Já temos subcategorias carregadas, marcar/desmarcar todas
                                    _processLivrosSelection(booksSubStore, prodStore, value ?? false);
                                  }
                                },
                                onActionTap: () async {
                                  // Usar BooksModal para categoria de livros, que mostra subcategorias
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
                      // Seção de Tecnologias
                      Observer(
                        builder: (_) {
                          // Usar SubcategoryStore apenas para Tecnologias
                          final subStore = Modular.get<SubcategoryStore>();
                          
                          // Carregar subcategorias de tecnologias
                          if (tecnologiasCat.id > 0 && subStore.lastCategoriaId != tecnologiasCat.id && !subStore.isLoading) {
                            subStore.fetchSubcategorias(tecnologiasCat.id);
                          }
                          
                          if (subStore.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          // Inicializar estado das subcategorias se ainda não foi feito
                          for (final sub in subStore.subcategorias) {
                            if (!cardStore.subcategoriesSelection.containsKey(sub.id)) {
                              cardStore.setSubcategorySelected(sub.id, false);
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
                                        isSelected: cardStore.subcategoriesSelection[sub.id] ?? false,
                                        onCheckboxChanged: (bool? value) {
                                          // Determinar o novo valor de seleção (inverso do atual)
                                          final isCurrentlySelected = cardStore.subcategoriesSelection[sub.id] ?? false;
                                          final newSelection = !isCurrentlySelected;
                                          
                                          // Atualizar a seleção da subcategoria na store
                                          cardStore.setSubcategorySelected(sub.id, newSelection);
                                          
                                          // Usar o novo método da ProductStore que garante isolamento por subcategoria
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
                    
                    // Extrair dados da cidade e estado enviados da tela anterior
                    final cidade = args?['cidade'];
                    final estado = args?['estado'];
                    
                    if (cidade == null || estado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dados de cidade/estado ausentes')),
                      );
                      return;
                    }
                    
                    // Extrair IDs dos objetos
                    final cidadeId = cidade.id as int? ?? 0;
                    final usuarioId = 1; // TODO: Implementar usuário logado
                    
                    print('🏙️ Cidade: ${cidade.nome} (ID: $cidadeId)');
                    print('🏛️ Estado: ${estado.nome}');
                    print('👤 Usuario ID: $usuarioId');
                    
                    if (cidadeId <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID da cidade inválido')),
                      );
                      return;
                    }

                    final prodStore = Modular.get<ProductStore>();
                    final allProducts = prodStore.allProducts;
                    final productSelections = allProducts.map((p) => ProductSelectionDto(
                      produtoId: p.id,
                      selected: prodStore.isSelected(p.id),
                      price: p.valor,
                    )).toList();

                    final service = Modular.get<BudgetService>();
                    
                    // Log dos dados que serão enviados
                    final budgetData = BudgetCreateDto(
                      diasValidade: dias,
                      usuarioId: usuarioId,
                      cidades: [cidadeId],
                      cidadePrincipalId: cidadeId,
                      total: prodStore.total,
                      products: productSelections,
                    );
                    
                    print('📋 Dados do orçamento a serem enviados:');
                    print('   Dias validade: $dias');
                    print('   Usuario ID: $usuarioId');
                    print('   Cidade ID: $cidadeId');
                    print('   Total: ${prodStore.total}');
                    print('   Produtos selecionados: ${productSelections.length}');
                    print('   JSON completo: ${budgetData.toMap()}');
                    
                    try {
                      final result = await service.criar(budgetData);
                      print('✅ Orçamento criado com sucesso: $result');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orçamento salvo com sucesso!'),
                          backgroundColor: Color(0xFF56B34A),
                        ),
                      );
                      // Redirecionar para a tela principal de orçamentos
                      Modular.to.pushNamedAndRemoveUntil('/budget/list', (route) => false);
                    } catch (e) {
                      print('❌ Erro ao criar orçamento: $e');
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
