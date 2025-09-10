import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'infra/repositories/auth_repository_impl.dart';
import 'infra/datasources/auth_datasource.dart';
import 'external/datasources/auth_api_datasource.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/pages/login_page.dart';

class AuthModule extends Module {
  @override
  List<Bind> get binds => [
        // External
        Bind.singleton<FlutterSecureStorage>(
            (i) => const FlutterSecureStorage()),
        Bind.singleton<AuthDatasource>(
          (i) => AuthApiDatasource(
            dio: i.get<Dio>(),
            secureStorage: i.get<FlutterSecureStorage>(),
          ),
        ),

        // Infra
        Bind.singleton<AuthRepository>(
          (i) => AuthRepositoryImpl(i.get<AuthDatasource>()),
        ),

        // Domain
        Bind.singleton<LoginUsecase>(
            (i) => LoginUsecase(i.get<AuthRepository>())),
        Bind.singleton<LogoutUsecase>(
            (i) => LogoutUsecase(i.get<AuthRepository>())),

        // Presentation
        Bind.singleton<AuthController>(
          (i) => AuthController(
            loginUsecase: i.get<LoginUsecase>(),
            logoutUsecase: i.get<LogoutUsecase>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/login', child: (context, args) => const LoginPage()),
        RedirectRoute('/', to: '/login'),
      ];
}
