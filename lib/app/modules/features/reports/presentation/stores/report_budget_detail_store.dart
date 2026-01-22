import 'package:mobx/mobx.dart';

import '../../../budget/budget_config/data/models/budget_census_dto.dart';
import '../../../budget/budget_config/domain/entities/budget_detail_entity.dart';
import '../../../budget/budget_config/domain/usecases/get_budget_census_usecase.dart';
import '../../../budget/budget_config/domain/usecases/get_budget_detail_usecase.dart';

part 'report_budget_detail_store.g.dart';

/// Store MobX para gerenciar os detalhes de um orçamento em modo somente leitura.
///
/// Reutiliza os use cases existentes do módulo budget_config para buscar
/// os dados do orçamento, censo e produtos.
class ReportBudgetDetailStore = _ReportBudgetDetailStoreBase
    with _$ReportBudgetDetailStore;

abstract class _ReportBudgetDetailStoreBase with Store {
  final GetBudgetDetailUseCase getBudgetDetailUseCase;
  final GetBudgetCensusUseCase getBudgetCensusUseCase;

  _ReportBudgetDetailStoreBase({
    required this.getBudgetDetailUseCase,
    required this.getBudgetCensusUseCase,
  });

  /// Detalhes do orçamento
  @observable
  BudgetDetailEntity? budgetDetail;

  /// Dados do censo escolar
  @observable
  BudgetCensusDto? censoEscolar;

  /// Indica se está carregando dados do orçamento
  @observable
  bool isLoadingBudget = false;

  /// Indica se está carregando dados do censo
  @observable
  bool isLoadingCensus = false;

  /// Mensagem de erro, se houver
  @observable
  String? error;

  /// ID do orçamento atual
  @observable
  int? currentBudgetId;

  /// Retorna true se qualquer dado está carregando
  @computed
  bool get isLoading => isLoadingBudget || isLoadingCensus;

  /// Nome/título do orçamento
  @computed
  String get budgetName => budgetDetail?.name ?? 'Orçamento';

  /// Status do orçamento
  @computed
  String get budgetStatus => budgetDetail?.status ?? '';

  /// Valor total do orçamento
  @computed
  double get budgetTotal => budgetDetail?.total ?? 0.0;

  /// Dias de validade
  @computed
  int get validityDays => budgetDetail?.validityDays ?? 0;

  /// Verifica se tem censo
  @computed
  bool get hasCensus => censoEscolar != null;

  /// Verifica se é orçamento multi-cidade
  @computed
  bool get isMultiCity => budgetDetail?.isMultiCity ?? false;

  /// Carrega todos os dados do orçamento
  @action
  Future<void> loadBudgetDetails(int budgetId) async {
    currentBudgetId = budgetId;
    error = null;

    // Carregar detalhes e censo em paralelo
    await Future.wait([
      _loadBudget(budgetId),
      _loadCensus(budgetId),
    ]);
  }

  /// Carrega apenas os detalhes do orçamento
  @action
  Future<void> _loadBudget(int budgetId) async {
    isLoadingBudget = true;

    final result = await getBudgetDetailUseCase(budgetId);

    result.fold(
      (failure) {
        error = failure.message;
        isLoadingBudget = false;
      },
      (detail) {
        budgetDetail = detail;
        isLoadingBudget = false;
      },
    );
  }

  /// Carrega apenas os dados do censo
  @action
  Future<void> _loadCensus(int budgetId) async {
    isLoadingCensus = true;

    final result = await getBudgetCensusUseCase(budgetId);

    result.fold(
      (failure) {
        // Erro no censo não é crítico, apenas ignoramos
        isLoadingCensus = false;
      },
      (census) {
        censoEscolar = census;
        isLoadingCensus = false;
      },
    );
  }

  /// Recarrega os dados do orçamento
  @action
  Future<void> refresh() async {
    if (currentBudgetId != null) {
      await loadBudgetDetails(currentBudgetId!);
    }
  }

  /// Limpa a store
  @action
  void clear() {
    budgetDetail = null;
    censoEscolar = null;
    error = null;
    currentBudgetId = null;
  }
}
