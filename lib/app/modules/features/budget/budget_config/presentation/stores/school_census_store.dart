import 'package:mobx/mobx.dart';

import '../../data/models/budget_census_dto.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';
import '../../domain/usecases/get_budget_census_usecase.dart';
import '../../domain/usecases/get_census_usecase.dart';
import '../../domain/usecases/update_budget_census_usecase.dart';
import '../../domain/usecases/update_census_usecase.dart';

part 'school_census_store.g.dart';

class SchoolCensusStore = _SchoolCensusStoreBase with _$SchoolCensusStore;

abstract class _SchoolCensusStoreBase with Store {
  final GetCensusUseCase _getCensusUseCase;
  final UpdateCensusUseCase _updateCensusUseCase;
  final UpdateBudgetCensusUseCase? _updateBudgetCensusUseCase;
  final GetBudgetCensusUseCase? _getBudgetCensusUseCase;

  _SchoolCensusStoreBase(
    this._getCensusUseCase,
    this._updateCensusUseCase, [
    this._updateBudgetCensusUseCase,
    this._getBudgetCensusUseCase,
  ]);

  // ========== OBSERVABLES EXISTENTES ==========

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

  /// ID do orçamento para usar endpoint budget-scoped
  @observable
  int? budgetId;

  // ========== NOVOS OBSERVABLES PARA MULTI-CIDADE ==========

  /// Indica se o orçamento é multi-cidade
  @observable
  bool isMultiCity = false;

  /// Lista de cidades disponíveis (para multi-cidade)
  @observable
  ObservableList<CidadeCensoDto> cidades = ObservableList<CidadeCensoDto>();

  /// Censo agregado (soma de todas as cidades)
  @observable
  ObservableMap<String, double> censoAgregado = ObservableMap<String, double>();

  /// ID da cidade selecionada (null = visualização agregada)
  @observable
  int? selectedCityId;

  // ========== COMPUTED ==========

  @computed
  double get totalStudents => censoEscolar?.valorTotal ?? 0.0;

  @computed
  bool get hasChanges {
    if (censoEscolar == null) return false;
    return true;
  }

  /// Verifica se está visualizando dados agregados
  @computed
  bool get isAggregatedView => isMultiCity && selectedCityId == null;

  /// Nome da cidade selecionada ou "Todas as cidades"
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

  /// Lista de opções para dropdown (agregado + cidades individuais)
  @computed
  List<DropdownCityOption> get cityOptions {
    final options = <DropdownCityOption>[];

    // Opção agregada sempre primeiro
    if (isMultiCity && cidades.length > 1) {
      options.add(DropdownCityOption(
        id: null,
        name: 'Todas as cidades (Agregado)',
        isAggregated: true,
      ));
    }

    // Cidades individuais
    for (final city in cidades) {
      options.add(DropdownCityOption(
        id: city.id,
        name: city.nome,
        isAggregated: false,
      ));
    }

    return options;
  }

  // ========== ACTIONS EXISTENTES ==========

  /// Define o budgetId para usar endpoint budget-scoped
  @action
  void setBudgetId(int? id) {
    budgetId = id;
  }

  @action
  Future<void> loadCensus(int cityId) async {
    isLoading = true;
    error = null;
    isMultiCity = false;

    final result = await _getCensusUseCase(cityId);

    result.fold(
      (l) => error = l.message,
      (r) {
        censoEscolar = r;
        _initEditedValues();
      },
    );
    isLoading = false;
  }

  /// Define o censo diretamente (sem chamar API)
  @action
  void setCensoEscolar(CensoEscolarEntity censo) {
    censoEscolar = censo;
    error = null;

    // ✅ FIX: Definir selectedCityId com o ID da cidade do censo
    selectedCityId = censo.cidadeId;

    // ✅ FIX: Popular lista de cidades para que selectCity() funcione após save
    cidades.clear();
    cidades.add(CidadeCensoDto.fromEntity(censo));

    _initEditedValues();
  }

  @action
  void toggleEditMode() {
    // Não permitir edição na visualização agregada
    if (isAggregatedView) return;

    isEditMode = !isEditMode;
    if (!isEditMode) {
      _initEditedValues();
    }
  }

  @action
  void updateValue(int indiceId, double value) {
    editedValues[indiceId] = value;
  }

  @action
  Future<void> saveCensus() async {
    if (censoEscolar == null) return;

    isSaving = true;
    error = null;

    // Usar endpoint budget-scoped se budgetId estiver definido
    if (budgetId != null && _updateBudgetCensusUseCase != null) {
      final updateResult = await _updateBudgetCensusUseCase.call(
        budgetId: budgetId!,
        cityId: censoEscolar!.cidadeId,
        indices: editedValues,
      );

      updateResult.fold(
        (l) => error = l.message,
        (r) {
          // Atualizar dados multi-cidade no store
          isMultiCity = r.multiCidade;

          // Atualizar lista de cidades usando o factory fromEntity para preservar índices
          cidades.clear();
          for (var cityEntity in r.cidades) {
            cidades.add(CidadeCensoDto.fromEntity(cityEntity));
          }

          // Atualizar censo agregado
          censoAgregado.clear();
          censoAgregado.addAll(r.censoAgregado);

          isEditMode = false;
          _initEditedValues();

          // Re-selecionar cidade para atualizar censoEscolar da UI com os novos dados
          selectCity(selectedCityId);
        },
      );
    } else {
      // Fallback para endpoint legacy (por cidade)
      final legacyResult = await _updateCensusUseCase(
        cityId: censoEscolar!.cidadeId,
        indices: editedValues,
      );

      legacyResult.fold(
        (l) => error = l.message,
        (r) {
          censoEscolar = r;
          isEditMode = false;
          _initEditedValues();

          // Atualizar cidade na lista se for multi-cidade
          if (isMultiCity && selectedCityId != null) {
            _updateCityInList(r);
          }
        },
      );
    }

    isSaving = false;
  }

  // ========== NOVOS ACTIONS PARA MULTI-CIDADE ==========

  /// Carrega dados do censo para um orçamento (suporta multi-cidade)
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

        // Popular lista de cidades
        cidades.clear();
        cidades.addAll(dto.cidades);

        // Popular censo agregado
        censoAgregado.clear();
        censoAgregado.addAll(dto.censoAgregado);

        // Se for multi-cidade, começar na visualização agregada
        if (isMultiCity && dto.cidades.length > 1) {
          selectedCityId = null;
          _loadAggregatedView();
        } else if (dto.cidades.isNotEmpty) {
          // Se for cidade única, carregar a cidade
          selectedCityId = dto.cidades.first.id;
          censoEscolar = dto.cidades.first.toEntity();
          _initEditedValues();
        }

        isLoading = false;
      },
    );
  }

  /// Seleciona uma cidade para visualização/edição
  @action
  void selectCity(int? cityId) {
    // Sair do modo de edição ao trocar de cidade
    isEditMode = false;
    selectedCityId = cityId;

    if (cityId == null) {
      // Visualização agregada
      _loadAggregatedView();
    } else {
      // Cidade específica - usar indexWhere para evitar fallback com id: 0
      final cityIndex = cidades.indexWhere((c) => c.id == cityId);
      if (cityIndex != -1) {
        censoEscolar = cidades[cityIndex].toEntity();
        _initEditedValues();
      }
      // Se não encontrar, mantém censoEscolar atual (não sobrescreve com id: 0)
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  void _initEditedValues() {
    editedValues.clear();
    if (censoEscolar != null) {
      for (var group in censoEscolar!.grupos) {
        for (var title in group.titulos) {
          editedValues[title.id] = title.valor;
        }
      }
    }
  }

  /// Carrega visualização agregada (soma de todas as cidades)
  void _loadAggregatedView() {
    if (cidades.isEmpty) return;

    // Usar primeira cidade como template e somar valores
    final firstCity = cidades.first;
    final aggregatedEntity = firstCity.toEntity();

    // Atualizar valores com censo agregado
    final updatedGroups = aggregatedEntity.grupos.map((group) {
      final updatedTitles = group.titulos.map((title) {
        final aggregatedValue = censoAgregado[title.nomeEtapa] ?? title.valor;
        return title.copyWith(valor: aggregatedValue);
      }).toList();
      return group.copyWith(titulos: updatedTitles);
    }).toList();

    censoEscolar = CensoEscolarEntity(
      cidadeId: 0, // ID 0 indica agregado
      cidadeNome: 'Todas as cidades',
      grupos: updatedGroups,
      valoresPorEtapa: Map<String, double>.from(censoAgregado),
    );

    // Não inicializar editedValues no modo agregado (read-only)
    editedValues.clear();
  }

  /// Atualiza cidade na lista após salvar
  void _updateCityInList(CensoEscolarEntity updatedCenso) {
    final index = cidades.indexWhere((c) => c.id == updatedCenso.cidadeId);
    if (index != -1) {
      // Reconstruir CidadeCensoDto com valores atualizados
      // Isso é complexo, então por ora apenas recalculamos o agregado
      _recalculateAgregado();
    }
  }

  /// Recalcula censo agregado após edição
  void _recalculateAgregado() {
    censoAgregado.clear();

    for (final cidade in cidades) {
      for (final indice in cidade.indices) {
        final key = indice.nomeEtapa;
        censoAgregado[key] = (censoAgregado[key] ?? 0) + indice.valor;
      }
    }
  }
}

/// Opção para dropdown de seleção de cidade
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
