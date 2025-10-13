import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'data/datasources/auth_api_datasource.dart';
import 'data/datasources/auth_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/stores/auth_store.dart';

/// Módulo de autenticação seguindo Clean Architecture
/// Configura todas as dependências e rotas do módulo
class AuthModule extends Module {
  @override
  List<Bind> get binds => [
        // === DATA LAYER ===

        // DataSource (Implementação concreta com Dio)
        Bind.singleton<AuthDatasource>(
          (i) => AuthApiDatasource(
            dio: i.get<Dio>(), // Dio vem do AppModule
            secureStorage:
                i.get<FlutterSecureStorage>(), // Storage do AppModule
          ),
        ),

        // Repository (Implementação concreta)
        Bind.singleton<AuthRepository>(
          (i) => AuthRepositoryImpl(
            i.get<AuthDatasource>(),
          ),
        ),

        // === DOMAIN LAYER ===

        // Use Cases
        Bind.singleton<LoginUsecase>(
          (i) => LoginUsecase(i.get<AuthRepository>()),
        ),
        Bind.singleton<LogoutUsecase>(
          (i) => LogoutUsecase(i.get<AuthRepository>()),
        ),
        Bind.singleton<GetCurrentUserUsecase>(
          (i) => GetCurrentUserUsecase(i.get<AuthRepository>()),
        ),

        // === PRESENTATION LAYER ===

        // Store (MobX State Management)
        Bind.singleton<AuthStore>(
          (i) => AuthStore(
            loginUsecase: i.get<LoginUsecase>(),
            logoutUsecase: i.get<LogoutUsecase>(),
            getCurrentUserUsecase: i.get<GetCurrentUserUsecase>(),
          ),
        ),
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
