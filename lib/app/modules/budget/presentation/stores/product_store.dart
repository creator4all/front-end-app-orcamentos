import 'package:mobx/mobx.dart';
import '../../domain/models/product.dart';
import '../../external/services/product_service.dart';

part 'product_store.g.dart';

class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  final ProductService _service;
  _ProductStore(this._service);

  @observable
  List<ProductDto> produtos = [];

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  int? lastSubcategoriaId;

  @observable
  ObservableSet<int> selectedIds = ObservableSet<int>();

  @computed
  double get total => produtos
      .where((p) => selectedIds.contains(p.id))
      .fold(0.0, (sum, p) => sum + (p.valor ?? 0.0));

  @computed
  int get selectedCount => selectedIds.length;

  @action
  Future<void> fetchProdutos(int subcategoriaId) async {
    isLoading = true;
    error = null;
    lastSubcategoriaId = subcategoriaId;
    try {
      produtos = await _service.listarPorSubcategoria(subcategoriaId);
      print('Carregados ${produtos.length} produtos para subcategoria $subcategoriaId');
      
      // Verificar se todos os produtos têm subcategoriaId definido corretamente
      final produtosSemSubcat = produtos.where((p) => p.subcategoriaId != subcategoriaId).toList();
      if (produtosSemSubcat.isNotEmpty) {
        print('ALERTA: ${produtosSemSubcat.length} produtos com subcategoriaId incorreto após carregamento');
      }
      
      // Executar diagnóstico após carregamento (em modo debug)
      checkInvalidProducts();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void setSelected(int productId, bool selected) {
    // Verificar se o produto existe na lista atual
    final produtosList = produtos.where((p) => p.id == productId).toList();
    
    if (produtosList.isEmpty) {
      print('Tentativa de selecionar produto inexistente: $productId');
      return;
    }
    
    final produto = produtosList.first;
    
    // Verificar se o produto tem subcategoriaId válido
    if (produto.subcategoriaId == null) {
      print('Tentativa de selecionar produto com subcategoriaId nulo: $productId');
      return;
    }
    
    // Aplicar a seleção
    if (selected) {
      selectedIds.add(productId);
      print('Selecionado produto $productId da subcategoria ${produto.subcategoriaId}');
    } else {
      selectedIds.remove(productId);
      print('Desmarcado produto $productId da subcategoria ${produto.subcategoriaId}');
    }
  }

  bool isSelected(int productId) => selectedIds.contains(productId);

  @action
  void unselectAllForSubcategory(int subcategoriaId) {
    // Filtrar produtos válidos para esta subcategoria
    final subcategoryProducts = produtos
        .where((p) => p.subcategoriaId != null && p.subcategoriaId == subcategoriaId)
        .toList();
    
    print('Desmarcando ${subcategoryProducts.length} produtos da subcategoria $subcategoriaId');
    
    // Remover seleção de todos os produtos válidos desta subcategoria
    for (final product in subcategoryProducts) {
      selectedIds.remove(product.id);
    }
  }

  @action
  void unselectAll() {
    selectedIds.clear();
  }

  // Método auxiliar para validar se um produto pertence a uma subcategoria
  bool _isValidProductForSubcategory(ProductDto product, int subcategoriaId) {
    if (product.subcategoriaId == null) return false;
    return product.subcategoriaId == subcategoriaId;
  }

  @action
  void selectAllForSubcategory(int subcategoriaId, bool selected) {
    // Verificar se os produtos da subcategoria já estão carregados
    if (lastSubcategoriaId != subcategoriaId) {
      print('Produtos da subcategoria $subcategoriaId não estão carregados');
      return; // Não fazemos nada se os produtos não estiverem carregados
    }
    
    print('Executando selectAllForSubcategory para subcategoria $subcategoriaId, selected=$selected');
    
    // Filtrar produtos válidos para esta subcategoria (com subcategoriaId não nulo e correto)
    final validProducts = produtos
        .where((p) => _isValidProductForSubcategory(p, subcategoriaId))
        .toList();
    
    print('Produtos válidos para subcategoria $subcategoriaId: ${validProducts.length}');
    
    if (validProducts.isEmpty) {
      print('Nenhum produto válido encontrado para subcategoria $subcategoriaId');
      return; // Não fazemos nada se não houver produtos válidos
    }
    
    // Obter os IDs dos produtos válidos
    final validProductIds = validProducts
        .map((p) => p.id)
        .toSet(); // Usamos Set para garantir unicidade
    
    // Aplicar a seleção apenas aos produtos válidos desta subcategoria
    if (selected) {
      // Adicionar apenas os produtos válidos desta subcategoria
      selectedIds.addAll(validProductIds);
      print('Adicionados ${validProductIds.length} produtos da subcategoria $subcategoriaId');
    } else {
      // Remover apenas os produtos válidos desta subcategoria
      selectedIds.removeAll(validProductIds);
      print('Removidos ${validProductIds.length} produtos da subcategoria $subcategoriaId');
    }
    
    // Verificar se houve algum vazamento para outras subcategorias
    for (final p in produtos) {
      if (p.subcategoriaId != null && 
          p.subcategoriaId != subcategoriaId && 
          selectedIds.contains(p.id)) {
        print('ALERTA: Produto ${p.id} da subcategoria ${p.subcategoriaId} está selecionado após manipular subcategoria $subcategoriaId');
      }
    }
  }

  int getSelectedCountForSubcategory(int subcategoriaId) {
    // Contar apenas produtos válidos para esta subcategoria
    final count = produtos
        .where((p) => 
            p.subcategoriaId != null && 
            p.subcategoriaId == subcategoriaId && 
            selectedIds.contains(p.id))
        .length;
    
    print('getSelectedCountForSubcategory($subcategoriaId) = $count');
    return count;
  }

  int getTotalCountForSubcategory(int subcategoriaId) {
    // Contar apenas produtos válidos para esta subcategoria
    final count = produtos
        .where((p) => p.subcategoriaId != null && p.subcategoriaId == subcategoriaId)
        .length;
    
    print('getTotalCountForSubcategory($subcategoriaId) = $count');
    return count;
  }

  double getTotalValueForSubcategory(int subcategoriaId) {
    // Calcular o valor total apenas de produtos válidos para esta subcategoria
    final value = produtos
        .where((p) => 
            p.subcategoriaId != null && 
            p.subcategoriaId == subcategoriaId && 
            selectedIds.contains(p.id))
        .fold(0.0, (sum, p) => sum + (p.valor ?? 0.0));
    
    print('getTotalValueForSubcategory($subcategoriaId) = $value');
    return value;
  }
  
  // Método para diagnóstico - verificar se há produtos com subcategoriaId inválido
  void checkInvalidProducts() {
    print('\n--- DIAGNÓSTICO DE PRODUTOS ---');
    print('Total de produtos carregados: ${produtos.length}');
    
    // Verificar produtos sem subcategoriaId
    final produtosSemSubcategoria = produtos.where((p) => p.subcategoriaId == null).toList();
    print('Produtos sem subcategoriaId: ${produtosSemSubcategoria.length}');
    for (final p in produtosSemSubcategoria) {
      print('- ID: ${p.id}, Nome: ${p.nome}');
    }
    
    // Verificar produtos selecionados
    print('\nProdutos selecionados: ${selectedIds.length}');
    for (final id in selectedIds) {
      final produtosEncontrados = produtos.where((p) => p.id == id).toList();
      if (produtosEncontrados.isNotEmpty) {
        final produto = produtosEncontrados.first;
        print('- ID: ${produto.id}, Nome: ${produto.nome}, Subcategoria: ${produto.subcategoriaId}');
      } else {
        print('- ID: $id (produto não encontrado na lista de produtos)');
      }
    }
    print('--- FIM DO DIAGNÓSTICO ---\n');
  }
}
