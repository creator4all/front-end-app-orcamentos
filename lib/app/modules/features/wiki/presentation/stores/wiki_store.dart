import 'package:mobx/mobx.dart';

part 'wiki_store.g.dart';

/// Store para gerenciar estado de expansão dos itens da Wiki
class WikiStore = _WikiStoreBase with _$WikiStore;

abstract class _WikiStoreBase with Store {
  /// Mapa de itens expandidos (id -> isExpanded)
  @observable
  ObservableMap<String, bool> expandedItems = ObservableMap<String, bool>();

  /// Alterna estado de expansão de um item
  @action
  void toggleItem(String itemId) {
    final current = expandedItems[itemId] ?? false;
    expandedItems[itemId] = !current;
  }

  /// Verifica se um item está expandido
  bool isExpanded(String itemId) {
    return expandedItems[itemId] ?? false;
  }
}
