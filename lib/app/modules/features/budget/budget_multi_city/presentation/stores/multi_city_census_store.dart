import 'package:mobx/mobx.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';

import '../../domain/usecases/create_multi_city_budget_usecase.dart';
import '../../domain/usecases/get_multi_city_census_usecase.dart';

part 'multi_city_census_store.g.dart';

class MultiCityCensusStore = _MultiCityCensusStoreBase
    with _$MultiCityCensusStore;

abstract class _MultiCityCensusStoreBase with Store {
  final GetMultiCityCensusUseCase _getCensusUseCase;
  final CreateMultiCityBudgetUseCase _createBudgetUseCase;
  final AuthStore _authStore;

  _MultiCityCensusStoreBase(
    this._getCensusUseCase,
    this._createBudgetUseCase,
    this._authStore,
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

  /// Valores editados por cidade: cidadeId -> { indice_etapa_id -> valor }
  @observable
  ObservableMap<int, ObservableMap<int, double>> editedValuesPerCity =
      ObservableMap<int, ObservableMap<int, double>>();

  /// Mapa de lookup: nomeEtapa -> indice_etapa_id (para conversão UI -> API)
  final Map<String, int> _nomeEtapaToId = {};

  /// Mapa de lookup inverso: indice_etapa_id -> nomeEtapa (para exibição)
  final Map<int, String> _idToNomeEtapa = {};

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

  /// Retorna os valores editados da cidade selecionada (por indice_etapa_id)
  @computed
  Map<int, double> get currentEditedValues {
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

  /// Valores agregados por indice_etapa_id (soma de todas as cidades)
  @computed
  Map<int, double> get aggregatedValues {
    final result = <int, double>{};
    for (final values in editedValuesPerCity.values) {
      for (final entry in values.entries) {
        result[entry.key] = (result[entry.key] ?? 0) + entry.value;
      }
    }
    return result;
  }

  /// Retorna os valores a exibir por nomeEtapa (para UI)
  /// Converte de indice_etapa_id para nomeEtapa
  @computed
  Map<String, double> get displayValues {
    final Map<int, double> sourceValues;
    if (isAggregateMode) {
      sourceValues = aggregatedValues;
    } else {
      sourceValues = editedValuesPerCity[selectedCityId] ?? {};
    }

    // Converter de int (id) para String (nomeEtapa) para a UI
    final result = <String, double>{};
    for (final entry in sourceValues.entries) {
      final nomeEtapa = _idToNomeEtapa[entry.key];
      if (nomeEtapa != null) {
        result[nomeEtapa] = entry.value;
      }
    }
    return result;
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
  /// Aceita nomeEtapa (String) para compatibilidade com UI e converte para id
  @action
  void updateValue(int cityId, String nomeEtapa, double value) {
    final indiceEtapaId = _nomeEtapaToId[nomeEtapa];
    if (indiceEtapaId == null) {
      // Se não encontrar o ID, não faz nada (não deveria acontecer)
      return;
    }

    if (!editedValuesPerCity.containsKey(cityId)) {
      editedValuesPerCity[cityId] = ObservableMap<int, double>();
    }
    editedValuesPerCity[cityId]![indiceEtapaId] = value;
  }

  /// Cria o orçamento e retorna os dados completos (categorias, cidades, censo_agregado)
  @action
  Future<Map<String, dynamic>?> createBudget() async {
    if (budgetName.isEmpty) {
      error = 'Nome do orçamento é obrigatório';
      return null;
    }

    if (cidadeIds.isEmpty) {
      error = 'Selecione pelo menos uma cidade';
      return null;
    }

    // ✅ Obter ID do usuário autenticado
    final userId = _authStore.currentUser?.id ?? 0;
    if (userId <= 0) {
      error = 'Usuário não autenticado';
      return null;
    }

    isSaving = true;
    error = null;

    // editedValuesPerCity já usa int como chave, apenas converter para Map regular
    final Map<int, Map<int, double>> overrides = {};
    editedValuesPerCity.forEach((cidadeId, values) {
      overrides[cidadeId] = Map<int, double>.from(values);
    });

    final result = await _createBudgetUseCase(
      nome: budgetName,
      diasValidade: 60,
      usuarioId: userId, // ✅ Usar ID do usuário logado
      cidadeIds: cidadeIds,
      overridesPorCidade: overrides,
    );

    isSaving = false;

    return result.fold(
      (failure) {
        error = failure.message;
        return null;
      },
      (budgetData) => budgetData,
    );
  }

  /// Inicializa valores editados e mapas de lookup a partir dos censos carregados
  void _initializeEditedValues() {
    editedValuesPerCity.clear();
    _nomeEtapaToId.clear();
    _idToNomeEtapa.clear();

    for (final entry in censusPerCity.entries) {
      final cityId = entry.key;
      final census = entry.value;

      editedValuesPerCity[cityId] = ObservableMap<int, double>();

      for (final group in census.grupos) {
        for (final title in group.titulos) {
          // Armazenar usando indice_etapa_id (int)
          editedValuesPerCity[cityId]![title.id] = title.valor;

          // Preencher mapas de lookup (uma vez por etapa)
          _nomeEtapaToId[title.nomeEtapa] = title.id;
          _idToNomeEtapa[title.id] = title.nomeEtapa;
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
