import 'package:mobx/mobx.dart';
import '../../../budget/external/services/budget_service.dart';
import './product_store.dart';
import 'package:multimidiaapp/entities/censo_entity.dart';

part 'budget_edit_store.g.dart';

class BudgetEditStore = _BudgetEditStore with _$BudgetEditStore;

abstract class _BudgetEditStore with Store {
  final BudgetService _budgetService;
  final ProductStore _productStore;

  _BudgetEditStore(this._budgetService, this._productStore);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  Map<String, dynamic>? budgetData;

  @observable
  Map<String, dynamic>? censoDataRaw;

  @observable
  CensoData? censoData;

  @action
  Future<void> loadBudgetDetails(int budgetId) async {
    isLoading = true;
    error = null;
    
    try {
      print('🔄 Carregando detalhes do orçamento ID: $budgetId');
      
      // Buscar detalhes completos do orçamento via API
      final response = await _budgetService.buscarPorId(budgetId);
      
      // Extrair dados se vier com chave 'dados'
      if (response.containsKey('dados')) {
        budgetData = response['dados'] as Map<String, dynamic>;
      } else {
        budgetData = response;
      }
      
      print('📋 Dados completos do orçamento carregados:');
      print('   Categorias: ${budgetData?['categorias']?.length ?? 0}');
      print('   Cidades: ${budgetData?['cidades']?.length ?? 0}');
      
      // Carregar dados do censo escolar
      _loadCensoData();
      
      // Carregar produtos organizados por categorias/subcategorias
      _loadProductsFromApi();
      
      print('✅ Detalhes do orçamento carregados com sucesso');
    } catch (e) {
      print('❌ Erro ao carregar detalhes do orçamento: $e');
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void _loadProductsFromApi() {
    print('🚀 _loadProductsFromApi() chamado');
    print('📦 budgetData keys: ${budgetData?.keys.toList()}');
    
    int totalProdutos = 0;
    int produtosSelecionados = 0;
    
    // Verificar se tem estrutura organizada (categorias) ou flat (produtos)
    if (budgetData?['categorias'] != null && budgetData!['categorias'] is List) {
      // Formato NOVO: categorias organizadas
      final categorias = budgetData!['categorias'] as List;
      print('🔍 Processando ${categorias.length} categorias do orçamento (formato novo)...');
      
      for (final categoria in categorias) {
        final subcategorias = categoria['subcategorias'] as List? ?? [];
        
        for (final subcategoria in subcategorias) {
          final subcategoriaId = subcategoria['id'] as int;
          final produtos = subcategoria['produtos'] as List? ?? [];
          
          for (final produto in produtos) {
            final produtoId = produto['id'] as int?;
            final selecionado = produto['selecionado'] as bool? ?? false;
            
            if (produtoId != null) {
              totalProdutos++;
              
              // Adicionar subcategoria_id ao produto (pois a API não envia)
              final produtoComSubcategoria = Map<String, dynamic>.from(produto);
              produtoComSubcategoria['subcategoria_id'] = subcategoriaId;
              
              // Adicionar produto na ProductStore se não existir
              if (!_productStore.produtosPorId.containsKey(produtoId)) {
                _productStore.addProductFromApi(produtoComSubcategoria);
                print('   ✅ Produto $produtoId adicionado na subcategoria $subcategoriaId');
              }
              
              // Marcar/desmarcar produto
              _productStore.setSelected(produtoId, selecionado);
              print('   📌 Produto $produtoId marcado como ${selecionado ? "SELECIONADO" : "NÃO SELECIONADO"}');
              
              if (selecionado) {
                produtosSelecionados++;
              }
            }
          }
        }
      }
    } else if (budgetData?['produtos'] != null && budgetData!['produtos'] is List) {
      // Formato ANTIGO: produtos flat (compatibilidade)
      final produtos = budgetData!['produtos'] as List;
      print('🔍 Processando ${produtos.length} produtos do orçamento (formato antigo)...');
      
      for (final produto in produtos) {
        final produtoId = produto['id'] as int?;
        final selecionado = produto['selecionado'] as bool? ?? false;
        
        if (produtoId != null) {
          totalProdutos++;
          
          // Garantir que tem subcategoria_id
          if (!produto.containsKey('subcategoria_id') && produto.containsKey('pro_subcategoria_id')) {
            produto['subcategoria_id'] = produto['pro_subcategoria_id'];
          }
          
          // Adicionar produto na ProductStore se não existir
          if (!_productStore.produtosPorId.containsKey(produtoId)) {
            _productStore.addProductFromApi(produto);
          }
          
          // Marcar/desmarcar produto
          _productStore.setSelected(produtoId, selecionado);
          
          if (selecionado) {
            produtosSelecionados++;
          }
        }
      }
    }
    
    print('📊 Resumo:');
    print('   Total de produtos: $totalProdutos');
    print('   Produtos selecionados: $produtosSelecionados');
    print('   Produtos na ProductStore: ${_productStore.produtosPorId.length}');
  }

  @action
  void _loadCensoData() {
    if (budgetData?['cidades'] != null && budgetData!['cidades'] is List) {
      final cidades = budgetData!['cidades'] as List;
      if (cidades.isNotEmpty) {
        final cidadeData = cidades[0] as Map<String, dynamic>;
        censoDataRaw = cidadeData;
        
        print('📍 Cidade principal: ${cidadeData['nome']}');
        print('📊 Indicadores: ${cidadeData['indicadores']?.length ?? 0}');
        
        // Converter para CensoData
        try {
          final indicadores = cidadeData['indicadores'] as List?;
          if (indicadores != null && indicadores.isNotEmpty) {
            // Converter indicadores para o formato esperado por CidadeData
            final indicesEtapa = indicadores.map((ind) => {
              'indice_etapa_id': ind['ine_indice_etapa_id'],
              'nome_etapa': 'Etapa ${ind['ine_indice_etapa_id']}',
              'valor': ind['valor'],
            }).toList();
            
            final cidadeFormatted = {
              'id': cidadeData['id'],
              'nome': cidadeData['nome'],
              'estado_id': 0,
              'indices_etapa': indicesEtapa,
            };
            
            censoData = CensoData(
              totalStudents: indicesEtapa.fold(0, (sum, item) => sum + (item['valor'] as num).toInt()),
              censusYear: '2024',
              groups: [],
              cidadeData: CidadeData.fromJson(cidadeFormatted),
            );
            
            print('✅ CensoData convertido com sucesso');
            print('   Total de estudantes: ${censoData?.totalStudents}');
          } else {
            print('⚠️ Sem indicadores para processar');
          }
        } catch (e) {
          print('❌ Erro ao converter CensoData: $e');
        }
      }
    }
  }

  @action
  void reset() {
    budgetData = null;
    censoDataRaw = null;
    censoData = null;
    error = null;
    isLoading = false;
  }

  // Getters convenientes
  List<dynamic> get produtos => budgetData?['produtos'] ?? [];
  List<dynamic> get cidades => budgetData?['cidades'] ?? [];
  Map<String, dynamic>? get cidadePrincipal => 
    cidades.isNotEmpty ? cidades[0] : null;
}
