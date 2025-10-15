/// Caso de uso para alternar estado de uma categoria
///
/// Este use case é simples e não precisa de repositório,
/// pois é apenas uma operação de lógica local na Store
class ToggleCategoryUseCase {
  /// Alterna o estado de uma categoria
  ///
  /// Retorna o novo estado após a alternância
  bool call(String categoryKey, Map<String, bool> currentStates) {
    final currentState = currentStates[categoryKey] ?? false;
    return !currentState;
  }

  /// Atualiza o mapa de estados com o novo valor
  Map<String, bool> updateStates(
    String categoryKey,
    Map<String, bool> currentStates,
    bool newValue,
  ) {
    return {
      ...currentStates,
      categoryKey: newValue,
    };
  }
}
