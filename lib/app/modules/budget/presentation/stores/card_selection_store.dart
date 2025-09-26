import 'package:mobx/mobx.dart';

part 'card_selection_store.g.dart';

class CardSelectionStore = _CardSelectionStore with _$CardSelectionStore;

abstract class _CardSelectionStore with Store {
  // Mapa para armazenar o estado de seleção dos cards principais (por nome)
  @observable
  ObservableMap<String, bool> mainCardsSelection = ObservableMap<String, bool>();

  // Mapa para armazenar o estado de seleção das subcategorias (por ID)
  @observable
  ObservableMap<int, bool> subcategoriesSelection = ObservableMap<int, bool>();

  // Inicializar com valores padrão
  _CardSelectionStore() {
    // Inicializar cards principais
    mainCardsSelection['livros'] = true; // Livros começa selecionado por padrão
    mainCardsSelection['portal'] = false;
    mainCardsSelection['gamificacao'] = false;
    mainCardsSelection['avaliacao'] = false;
    mainCardsSelection['servicos'] = false;
  }

  // Método para definir o estado de seleção de um card principal
  @action
  void setMainCardSelected(String cardName, bool selected) {
    mainCardsSelection[cardName] = selected;
  }

  // Método para definir o estado de seleção de uma subcategoria
  @action
  void setSubcategorySelected(int subcategoryId, bool selected) {
    subcategoriesSelection[subcategoryId] = selected;
  }

  // Método para limpar todas as seleções de subcategorias
  @action
  void clearSubcategorySelections() {
    subcategoriesSelection.clear();
  }

  // Computar o total de cards selecionados
  @computed
  int get selectedCardsCount {
    int count = 0;
    
    // Contar cards principais selecionados
    mainCardsSelection.forEach((key, selected) {
      if (selected) count++;
    });
    
    // Contar subcategorias selecionadas
    subcategoriesSelection.forEach((key, selected) {
      if (selected) count++;
    });
    
    return count;
  }
}
