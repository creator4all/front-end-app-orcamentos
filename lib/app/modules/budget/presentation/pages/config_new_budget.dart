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
import '../../presentation/stores/product_store.dart';
import '../../presentation/stores/card_selection_store.dart';
import '../../presentation/stores/budget_edit_store.dart';
import '../../external/services/budget_service.dart';


class ConfigNewBudgetPage extends StatefulWidget {
  final int budgetId;
  
  const ConfigNewBudgetPage({super.key, required this.budgetId});

  @override
  State<ConfigNewBudgetPage> createState() => _ConfigNewBudgetPageState();
}

class _ConfigNewBudgetPageState extends State<ConfigNewBudgetPage> with WidgetsBindingObserver {
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
  String _budgetStatus = 'rascunho'; // Armazenar status do orçamento

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dataOrcamentoController.text = DateTime.now().toString().split(' ')[0];
    final defaultValid = DateTime.now().add(const Duration(days: 60));
    _validadeOrcamentoController.text = defaultValid.toString().split(' ')[0];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Excluir rascunho se app for minimizado/fechado
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _deleteRascunhoIfNeeded();
    }
  }

  Future<void> _deleteRascunhoIfNeeded() async {
    if (_budgetStatus == 'rascunho') {
      try {
        final budgetService = Modular.get<BudgetService>();
        await budgetService.excluir(widget.budgetId);
        print('🗑️ Rascunho ${widget.budgetId} excluído automaticamente');
      } catch (e) {
        print('⚠️ Erro ao excluir rascunho: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar a store de seleção de cards
    cardStore = Modular.get<CardSelectionStore>();
    // Carregar orçamento rascunho e dados necessários
    _loadBudgetAndInitialData();
  }

  // Método para carregar orçamento rascunho e todos os dados necessários
  Future<void> _loadBudgetAndInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
    });
    
    try {
      print('🔄 Iniciando carregamento do orçamento rascunho ID: ${widget.budgetId}');
      
      // 1. Carregar orçamento rascunho usando BudgetEditStore
      final budgetEditStore = Modular.get<BudgetEditStore>();
      await budgetEditStore.loadBudgetDetails(widget.budgetId);
      
      // Atualizar status local
      _budgetStatus = budgetEditStore.budgetData?['status'] as String? ?? 'rascunho';
      print('📊 Status do orçamento: $_budgetStatus');
      
      // Atualizar censo data local se disponível
      if (budgetEditStore.censoData != null) {
        setState(() {
          _cachedCensoData = budgetEditStore.censoData;
        });
        print('✅ Dados do censo carregados e atualizados na UI');
        print('   Total de estudantes: ${budgetEditStore.censoData?.totalStudents}');
      }
      
      // Se for um orçamento rascunho (novo), marcar todos os produtos como selecionados por padrão
      if (_budgetStatus == 'rascunho') {
        final prodStore = Modular.get<ProductStore>();
        final categorias = budgetEditStore.budgetData?['categorias'] as List? ?? [];
        
        print('📦 Marcando todos os produtos como selecionados (orçamento rascunho)...');
        int totalProdutos = 0;
        int totalCheckboxes = 0;
        
        for (final categoria in categorias) {
          final categoriaNome = categoria['nome'] as String;
          final subcategorias = categoria['subcategorias'] as List? ?? [];
          
          // Se é categoria de Livros, marcar o card principal
          if (categoriaNome.toLowerCase().contains('livro')) {
            cardStore.setMainCardSelected('livros', true);
            totalCheckboxes++; // +1 checkbox visível (Livros)
            print('✅ Card "Livros" marcado');
          }
          
          // Para cada subcategoria
          for (final subcategoria in subcategorias) {
            final subcategoriaId = subcategoria['id'] as int;
            final produtos = subcategoria['produtos'] as List? ?? [];
            
            // Se não é categoria de Livros, marcar a subcategoria individualmente
            if (!categoriaNome.toLowerCase().contains('livro')) {
              cardStore.setSubcategorySelected(subcategoriaId, true);
              totalCheckboxes++; // +1 checkbox visível (subcategoria de Tecnologias)
              print('✅ Subcategoria "${subcategoria['nome']}" marcada');
            }
            
            // Marcar todos os produtos da subcategoria
            for (final produto in produtos) {
              final produtoId = produto['id'] as int?;
              if (produtoId != null) {
                prodStore.setSelected(produtoId, true);
                totalProdutos++;
              }
            }
          }
        }
        
        print('✅ $totalProdutos produtos marcados como selecionados');
        print('✅ $totalCheckboxes checkboxes visíveis marcados na tela');
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Excluir rascunho ao voltar
        await _deleteRascunhoIfNeeded();
        return true;
      },
      child: Scaffold(
        appBar: CustomTopBar(
          title: 'Novo orçamento',
          showBackButton: true,
          onBackPressed: () async {
            // Excluir rascunho ao clicar no botão voltar
            await _deleteRascunhoIfNeeded();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
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
              // Usar Observer para reagir às mudanças na BudgetEditStore
              Observer(
                builder: (_) {
                  final budgetEditStore = Modular.get<BudgetEditStore>();
                  
                  // Priorizar dados da store, depois cache local
                  final censo = budgetEditStore.censoData ?? _cachedCensoData;
                  
                  return SchoolCensus(
                    leadingIcon: const Icon(Icons.school, color: Colors.black54),
                    title: 'Censo Escolar',
                    info1: censo != null
                        ? 'estudantes: ${censo.totalStudents}'
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
                        // Atualizar também na store
                        budgetEditStore.censoData = updatedCenso;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              Observer(
                builder: (_) {
                  final budgetEditStore = Modular.get<BudgetEditStore>();
                  final prodStore = Modular.get<ProductStore>();
                  
                  // Verificar se ainda está carregando
                  if (budgetEditStore.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Verificar se há erro
                  if (budgetEditStore.error != null) {
                    return Center(
                      child: Text('Erro: ${budgetEditStore.error}'),
                    );
                  }
                  
                  // Usar dados das categorias que vieram da API do orçamento
                  final categorias = budgetEditStore.budgetData?['categorias'] as List? ?? [];
                  
                  if (categorias.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma categoria encontrada'),
                    );
                  }

                  // Separar categorias
                  Map<String, dynamic>? livrosCategoria;
                  Map<String, dynamic>? tecnologiasCategoria;
                  
                  for (final categoria in categorias) {
                    final categoriaNome = categoria['nome'] as String;
                    if (categoriaNome.toLowerCase().contains('livro')) {
                      livrosCategoria = categoria;
                    } else if (categoriaNome.toLowerCase().contains('tecnologia')) {
                      tecnologiasCategoria = categoria;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seção Livros (agrupada)
                      if (livrosCategoria != null) ...[
                        Observer(
                          builder: (_) {
                            // Acessar selectedIds para forçar reação do Observer
                            final _ = prodStore.selectedIds.length;
                            
                            final subcategorias = livrosCategoria!['subcategorias'] as List? ?? [];
                            
                            // Calcular totais
                            int totalProdutos = 0;
                            int produtosSelecionados = 0;
                            double valorTotal = 0.0;
                            
                            for (final sub in subcategorias) {
                              final subId = sub['id'] as int;
                              totalProdutos += prodStore.getTotalCountForSubcategory(subId);
                              produtosSelecionados += prodStore.getSelectedCountForSubcategory(subId);
                              valorTotal += prodStore.getTotalValueForSubcategory(subId);
                            }
                            
                            return ProductCategory(
                              categoryIcon: const Icon(Icons.menu_book, color: Colors.black54),
                              title: 'Livros',
                              value: 'R\$ ${valorTotal.toStringAsFixed(2)}',
                              selectedCount: produtosSelecionados,
                              totalCount: totalProdutos,
                              isSelected: produtosSelecionados > 0,
                              onCheckboxChanged: (value) {
                                // Marcar/desmarcar todos os produtos de livros
                                for (final sub in subcategorias) {
                                  final subId = sub['id'] as int;
                                  prodStore.selectAllForSubcategory(subId, value ?? false);
                                }
                              },
                              onActionTap: () async {
                                await BooksModal.show(
                                  context: context,
                                  categoriaId: livrosCategoria!['id'] as int,
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                      ],
                      
                      // Label Tecnologias
                      if (tecnologiasCategoria != null) ...[
                        Text(
                          'Tecnologias',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF117BBD),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        
                        // Subcategorias de Tecnologias
                        ...((tecnologiasCategoria['subcategorias'] as List?) ?? []).map((sub) {
                          final subId = sub['id'] as int;
                          final subNome = sub['nome'] as String;
                          
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Observer(
                              builder: (_) {
                                // Acessar selectedIds para forçar reação do Observer
                                final _ = prodStore.selectedIds.length;
                                
                                final selectedCount = prodStore.getSelectedCountForSubcategory(subId);
                                final totalCount = prodStore.getTotalCountForSubcategory(subId);
                                final totalValue = prodStore.getTotalValueForSubcategory(subId);
                                
                                return ProductCategory(
                                  categoryIcon: const Icon(Icons.widgets, color: Colors.black54),
                                  title: subNome,
                                  value: 'R\$ ${totalValue.toStringAsFixed(2)}',
                                  selectedCount: selectedCount,
                                  totalCount: totalCount,
                                  isSelected: selectedCount > 0,
                                  onCheckboxChanged: (value) {
                                    // Marcar/desmarcar todos os produtos desta subcategoria
                                    prodStore.selectAllForSubcategory(subId, value ?? false);
                                  },
                                  onActionTap: () async {
                                    await TechnologyProductsModal.show(
                                      context: context,
                                      subcategoriaId: subId,
                                      title: subNome,
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ],
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

                    final prodStore = Modular.get<ProductStore>();
                    final service = Modular.get<BudgetService>();
                    
                    print('📋 Salvando orçamento ID: ${widget.budgetId}');
                    print('   Total: ${prodStore.total}');
                    print('   Produtos selecionados: ${prodStore.selectedIds.length}');
                    print('   Dias de validade: $dias');
                    
                    try {
                      // Coletar TODOS os produtos com seus estados de seleção
                      final todosProdutos = prodStore.produtosPorId.values.map((produto) {
                        final selecionado = prodStore.selectedIds.contains(produto.id);
                        return {
                          'produto_id': produto.id,
                          'selecionado': selecionado,
                        };
                      }).toList();
                      
                      print('📤 Enviando ${todosProdutos.length} produtos para o backend');
                      print('📤 Produtos selecionados: ${prodStore.selectedIds.length}');
                      print('📤 Produtos não selecionados: ${todosProdutos.length - prodStore.selectedIds.length}');
                      
                      // Atualizar orçamento com status "pendente", total e TODOS os produtos
                      await service.atualizar(widget.budgetId, {
                        'orc_status': 'pendente',
                        'orc_total': prodStore.total,
                        'orc_dias_validade': dias,
                        'produtos': todosProdutos, // TODOS os produtos, não apenas os selecionados
                      });
                      
                      // Marcar como não-rascunho para não excluir
                      _budgetStatus = 'pendente';
                      
                      print('✅ Orçamento ${widget.budgetId} salvo com sucesso');
                      print('   Status: pendente');
                      print('   Total: R\$ ${prodStore.total}');
                      print('   Produtos enviados: ${todosProdutos.length}');
                      print('   Produtos selecionados: ${prodStore.selectedIds.length}');
                      
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orçamento salvo com sucesso!'),
                          backgroundColor: Color(0xFF56B34A),
                        ),
                      );
                      
                      // Redirecionar para a tela principal de orçamentos
                      Modular.to.pushNamedAndRemoveUntil('/budget/', (route) => false);
                    } catch (e) {
                      print('❌ Erro ao salvar orçamento: $e');
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
      ),
    );
  }
}
