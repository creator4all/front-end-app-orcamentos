import 'package:mobx/mobx.dart';
import '../../domain/models/subcategory.dart';
import '../../external/services/subcategory_service.dart';

part 'subcategory_store.g.dart';

class SubcategoryStore = _SubcategoryStore with _$SubcategoryStore;

abstract class _SubcategoryStore with Store {
  final SubcategoryService _service;
  _SubcategoryStore(this._service);

  @observable
  List<SubcategoryDto> subcategorias = [];

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  int? lastCategoriaId;

  @action
  Future<void> fetchSubcategorias(int categoriaId) async {
    isLoading = true;
    error = null;
    lastCategoriaId = categoriaId;
    try {
      subcategorias = await _service.listarPorCategoria(categoriaId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
