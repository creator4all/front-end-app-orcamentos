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
      print('🔄 Carregando orçamentos da API...');
      items = await _service.listar(status: status);
      print('✅ Orçamentos carregados: ${items.length}');
      for (final item in items) {
        print('   - ID: ${item.id}, Nome: ${item.nome}, Status: ${item.status}, Total: R\$ ${item.total}');
      }
    } catch (e) {
      print('❌ Erro ao carregar orçamentos: $e');
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refresh() async {
    await fetch();
  }
}
