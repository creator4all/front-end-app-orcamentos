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

  // Mapa para rastrear quais subcategorias pertencem a quais cards principais
  Map<int, String> subcategoryToMainCard = {};

  // Inicializar com valores padrão
  _CardSelectionStore() {
    // Inicializar cards principais - todos começam não selecionados
    mainCardsSelection['livros'] = false; // Alterado para não selecionar por padrão
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

  // Método para registrar que uma subcategoria pertence a um card principal
  @action
  void registerSubcategoryToMainCard(int subcategoryId, String mainCardName) {
    subcategoryToMainCard[subcategoryId] = mainCardName;
  }

  // Método para limpar todas as seleções de subcategorias
  @action
  void clearSubcategorySelections() {
    subcategoriesSelection.clear();
  }

  // Computar o total de cards selecionados (incluindo subcategorias)
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

  // Computar apenas os checkboxes visíveis na tela principal
  @computed
  int get visibleCheckboxesCount {
    int count = 0;
    
    // Contar cards principais selecionados (Livros = 1 checkbox, independente das subcategorias)
    mainCardsSelection.forEach((key, selected) {
      if (selected) count++;
    });
    
    // Para subcategorias, contar apenas as que não pertencem a um card principal selecionado
    subcategoriesSelection.forEach((subcategoryId, selected) {
      if (selected) {
        // Verificar se esta subcategoria pertence a um card principal
        String? mainCard = subcategoryToMainCard[subcategoryId];
        
        // Se não pertence a nenhum card principal OU o card principal não está selecionado
        if (mainCard == null || mainCardsSelection[mainCard] != true) {
          count++;
        }
        // Se pertence a um card principal selecionado, não contar (já foi contado no card principal)
      }
    });
    
    return count;
  }
}
