import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../services/censo_service.dart';
import '../services/geo_service.dart';
import 'auth_store.dart';
import 'censo_store.dart';
import 'geo_store.dart';
import 'login_store.dart';

class StoreProvider extends InheritedWidget {
  final AuthStore authStore;
  final LoginStore loginStore;
  final GeoStore geoStore;
  final CensoStore censoStore;

  const StoreProvider._({
    super.key,
    required this.authStore,
    required this.loginStore,
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

    final geoStore = GeoStore(Modular.get<GeoService>());
    final censoStore = CensoStore(Modular.get<CensoService>());

    _tentarAutoLogin(loginStore);

    return StoreProvider._(
      key: key,
      authStore: authStore,
      loginStore: loginStore,
      geoStore: geoStore,
      censoStore: censoStore,
      child: child,
    );
  }

  static void _tentarAutoLogin(LoginStore loginStore) {
    Future.delayed(Duration.zero, () async {
      try {
        await loginStore.tryAutoLogin();
      } catch (_) {
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
