import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_edit_entity.dart';
import '../../domain/usecases/get_budget_for_edit_usecase.dart';
import '../../domain/usecases/update_budget_usecase.dart';

part 'budget_edit_store.g.dart';

class BudgetEditStore = _BudgetEditStoreBase with _$BudgetEditStore;

abstract class _BudgetEditStoreBase with Store {
  final GetBudgetForEditUseCase getBudgetForEditUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;

  _BudgetEditStoreBase({
    required this.getBudgetForEditUseCase,
    required this.updateBudgetUseCase,
  });

  // ========== OBSERVABLES ==========

  @observable
  bool isLoading = false;

  @observable
  bool isSaving = false;

  @observable
  String? error;

  @observable
  BudgetEditEntity? budgetData;

  @observable
  String selectedStatus = 'pendente';

  @observable
  bool isArchived = false;

  @observable
  DateTime? validityDate;

  @observable
  ObservableSet<int> selectedProductIds = ObservableSet<int>();

  // ========== COMPUTED ==========

  @computed
  bool get hasData => budgetData != null;

  @computed
  bool get canSave {
    if (budgetData == null) return false;
    if (validityDate == null) return false;
    return selectedProductIds.isNotEmpty;
  }

  @computed
  int get selectedProductsCount => selectedProductIds.length;

  @computed
  double get totalValue {
    if (budgetData == null) return 0.0;
    return budgetData!.products
        .where((p) => selectedProductIds.contains(p.productId))
        .fold(0.0, (sum, p) => sum + p.totalPrice);
  }

  // ========== ACTIONS ==========

  @action
  Future<void> loadBudgetForEdit(int budgetId) async {
    isLoading = true;
    error = null;

    try {
      print('🔄 [BudgetEditStore] Carregando orçamento para edição: $budgetId');

      final result = await getBudgetForEditUseCase(budgetId);

      result.fold(
        (failure) {
          print('❌ [BudgetEditStore] Erro: ${failure.message}');
          error = failure.message;
          budgetData = null;
        },
        (budget) {
          print('✅ [BudgetEditStore] Orçamento carregado');
          budgetData = budget;

          // Inicializar estados
          selectedStatus = budget.status;
          isArchived = budget.isArchived;
          validityDate = budget.validityDate;

          // Inicializar produtos selecionados
          selectedProductIds.clear();
          selectedProductIds.addAll(
            budget.products.where((p) => p.isSelected).map((p) => p.productId),
          );

          print('   Produtos selecionados: ${selectedProductIds.length}');
        },
      );
    } catch (e) {
      print('❌ [BudgetEditStore] Erro inesperado: $e');
      error = 'Erro ao carregar orçamento: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  void toggleProductSelection(int productId) {
    if (selectedProductIds.contains(productId)) {
      selectedProductIds.remove(productId);
    } else {
      selectedProductIds.add(productId);
    }
  }

  @action
  void selectAllProductsForSubcategory(int subcategoryId, bool selected) {
    if (budgetData == null) return;

    final products = budgetData!.products
        .where((p) => p.category.contains(subcategoryId.toString()));

    if (selected) {
      selectedProductIds.addAll(products.map((p) => p.productId));
    } else {
      for (final product in products) {
        selectedProductIds.remove(product.productId);
      }
    }
  }

  @action
  void setStatus(String status) {
    selectedStatus = status;
  }

  @action
  void setArchived(bool archived) {
    isArchived = archived;
  }

  @action
  void setValidityDate(DateTime? date) {
    validityDate = date;
  }

  @action
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudget() async {
    if (budgetData == null) {
      error = 'Orçamento não carregado';
      return const Left(ValidationFailure('Orçamento não carregado'));
    }

    isSaving = true;
    error = null;

    try {
      print('🔄 [BudgetEditStore] Salvando alterações...');

      // Calcular dias de validade
      int? validityDays;
      if (validityDate != null) {
        final hoje = DateTime.now();
        final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
        validityDays = validityDate!.difference(hojeDate).inDays;
      }

      final result = await updateBudgetUseCase(
        budgetId: budgetData!.id,
        validityDays: validityDays,
        validityDate: validityDate,
        status: selectedStatus,
        isArchived: isArchived,
        selectedProductIds: selectedProductIds.toList(),
      );

      return result.fold(
        (failure) {
          print('❌ [BudgetEditStore] Erro ao salvar: ${failure.message}');
          error = failure.message;
          isSaving = false;
          return Left(failure);
        },
        (updatedBudget) {
          print('✅ [BudgetEditStore] Orçamento salvo com sucesso');
          budgetData = updatedBudget;
          isSaving = false;
          return Right(updatedBudget);
        },
      );
    } catch (e) {
      print('❌ [BudgetEditStore] Erro inesperado: $e');
      error = 'Erro ao salvar: $e';
      isSaving = false;
      return Left(UnknownFailure(e.toString()));
    }
  }

  @action
  void reset() {
    budgetData = null;
    selectedProductIds.clear();
    selectedStatus = 'pendente';
    isArchived = false;
    validityDate = null;
    error = null;
    isLoading = false;
    isSaving = false;
  }
}
