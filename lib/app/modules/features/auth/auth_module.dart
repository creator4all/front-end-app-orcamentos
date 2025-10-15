import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/pages/login_page.dart';

/// Módulo de autenticação seguindo Clean Architecture
///
/// NOTA: Todas as dependências (DataSources, Repositories, UseCases, Store)
/// estão registradas no AppModule para serem compartilhadas globalmente.
/// Este módulo contém apenas as rotas específicas de autenticação.
class AuthModule extends Module {
  @override
  List<Bind> get binds => [
        // Todos os binds foram movidos para o AppModule
        // para serem compartilhados globalmente
      ];

  @override
  List<ModularRoute> get routes => [
        // Rota de login
        ChildRoute(
          '/login',
          child: (context, args) => const LoginPage(),
        ),

        // Rota padrão redireciona para login
        RedirectRoute('/', to: '/login'),
      ];
}
