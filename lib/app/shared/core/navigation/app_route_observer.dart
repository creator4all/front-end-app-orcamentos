import 'dart:async';

import 'package:flutter/widgets.dart';

import '../update/app_update_coordinator.dart';

/// Observer único do Navigator raiz, registrado via `Modular.setObservers`.
///
/// Permite que uma página saiba quando voltou a ser a rota visível
/// (`RouteAware.didPopNext`) e recarregue seus dados. É a única forma
/// confiável de detectar o retorno quando a rota intermediária foi removida
/// da pilha por `pushNamedAndRemoveUntil`, caso em que o `Future` do
/// `pushNamed` original é concluído antes de o usuário voltar.
final AppRouteObserver appRouteObserver = AppRouteObserver();

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null && route is PageRoute<dynamic>) {
      _scheduleUpdateCheck();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute<dynamic>) {
      _scheduleUpdateCheck();
    }
  }

  void _scheduleUpdateCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(appUpdateCoordinator.checkOptionalUpdateOnce());
    });
  }
}
