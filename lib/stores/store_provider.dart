import "package:flutter/material.dart";
import "auth_store.dart";
import "login_store.dart";
import "budget_store.dart";

class StoreProvider extends InheritedWidget {
  final AuthStore authStore;
  final LoginStore loginStore;
  final BudgetStore budgetStore;

  // Private constructor that takes pre-initialized stores
  StoreProvider._({
    Key? key,
    required this.authStore,
    required this.loginStore,
    required this.budgetStore,
    required Widget child,
  }) : super(key: key, child: child);
  
  // Factory constructor that properly initializes all stores
  factory StoreProvider({
    Key? key,
    required Widget child,
  }) {
    // Create a single shared AuthStore instance
    final authStore = AuthStore();
    
    // Create other stores using the shared AuthStore
    final loginStore = LoginStore(authStore);
    final budgetStore = BudgetStore(authStore);
    
    // Return a new StoreProvider with all stores properly initialized
    return StoreProvider._(
      key: key,
      authStore: authStore,
      loginStore: loginStore,
      budgetStore: budgetStore,
      child: child,
    );
  }

  static StoreProvider of(BuildContext context) {
    final StoreProvider? result =
        context.dependOnInheritedWidgetOfExactType<StoreProvider>();
    assert(result != null, "No StoreProvider found in context");
    return result!;
  }

  @override
  bool updateShouldNotify(StoreProvider oldWidget) {
    return true;
  }
}
