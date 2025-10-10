import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app/modules/auth/auth_module.dart';
import 'app/modules/budget/budget_module.dart';
import 'app/modules/drive/drive_module.dart';
import 'app/modules/partner/partner_module.dart';
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

        // Partner Module
        ModuleRoute('/partner', module: PartnerModule()),

        // Drive Module
        ModuleRoute('/drive', module: DriveModule()),

        // Redirect to auth by default
        RedirectRoute('/', to: '/auth/login'),
      ];
}
