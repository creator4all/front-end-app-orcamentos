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
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void setSelected(int productId, bool selected) {
    if (selected) {
      selectedIds.add(productId);
    } else {
      selectedIds.remove(productId);
    }
  }

  bool isSelected(int productId) => selectedIds.contains(productId);
}
