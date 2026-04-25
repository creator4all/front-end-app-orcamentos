import 'package:mobx/mobx.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/census_value_normalizer.dart';

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

  @observable
  String budgetName = '';

  @observable
  ObservableList<Map<String, dynamic>> selectedCities =
      ObservableList<Map<String, dynamic>>();

  @observable
  ObservableMap<int, CensoEscolarEntity> censusPerCity =
      ObservableMap<int, CensoEscolarEntity>();

  @observable
  int? selectedCityId;

  @observable
  ObservableMap<int, ObservableMap<int, double>> editedValuesPerCity =
      ObservableMap<int, ObservableMap<int, double>>();

  final Map<String, int> _nomeEtapaToId = {};
  final Map<int, String> _idToNomeEtapa = {};

  @observable
  bool shouldOpenCityModal = true;

  @observable
  bool isLoading = false;

  @observable
  bool isSaving = false;

  @observable
  String? error;

  @computed
  CensoEscolarEntity? get currentCensus {
    if (selectedCityId != null) {
      return censusPerCity[selectedCityId!];
    }
    if (censusPerCity.isNotEmpty) {
      return censusPerCity.values.first;
    }
    return null;
  }

  @computed
  Map<int, double> get currentEditedValues {
    if (selectedCityId != null) {
      return editedValuesPerCity[selectedCityId!] ?? {};
    }
    return {};
  }

  @computed
  List<int> get cidadeIds => selectedCities.map((c) => c['id'] as int).toList();

  @computed
  int get quantidadeCidades => selectedCities.length;

  @computed
  bool get hasCities => selectedCities.isNotEmpty;

  @computed
  double get valorTotalAgregado {
    if (editedValuesPerCity.isNotEmpty) {
      return aggregatedValues.values.fold(0.0, (sum, value) => sum + value);
    }

    return censusPerCity.values.fold(0.0, (sum, censo) {
      final totalCidade =
          censo.valoresPorEtapa.entries.fold(0.0, (citySum, entry) {
        return citySum +
            CensusValueNormalizer.consolidateStageValue(
              entry.key,
              entry.value,
            );
      });
      return sum + totalCidade;
    });
  }

  @computed
  bool get isAggregateMode => selectedCityId == null;

  @computed
  Map<int, double> get aggregatedValues {
    final result = <int, double>{};
    for (final values in editedValuesPerCity.values) {
      for (final entry in values.entries) {
        result[entry.key] = (result[entry.key] ?? 0) +
            _consolidateValue(entry.key, entry.value);
      }
    }
    return result;
  }

  @computed
  Map<String, double> get displayValues {
    final Map<int, double> sourceValues;
    if (isAggregateMode) {
      sourceValues = aggregatedValues;
    } else {
      sourceValues = editedValuesPerCity[selectedCityId] ?? {};
    }

    final result = <String, double>{};
    for (final entry in sourceValues.entries) {
      final nomeEtapa = _idToNomeEtapa[entry.key];
      if (nomeEtapa != null) {
        result[nomeEtapa] = CensusValueNormalizer.consolidateStageValue(
          nomeEtapa,
          entry.value,
        );
      }
    }
    return result;
  }

  double _consolidateValue(int indiceEtapaId, double value) {
    final nomeEtapa = _idToNomeEtapa[indiceEtapaId];
    if (nomeEtapa == null) {
      return value;
    }

    return CensusValueNormalizer.consolidateStageValue(nomeEtapa, value);
  }

  @action
  void setBudgetName(String name) {
    budgetName = name;
  }

  @action
  void setSelectedCities(List<Map<String, dynamic>> cities) {
    selectedCities.clear();
    selectedCities.addAll(cities);
  }

  @action
  void addCity(Map<String, dynamic> city) {
    if (!selectedCities.any((c) => c['id'] == city['id'])) {
      selectedCities.add(city);
    }
  }

  @action
  void removeCity(int cityId) {
    selectedCities.removeWhere((c) => c['id'] == cityId);
    censusPerCity.remove(cityId);
    editedValuesPerCity.remove(cityId);

    if (selectedCityId == cityId) {
      selectedCityId = null;
    }
  }

  @action
  void selectCity(int? cityId) {
    selectedCityId = cityId;
  }

  @action
  void markModalOpened() {
    shouldOpenCityModal = false;
  }

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

  @action
  void updateValue(int cityId, String nomeEtapa, double value) {
    final indiceEtapaId = _nomeEtapaToId[nomeEtapa];
    if (indiceEtapaId == null) {
      return;
    }

    if (!editedValuesPerCity.containsKey(cityId)) {
      editedValuesPerCity[cityId] = ObservableMap<int, double>();
    }
    editedValuesPerCity[cityId]![indiceEtapaId] = value;
  }

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

    final userId = _authStore.currentUser?.id ?? 0;
    if (userId <= 0) {
      error = 'Usuário não autenticado';
      return null;
    }

    isSaving = true;
    error = null;

    final Map<int, Map<int, double>> overrides = {};
    editedValuesPerCity.forEach((cidadeId, values) {
      overrides[cidadeId] = Map<int, double>.from(values);
    });

    final result = await _createBudgetUseCase(
      nome: budgetName,
      diasValidade: 60,
      usuarioId: userId,
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
          editedValuesPerCity[cityId]![title.id] = title.valor;

          _nomeEtapaToId[title.nomeEtapa] = title.id;
          _idToNomeEtapa[title.id] = title.nomeEtapa;
        }
      }
    }
  }

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
