import 'package:mobx/mobx.dart';

import '../../data/models/budget_census_dto.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';
import '../../domain/repositories/census_repository.dart';
import '../../domain/services/census_value_normalizer.dart';
import '../../domain/usecases/get_budget_census_usecase.dart';

part 'school_census_store.g.dart';

class SchoolCensusStore = _SchoolCensusStoreBase with _$SchoolCensusStore;

abstract class _SchoolCensusStoreBase with Store {
  final CensusRepository _censusRepository;
  final GetBudgetCensusUseCase? _getBudgetCensusUseCase;

  _SchoolCensusStoreBase(
    this._censusRepository, [
    this._getBudgetCensusUseCase,
  ]);

  @computed
  double get totalProfessores => censoEscolar?.valorTotalProfessores ?? 0.0;

  @computed
  double get totalCursistas => censoEscolar?.valorTotalCursistas ?? 0.0;

  @observable
  CensoEscolarEntity? censoEscolar;

  @observable
  bool isLoading = false;

  @observable
  bool isSaving = false;

  @observable
  bool isEditMode = false;

  @observable
  String? error;

  @observable
  ObservableMap<int, double> editedValues = ObservableMap<int, double>();

  final Map<int, double> _originalValues = {};

  @observable
  int? budgetId;

  @observable
  bool isMultiCity = false;

  @observable
  ObservableList<CidadeCensoDto> cidades = ObservableList<CidadeCensoDto>();

  @observable
  ObservableMap<String, double> censoAgregado = ObservableMap<String, double>();

  @observable
  int? selectedCityId;

  @computed
  double get totalStudents => censoEscolar?.valorTotalAlunos ?? 0.0;

  @computed
  bool get hasChanges {
    if (censoEscolar == null) return false;
    return true;
  }

  @computed
  bool get isAggregatedView => isMultiCity && selectedCityId == null;

  @computed
  String get selectedCityName {
    if (!isMultiCity || selectedCityId == null) {
      return 'Todas as cidades (Agregado)';
    }
    final city = cidades.firstWhere(
      (c) => c.id == selectedCityId,
      orElse: () => const CidadeCensoDto(id: 0, nome: 'Cidade', indices: []),
    );
    return city.nome;
  }

  @computed
  List<DropdownCityOption> get cityOptions {
    final options = <DropdownCityOption>[];

    if (isMultiCity && cidades.length > 1) {
      options.add(
        DropdownCityOption(
          id: null,
          name: 'Todas as cidades (Agregado)',
          isAggregated: true,
        ),
      );
    }

    for (final city in cidades) {
      options.add(
        DropdownCityOption(id: city.id, name: city.nome, isAggregated: false),
      );
    }

    return options;
  }

  @action
  void setBudgetId(int? id) {
    budgetId = id;
  }

  @action
  Future<void> loadCensus(int cityId) async {
    isLoading = true;
    error = null;
    isMultiCity = false;

    final result = await _censusRepository.getCensusByCity(cityId);

    result.fold((l) => error = l.message, (r) {
      censoEscolar = r;
      _initEditedValues();
    });
    isLoading = false;
  }

  @action
  void setCensoEscolar(CensoEscolarEntity censo) {
    censoEscolar = censo;
    error = null;

    selectedCityId = censo.cidadeId;

    cidades.clear();
    cidades.add(CidadeCensoDto.fromEntity(censo));

    _initEditedValues();
  }

  @action
  void toggleEditMode() {
    if (isAggregatedView) return;

    isEditMode = !isEditMode;
    if (!isEditMode) {
      _initEditedValues();
    }
  }

  @action
  void updateValue(int indiceId, double? value) {
    if (value == null) {
      editedValues.remove(indiceId);
      return;
    }

    editedValues[indiceId] = value;
  }

  @action
  Future<void> saveCensus() async {
    if (censoEscolar == null) return;

    isSaving = true;
    error = null;

    if (budgetId != null) {
      final indicesToSend = isMultiCity ? editedValues : _changedIndices();

      if (!isMultiCity && indicesToSend.isEmpty) {
        isEditMode = false;
        _initEditedValues();
        isSaving = false;
        return;
      }

      final updateResult = await _censusRepository.updateBudgetCensusIndices(
        budgetId: budgetId!,
        cityId: censoEscolar!.cidadeId,
        updatedIndices: indicesToSend,
      );

      updateResult.fold((l) => error = l.message, (r) {
        isMultiCity = r.multiCidade;

        cidades.clear();
        for (var cityEntity in r.cidades) {
          cidades.add(CidadeCensoDto.fromEntity(cityEntity));
        }

        censoAgregado.clear();
        censoAgregado.addAll(r.censoAgregado);

        isEditMode = false;
        _initEditedValues();

        selectCity(selectedCityId);
      });
    } else {
      final legacyResult = await _censusRepository.updateCensusIndices(
        censoEscolar!.cidadeId,
        editedValues,
      );

      legacyResult.fold((l) => error = l.message, (r) {
        censoEscolar = r;
        isEditMode = false;
        _initEditedValues();

        if (isMultiCity && selectedCityId != null) {
          _updateCityInList(r);
        }
      });
    }

    isSaving = false;
  }

  @action
  Future<void> loadBudgetCensus(int budgetIdParam) async {
    if (_getBudgetCensusUseCase == null) {
      error = 'GetBudgetCensusUseCase não configurado';
      return;
    }

    isLoading = true;
    error = null;
    budgetId = budgetIdParam;

    final result = await _getBudgetCensusUseCase.call(budgetIdParam);

    result.fold(
      (failure) {
        error = failure.message;
        isLoading = false;
      },
      (dto) {
        isMultiCity = dto.multiCidade;

        cidades.clear();
        cidades.addAll(dto.cidades);

        censoAgregado.clear();
        censoAgregado.addAll(dto.censoAgregado);

        if (isMultiCity && dto.cidades.length > 1) {
          selectedCityId = null;
          _loadAggregatedView();
        } else if (dto.cidades.isNotEmpty) {
          selectedCityId = dto.cidades.first.id;
          censoEscolar = dto.cidades.first.toEntity();
          _initEditedValues();
        }

        isLoading = false;
      },
    );
  }

  @action
  void selectCity(int? cityId) {
    isEditMode = false;
    selectedCityId = cityId;

    if (cityId == null) {
      _loadAggregatedView();
    } else {
      final cityIndex = cidades.indexWhere((c) => c.id == cityId);
      if (cityIndex != -1) {
        censoEscolar = cidades[cityIndex].toEntity();
        _initEditedValues();
      }
    }
  }

  void _initEditedValues() {
    editedValues.clear();
    _originalValues.clear();
    if (censoEscolar != null) {
      for (var group in censoEscolar!.grupos) {
        for (var title in group.titulos) {
          editedValues[title.id] = title.valor;
          _originalValues[title.id] = title.valor;
        }
      }
    }
  }

  Map<int, double> _changedIndices() {
    final changed = <int, double>{};
    editedValues.forEach((id, value) {
      final original = _originalValues[id];
      if (original == null || (value - original).abs() > 0.0001) {
        changed[id] = value;
      }
    });
    return changed;
  }

  void _loadAggregatedView() {
    if (cidades.isEmpty) return;

    final firstCity = cidades.first;
    final aggregatedEntity = firstCity.toEntity();

    final updatedGroups = aggregatedEntity.grupos.map((group) {
      final updatedTitles = group.titulos.map((title) {
        final aggregatedValue = censoAgregado[title.nomeEtapa] ?? title.valor;
        return title.copyWith(valor: aggregatedValue);
      }).toList();
      return group.copyWith(titulos: updatedTitles);
    }).toList();

    censoEscolar = CensoEscolarEntity(
      cidadeId: 0,
      cidadeNome: 'Todas as cidades',
      censoAno: null,
      anoPopulacao: null,
      grupos: updatedGroups,
      valoresPorEtapa: Map<String, double>.from(censoAgregado),
    );

    editedValues.clear();
    _originalValues.clear();
  }

  void _updateCityInList(CensoEscolarEntity updatedCenso) {
    final index = cidades.indexWhere((c) => c.id == updatedCenso.cidadeId);
    if (index != -1) {
      _recalculateAgregado();
    }
  }

  void _recalculateAgregado() {
    censoAgregado.clear();

    for (final cidade in cidades) {
      for (final indice in cidade.indices) {
        final key = indice.nomeEtapa;
        censoAgregado[key] = (censoAgregado[key] ?? 0) +
            CensusValueNormalizer.consolidateStageValue(
              key,
              indice.valor,
            );
      }
    }
  }
}

class DropdownCityOption {
  final int? id;
  final String name;
  final bool isAggregated;

  DropdownCityOption({
    required this.id,
    required this.name,
    required this.isAggregated,
  });
}
