import 'package:flutter/material.dart';

import '../services/censo_service.dart';
import '../services/geo_service.dart';
import 'auth_store.dart';
import 'budget_store.dart';
import 'censo_store.dart';
import 'geo_store.dart';
import 'login_store.dart';

class StoreProvider extends InheritedWidget {
  final AuthStore authStore;
  final LoginStore loginStore;
  final BudgetStore budgetStore;
  final GeoStore geoStore;
  final CensoStore censoStore;

  const StoreProvider._({
    super.key,
    required this.authStore,
    required this.loginStore,
    required this.budgetStore,
    required this.geoStore,
    required this.censoStore,
    required super.child,
  });

  factory StoreProvider({
    Key? key,
    required Widget child,
  }) {
    final authStore = AuthStore();
    final loginStore = LoginStore(authStore);
    final budgetStore = BudgetStore(authStore);
    final geoStore = GeoStore(GeoService());
    final censoStore = CensoStore(CensoService());

    // Tentar auto-login quando o provider é criado
    _tentarAutoLogin(loginStore);

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

  // Método para tentar auto-login ao iniciar o app
  static void _tentarAutoLogin(LoginStore loginStore) {
    Future.delayed(Duration.zero, () async {
      try {
        final success = await loginStore.tryAutoLogin();
        if (success) {
          print('✅ Auto-login realizado com sucesso');
        } else {
          print('ℹ️ Nenhuma sessão anterior encontrada');
        }
      } catch (e) {
        print('⚠️ Erro no auto-login: $e');
      }
    });
  }

  static StoreProvider of(BuildContext context) {
    final StoreProvider? result =
        context.dependOnInheritedWidgetOfExactType<StoreProvider>();
    assert(result != null, 'No StoreProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(StoreProvider oldWidget) {
    return true;
  }
}
