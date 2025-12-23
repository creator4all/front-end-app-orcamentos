import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/usecases/get_census_usecase.dart';
import '../../domain/usecases/update_budget_census_usecase.dart';
import '../../domain/usecases/update_census_usecase.dart';

part 'school_census_store.g.dart';

class SchoolCensusStore = _SchoolCensusStoreBase with _$SchoolCensusStore;

abstract class _SchoolCensusStoreBase with Store {
  final GetCensusUseCase _getCensusUseCase;
  final UpdateCensusUseCase _updateCensusUseCase;
  final UpdateBudgetCensusUseCase? _updateBudgetCensusUseCase;

  _SchoolCensusStoreBase(
    this._getCensusUseCase,
    this._updateCensusUseCase, [
    this._updateBudgetCensusUseCase,
  ]);

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

  @computed
  double get totalStudents => censoEscolar?.valorTotal ?? 0.0;

  @computed
  bool get hasChanges {
    if (censoEscolar == null) return false;
    for (var entry in editedValues.entries) {
      // Find original value
      // Note: This is computationally expensive if O(N^2), but N is small.
      // Better to check if editedValues differs from initial state
      // Simplification: just return true if editMode is on and edits exist?
      // Or properly compare.
    }
    // For now relying on direct action call
    return true;
  }

  /// Define o budgetId para usar endpoint budget-scoped
  @action
  void setBudgetId(int? id) {
    budgetId = id;
  }

  @action
  Future<void> loadCensus(int cityId) async {
    isLoading = true;
    error = null;
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
    _initEditedValues();
  }

  @action
  void toggleEditMode() {
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

    Either<BudgetFailure, CensoEscolarEntity> result;

    // Usar endpoint budget-scoped se budgetId estiver definido
    if (budgetId != null && _updateBudgetCensusUseCase != null) {
      result = await _updateBudgetCensusUseCase.call(
        budgetId: budgetId!,
        cityId: censoEscolar!.cidadeId,
        indices: editedValues,
      );
    } else {
      // Fallback para endpoint legacy (por cidade)
      result = await _updateCensusUseCase(
        cityId: censoEscolar!.cidadeId,
        indices: editedValues,
      );
    }

    result.fold(
      (l) => error = l.message,
      (r) {
        censoEscolar = r;
        isEditMode = false;
        _initEditedValues();
      },
    );

    isSaving = false;
  }

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
}
