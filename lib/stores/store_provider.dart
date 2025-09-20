import "package:flutter/material.dart";
import "auth_store.dart";
import "login_store.dart";
import "budget_store.dart";
import "geo_store.dart";
import "censo_store.dart";
import "../services/geo_service.dart";
import "../services/censo_service.dart";

class StoreProvider extends InheritedWidget {
  final AuthStore authStore;
  final LoginStore loginStore;
  final BudgetStore budgetStore;
  final GeoStore geoStore;
  final CensoStore censoStore;

  StoreProvider._({
    Key? key,
    required this.authStore,
    required this.loginStore,
    required this.budgetStore,
    required this.geoStore,
    required this.censoStore,
    required Widget child,
  }) : super(key: key, child: child);

  factory StoreProvider({
    Key? key,
    required Widget child,
  }) {
    final authStore = AuthStore();
    final loginStore = LoginStore(authStore);
    final budgetStore = BudgetStore(authStore);
    final geoStore = GeoStore(GeoService());
    final censoStore = CensoStore(CensoService());

    return StoreProvider._(
      key: key,
      authStore: authStore,
      loginStore: loginStore,
      budgetStore: budgetStore,
      geoStore: geoStore,
      censoStore: censoStore,
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
