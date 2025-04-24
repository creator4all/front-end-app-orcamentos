import "package:mobx/mobx.dart";
import "../stores/auth_store.dart";

part "budget_store.g.dart";

class BudgetStore = _BudgetStore with _$BudgetStore;

abstract class _BudgetStore with Store {
  final AuthStore _authStore;

  _BudgetStore(this._authStore);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  String searchQuery = "";

  @observable
  ObservableList<Map<String, dynamic>> allBudgets = ObservableList<Map<String, dynamic>>();

  @observable
  String selectedFilter = "todos";

  @computed
  List<Map<String, dynamic>> get filteredBudgets {
    // Filter by user role
    List<Map<String, dynamic>> roleFilteredBudgets = _authStore.isManager
        ? allBudgets.toList() // Managers see all budgets
        : allBudgets.where((budget) => budget["sellerId"] == _authStore.user?.id).toList();
    
    // Filter by status
    if (selectedFilter != "todos") {
      roleFilteredBudgets = roleFilteredBudgets
          .where((budget) => budget["status"].toLowerCase() == selectedFilter.toLowerCase())
          .toList();
    }
    
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      roleFilteredBudgets = roleFilteredBudgets.where((budget) {
        final code = budget["code"].toString().toLowerCase();
        final city = budget["city"].toString().toLowerCase();
        return code.contains(query) || city.contains(query);
      }).toList();
    }
    
    return roleFilteredBudgets;
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  void setSelectedFilter(String filter) {
    selectedFilter = filter;
  }

  @action
  Future<void> fetchBudgets() async {
    isLoading = true;
    error = null;
    
    try {
      // In a real app, this would be an API call
      // For now, just use dummy data
      await Future.delayed(const Duration(milliseconds: 500));
      
      allBudgets = ObservableList.of([
        {
          "id": "1",
          "code": "D-3550308-341",
          "city": "São Paulo",
          "state": "SP",
          "date": "5/4/2024",
          "daysRemaining": 36,
          "value": 3868886148.50,
          "status": "aprovado",
          "sellerId": "1",
        },
        {
          "id": "2",
          "code": "D-4202107-119",
          "city": "Barra Velha",
          "state": "SC",
          "date": "15/3/2024",
          "daysRemaining": 10,
          "value": 45282630.80,
          "status": "pendente",
          "sellerId": "1",
        },
        {
          "id": "3",
          "code": "D-3304557-221",
          "city": "Rio de Janeiro",
          "state": "RJ",
          "date": "20/3/2024",
          "daysRemaining": 15,
          "value": 927500.75,
          "status": "não aprovado",
          "sellerId": "2",
        },
        {
          "id": "4",
          "code": "D-3106200-178",
          "city": "Belo Horizonte",
          "state": "MG",
          "date": "10/3/2024",
          "daysRemaining": 5,
          "value": 1250000.00,
          "status": "expirado",
          "sellerId": "2",
        },
        {
          "id": "5",
          "code": "D-4209102-562",
          "city": "Florianópolis",
          "state": "SC",
          "date": "1/4/2024",
          "daysRemaining": 25,
          "value": 3200000.00,
          "status": "arquivado",
          "sellerId": "1",
        },
      ]);
      
      isLoading = false;
    } catch (e) {
      isLoading = false;
      error = e.toString();
    }
  }
}
