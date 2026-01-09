import 'package:mobx/mobx.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';

import '../../domain/usecases/create_multi_city_budget_usecase.dart';
import '../../domain/usecases/get_multi_city_census_usecase.dart';

part 'multi_city_census_store.g.dart';

class MultiCityCensusStore = _MultiCityCensusStoreBase
    with _$MultiCityCensusStore;

abstract class _MultiCityCensusStoreBase with Store {
  final GetMultiCityCensusUseCase _getCensusUseCase;
  final CreateMultiCityBudgetUseCase _createBudgetUseCase;

  _MultiCityCensusStoreBase(
    this._getCensusUseCase,
    this._createBudgetUseCase,
  );

  // =========================
  // Observáveis
  // =========================

  /// Nome do orçamento definido pelo usuário
  @observable
  String budgetName = '';

  /// Lista de cidades selecionadas [{'id': int, 'nome': String, 'uf': String}]
  @observable
  ObservableList<Map<String, dynamic>> selectedCities =
      ObservableList<Map<String, dynamic>>();

  /// Mapa de censo por cidade (cidadeId -> CensoEscolarEntity)
  @observable
  ObservableMap<int, CensoEscolarEntity> censusPerCity =
      ObservableMap<int, CensoEscolarEntity>();

  /// ID da cidade selecionada no dropdown (null = visualização agregada)
  @observable
  int? selectedCityId;

  /// Valores editados por cidade: cidadeId -> { nomeEtapa -> valor }
  @observable
  ObservableMap<int, ObservableMap<String, double>> editedValuesPerCity =
      ObservableMap<int, ObservableMap<String, double>>();

  /// Flag se deve abrir modal na primeira renderização
  @observable
  bool shouldOpenCityModal = true;

  /// Estados de carregamento
  @observable
  bool isLoading = false;

  @observable
  bool isSaving = false;

  @observable
  String? error;

  // =========================
  // Computados
  // =========================

  /// Retorna o censo da cidade selecionada ou agregado
  @computed
  CensoEscolarEntity? get currentCensus {
    if (selectedCityId != null) {
      return censusPerCity[selectedCityId!];
    }
    // Retornar primeiro censo se houver (para exibição quando não há cidade selecionada)
    if (censusPerCity.isNotEmpty) {
      return censusPerCity.values.first;
    }
    return null;
  }

  /// Retorna os valores editados da cidade selecionada
  @computed
  Map<String, double> get currentEditedValues {
    if (selectedCityId != null) {
      return editedValuesPerCity[selectedCityId!] ?? {};
    }
    return {};
  }

  /// IDs das cidades selecionadas
  @computed
  List<int> get cidadeIds => selectedCities.map((c) => c['id'] as int).toList();

  /// Número de cidades selecionadas
  @computed
  int get quantidadeCidades => selectedCities.length;

  /// Verifica se há cidades selecionadas
  @computed
  bool get hasCities => selectedCities.isNotEmpty;

  /// Valor total agregado de todas as cidades
  @computed
  double get valorTotalAgregado {
    return censusPerCity.values.fold(0.0, (sum, c) => sum + c.valorTotal);
  }

  /// Verifica se está em modo agregado (todas as cidades)
  @computed
  bool get isAggregateMode => selectedCityId == null;

  /// Valores agregados por nomeEtapa (soma de todas as cidades)
  @computed
  Map<String, double> get aggregatedValues {
    final result = <String, double>{};
    for (final values in editedValuesPerCity.values) {
      for (final entry in values.entries) {
        result[entry.key] = (result[entry.key] ?? 0) + entry.value;
      }
    }
    return result;
  }

  /// Retorna os valores a exibir (agregados ou da cidade selecionada)
  @computed
  Map<String, double> get displayValues {
    if (isAggregateMode) {
      return aggregatedValues;
    }
    return editedValuesPerCity[selectedCityId] ?? {};
  }

  // =========================
  // Actions
  // =========================

  /// Define o nome do orçamento
  @action
  void setBudgetName(String name) {
    budgetName = name;
  }

  /// Atualiza a lista de cidades selecionadas
  @action
  void setSelectedCities(List<Map<String, dynamic>> cities) {
    selectedCities.clear();
    selectedCities.addAll(cities);
  }

  /// Adiciona uma cidade à seleção
  @action
  void addCity(Map<String, dynamic> city) {
    if (!selectedCities.any((c) => c['id'] == city['id'])) {
      selectedCities.add(city);
    }
  }

  /// Remove uma cidade da seleção
  @action
  void removeCity(int cityId) {
    selectedCities.removeWhere((c) => c['id'] == cityId);
    censusPerCity.remove(cityId);
    editedValuesPerCity.remove(cityId);

    // Se removeu a cidade selecionada, limpar seleção
    if (selectedCityId == cityId) {
      selectedCityId = null;
    }
  }

  /// Seleciona uma cidade no dropdown (null para agregado)
  @action
  void selectCity(int? cityId) {
    selectedCityId = cityId;
  }

  /// Marca que a modal já foi aberta
  @action
  void markModalOpened() {
    shouldOpenCityModal = false;
  }

  /// Carrega os censos para todas as cidades selecionadas
  @action
  Future<void> loadCensusForCities() async {
    if (cidadeIds.isEmpty) return;

    isLoading = true;
    error = null;

    final result = await _getCensusUseCase(cidadeIds);

    result.fold(
      (failure) {
        error = failure.message;
      },
      (censos) {
        censusPerCity.clear();
        censusPerCity.addAll(censos);
        _initializeEditedValues();
      },
    );

    isLoading = false;
  }

  /// Atualiza um valor de etapa para uma cidade específica
  @action
  void updateValue(int cityId, String nomeEtapa, double value) {
    if (!editedValuesPerCity.containsKey(cityId)) {
      editedValuesPerCity[cityId] = ObservableMap<String, double>();
    }
    editedValuesPerCity[cityId]![nomeEtapa] = value;
  }

  /// Cria o orçamento e retorna o ID
  @action
  Future<int?> createBudget() async {
    if (budgetName.isEmpty) {
      error = 'Nome do orçamento é obrigatório';
      return null;
    }

    if (cidadeIds.isEmpty) {
      error = 'Selecione pelo menos uma cidade';
      return null;
    }

    isSaving = true;
    error = null;

    // Converter editedValuesPerCity para Map<int, Map<int, double>>
    final Map<int, Map<int, double>> overrides = {};
    editedValuesPerCity.forEach((cidadeId, values) {
      overrides[cidadeId] = Map<int, double>.from(values);
    });

    final result = await _createBudgetUseCase(
      nome: budgetName,
      diasValidade: 60,
      cidadeIds: cidadeIds,
      overridesPorCidade: overrides,
    );

    isSaving = false;

    return result.fold(
      (failure) {
        error = failure.message;
        return null;
      },
      (budgetId) => budgetId,
    );
  }

  /// Inicializa valores editados a partir dos censos carregados
  void _initializeEditedValues() {
    editedValuesPerCity.clear();

    for (final entry in censusPerCity.entries) {
      final cityId = entry.key;
      final census = entry.value;

      editedValuesPerCity[cityId] = ObservableMap<String, double>();

      for (final group in census.grupos) {
        for (final title in group.titulos) {
          editedValuesPerCity[cityId]![title.nomeEtapa] = title.valor;
        }
      }
    }
  }

  /// Limpa o store
  @action
  void clear() {
    budgetName = '';
    selectedCities.clear();
    censusPerCity.clear();
    selectedCityId = null;
    editedValuesPerCity.clear();
    shouldOpenCityModal = true;
    isLoading = false;
    isSaving = false;
    error = null;
  }
}
