import 'package:flutter/widgets.dart';

/// Observer único do Navigator raiz, registrado via `Modular.setObservers`.
///
/// Permite que uma página saiba quando voltou a ser a rota visível
/// (`RouteAware.didPopNext`) e recarregue seus dados. É a única forma
/// confiável de detectar o retorno quando a rota intermediária foi removida
/// da pilha por `pushNamedAndRemoveUntil`, caso em que o `Future` do
/// `pushNamed` original é concluído antes de o usuário voltar.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
