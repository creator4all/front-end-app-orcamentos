import 'package:mobx/mobx.dart';
import '../../../budget/external/services/budget_service.dart';
import '../../../budget/domain/models/budget_summary.dart';

part 'budget_list_store.g.dart';

class BudgetListStore = _BudgetListStore with _$BudgetListStore;

abstract class _BudgetListStore with Store {
  final BudgetService _service;
  _BudgetListStore(this._service);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  List<BudgetSummaryDto> items = [];

  @action
  Future<void> fetch({String? status}) async {
    isLoading = true;
    error = null;
    try {
      items = await _service.listar(status: status);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
