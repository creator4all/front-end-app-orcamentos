import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/modules/budget/budget_module.dart';
import 'app/modules/drive/drive_module.dart';
import 'app/modules/features/auth/auth_module.dart';
import 'app/modules/partner/external/services/partner_service.dart';
import 'app/modules/partner/partner_module.dart';
import 'app/modules/profile/profile_module.dart';
import 'app/shared/core/http/dio_client.dart';
import 'services/api_service.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        // Core HTTP Client
        Bind.singleton<Dio>((i) => DioClient().dio),

        // API Service
        Bind.singleton<ApiService>((i) => ApiService(dio: i.get<Dio>())),

        // Secure Storage (compartilhado globalmente)
        Bind.singleton<FlutterSecureStorage>(
          (i) => const FlutterSecureStorage(),
        ),

        // Partner Service (compartilhado globalmente)
        Bind.singleton<PartnerService>(
          (i) => PartnerService(i<ApiService>(), i<FlutterSecureStorage>()),
        ),
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
