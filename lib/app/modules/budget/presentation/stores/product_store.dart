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
  ObservableMap<int, List<ProductDto>> produtosPorSubcategoria =
      ObservableMap<int, List<ProductDto>>();

  @observable
  ObservableMap<int, ProductDto> produtosPorId =
      ObservableMap<int, ProductDto>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  int? lastSubcategoriaId;

  @observable
  ObservableSet<int> selectedIds = ObservableSet<int>();

  @computed
  double get total {
    double acumulado = 0.0;
    for (final productId in selectedIds) {
      final produto = produtosPorId[productId];
      acumulado += produto?.valor ?? 0.0;
    }
    return acumulado;
  }

  @computed
  List<ProductDto> get allProducts =>
      produtosPorId.values.toList(growable: false);

  @computed
  int get selectedCount => selectedIds.length;

  @action
  Future<void> fetchProdutos(int subcategoriaId) async {
    isLoading = true;
    error = null;
    lastSubcategoriaId = subcategoriaId;
    try {
      final fetched = await _service.listarPorSubcategoria(subcategoriaId);
      produtos = List<ProductDto>.from(fetched);
      print('Carregados ${produtos.length} produtos para subcategoria $subcategoriaId');

      // Limpar cache antigo desta subcategoria antes de adicionar os novos produtos
      final existentes = produtosPorSubcategoria[subcategoriaId];
      if (existentes != null) {
        for (final antigo in existentes) {
          produtosPorId.remove(antigo.id);
        }
      }

      produtosPorSubcategoria[subcategoriaId] =
          List<ProductDto>.from(produtos);

      for (final produto in produtos) {
        produtosPorId[produto.id] = produto;
      }

      // Verificar se todos os produtos têm subcategoriaId definido corretamente
      final produtosSemSubcat = produtos
          .where((p) => p.subcategoriaId != subcategoriaId)
          .toList();
      if (produtosSemSubcat.isNotEmpty) {
        print(
            'ALERTA: ${produtosSemSubcat.length} produtos com subcategoriaId incorreto após carregamento');
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
    final produto = produtosPorId[productId];

    if (produto == null) {
      print('Tentativa de selecionar produto inexistente: $productId');
      return;
    }

    if (produto.subcategoriaId == null) {
      print('Tentativa de selecionar produto com subcategoriaId nulo: $productId');
      return;
    }

    if (selected) {
      selectedIds.add(productId);
      print(
          'Selecionado produto $productId da subcategoria ${produto.subcategoriaId}');
    } else {
      selectedIds.remove(productId);
      print(
          'Desmarcado produto $productId da subcategoria ${produto.subcategoriaId}');
    }
  }

  bool isSelected(int productId) => selectedIds.contains(productId);

  @action
  void unselectAllForSubcategory(int subcategoriaId) {
    final subcategoryProducts =
        produtosPorSubcategoria[subcategoriaId] ?? const <ProductDto>[];

    print(
        'Desmarcando ${subcategoryProducts.length} produtos da subcategoria $subcategoriaId');

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
    final validProducts = produtosPorSubcategoria[subcategoriaId] ??
        const <ProductDto>[];

    print(
        'Executando selectAllForSubcategory para subcategoria $subcategoriaId, selected=$selected');

    if (validProducts.isEmpty) {
      print('Nenhum produto válido encontrado para subcategoria $subcategoriaId');
      return;
    }

    final validProductIds = validProducts
        .where((p) => _isValidProductForSubcategory(p, subcategoriaId))
        .map((p) => p.id)
        .toSet();

    if (selected) {
      selectedIds.addAll(validProductIds);
      print(
          'Adicionados ${validProductIds.length} produtos da subcategoria $subcategoriaId');
    } else {
      selectedIds.removeAll(validProductIds);
      print(
          'Removidos ${validProductIds.length} produtos da subcategoria $subcategoriaId');
    }

    for (final entry in produtosPorSubcategoria.entries) {
      final subId = entry.key;
      if (subId == subcategoriaId) {
        continue;
      }
      for (final produto in entry.value) {
        if (selectedIds.contains(produto.id)) {
          print(
              'ALERTA: Produto ${produto.id} da subcategoria ${produto.subcategoriaId} está selecionado após manipular subcategoria $subcategoriaId');
        }
      }
    }
  }

  int getSelectedCountForSubcategory(int subcategoriaId) {
    final lista = produtosPorSubcategoria[subcategoriaId] ?? const <ProductDto>[];
    final count = lista
        .where((p) => p.subcategoriaId != null && selectedIds.contains(p.id))
        .length;

    print('getSelectedCountForSubcategory($subcategoriaId) = $count');
    return count;
  }

  int getTotalCountForSubcategory(int subcategoriaId) {
    final lista = produtosPorSubcategoria[subcategoriaId] ?? const <ProductDto>[];
    final count = lista
        .where((p) => p.subcategoriaId != null && p.subcategoriaId == subcategoriaId)
        .length;

    print('getTotalCountForSubcategory($subcategoriaId) = $count');
    return count;
  }

  double getTotalValueForSubcategory(int subcategoriaId) {
    final lista = produtosPorSubcategoria[subcategoriaId] ?? const <ProductDto>[];
    final value = lista
        .where((p) => p.subcategoriaId != null && selectedIds.contains(p.id))
        .fold(0.0, (sum, p) => sum + (p.valor ?? 0.0));

    print('getTotalValueForSubcategory($subcategoriaId) = $value');
    return value;
  }

  // Método para diagnóstico - verificar se há produtos com subcategoriaId inválido
  void checkInvalidProducts() {
    print('\n--- DIAGNÓSTICO DE PRODUTOS ---');
    print('Subcategorias em cache: ${produtosPorSubcategoria.length}');

    final todosProdutos = produtosPorId.values.toList(growable: false);
    print('Total de produtos carregados: ${todosProdutos.length}');

    final produtosSemSubcategoria =
        todosProdutos.where((p) => p.subcategoriaId == null).toList();
    print('Produtos sem subcategoriaId: ${produtosSemSubcategoria.length}');
    for (final p in produtosSemSubcategoria) {
      print('- ID: ${p.id}, Nome: ${p.nome}');
    }

    print('\nProdutos selecionados: ${selectedIds.length}');
    for (final id in selectedIds) {
      final produto = produtosPorId[id];
      if (produto != null) {
        print(
            '- ID: ${produto.id}, Nome: ${produto.nome}, Subcategoria: ${produto.subcategoriaId}');
      } else {
        print('- ID: $id (produto não encontrado na lista de produtos)');
      }
    }
    print('--- FIM DO DIAGNÓSTICO ---\n');
  }

  List<ProductDto> getProdutosPorSubcategoria(int subcategoriaId) {
    return produtosPorSubcategoria[subcategoriaId] ?? const <ProductDto>[];
  }

  ProductDto? getProductById(int productId) => produtosPorId[productId];

  List<ProductDto> getSelectedProducts() {
    return selectedIds
        .map((id) => produtosPorId[id])
        .whereType<ProductDto>()
        .toList(growable: false);
  }
}
