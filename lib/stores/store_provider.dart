import "package:flutter/material.dart";
import "auth_store.dart";
import "login_store.dart";
import "budget_store.dart";

class StoreProvider extends InheritedWidget {
  final AuthStore authStore;
  final LoginStore loginStore;
  final BudgetStore budgetStore;

  StoreProvider({
    Key? key,
    required Widget child,
  }) : 
    authStore = AuthStore(),
    loginStore = LoginStore(authStore), // Fixed: Uses the same authStore instance
    budgetStore = BudgetStore(authStore), // Fixed: Uses the same authStore instance
    super(key: key, child: child);

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
