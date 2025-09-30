import 'package:mobx/mobx.dart';
import '../../domain/models/category.dart';
import '../../external/services/category_service.dart';

part 'category_store.g.dart';

class CategoryStore = _CategoryStore with _$CategoryStore;

abstract class _CategoryStore with Store {
  final CategoryService _service;
  _CategoryStore(this._service);

  @observable
  List<CategoryDto> categorias = [];

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @action
  Future<void> fetchCategorias() async {
    isLoading = true;
    error = null;
    try {
      categorias = await _service.listar();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
