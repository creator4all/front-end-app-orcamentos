import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';
import 'app/modules/auth/auth_module.dart';
import 'app/modules/budget/budget_module.dart';
import 'app/modules/profile/profile_module.dart';
import 'app/shared/core/http/dio_client.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        // Core HTTP Client
        Bind.singleton<Dio>((i) => DioClient().dio),
      ];

  @override
  List<ModularRoute> get routes => [
        // Auth Module
        ModuleRoute('/auth', module: AuthModule()),

        // Budget Module
        ModuleRoute('/budget', module: BudgetModule()),

        // Profile Module
        ModuleRoute('/profile', module: ProfileModule()),

        // Redirect to auth by default
        RedirectRoute('/', to: '/auth/login'),
      ];
}
