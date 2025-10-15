import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/modules/features/auth/auth_module.dart';
// Auth - Clean Architecture (compartilhado globalmente)
import 'app/modules/features/auth/data/datasources/auth_api_datasource.dart';
import 'app/modules/features/auth/data/datasources/auth_datasource.dart';
import 'app/modules/features/auth/data/repositories/auth_repository_impl.dart';
import 'app/modules/features/auth/domain/repositories/auth_repository.dart';
import 'app/modules/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'app/modules/features/auth/domain/usecases/login_usecase.dart';
import 'app/modules/features/auth/domain/usecases/logout_usecase.dart';
import 'app/modules/features/auth/presentation/stores/auth_store.dart';
// import 'app/modules/budget/budget_module.dart'; // ANTIGO
import 'app/modules/features/budget/budget_module_new.dart'; // NOVO - Clean Architecture
// import 'app/modules/drive/drive_module.dart'; // ANTIGO - Legacy
import 'app/modules/features/new_drive/new_drive_module.dart'; // NOVO - Clean Architecture
import 'app/modules/partner/external/services/partner_service.dart';
import 'app/modules/partner/partner_module.dart';
import 'app/modules/profile/profile_module.dart';
import 'app/shared/core/http/dio_client.dart';
import 'services/api_service.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        // ==================== CORE ====================

        // Core HTTP Client
        Bind.singleton<Dio>((i) => DioClient().dio),

        // API Service
        Bind.singleton<ApiService>((i) => ApiService(dio: i.get<Dio>())),

        // Secure Storage (compartilhado globalmente)
        Bind.singleton<FlutterSecureStorage>(
          (i) => const FlutterSecureStorage(),
        ),

        // ==================== AUTH (Compartilhado Globalmente) ====================

        // DataSource
        Bind.singleton<AuthDatasource>(
          (i) => AuthApiDatasource(
            dio: i.get<Dio>(),
            secureStorage: i.get<FlutterSecureStorage>(),
          ),
        ),

        // Repository
        Bind.singleton<AuthRepository>(
          (i) => AuthRepositoryImpl(
            i.get<AuthDatasource>(),
          ),
        ),

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

        // Store (Disponível para todos os módulos)
        Bind.singleton<AuthStore>(
          (i) => AuthStore(
            loginUsecase: i.get<LoginUsecase>(),
            logoutUsecase: i.get<LogoutUsecase>(),
            getCurrentUserUsecase: i.get<GetCurrentUserUsecase>(),
          ),
        ),

        // ==================== PARTNER SERVICE ====================

        // Partner Service (compartilhado globalmente)
        Bind.singleton<PartnerService>(
          (i) => PartnerService(i<ApiService>(), i<FlutterSecureStorage>()),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        // Auth Module
        ModuleRoute('/auth', module: AuthModule()),

        // Budget Module - Clean Architecture
        ModuleRoute('/budget', module: BudgetModuleNew()),

        // Profile Module
        ModuleRoute('/profile', module: ProfileModule()),

        // Partner Module
        ModuleRoute('/partner', module: PartnerModule()),

        // Drive Module - Clean Architecture
        ModuleRoute('/drive', module: NewDriveModule()),

        // Redirect to auth by default
        RedirectRoute('/', to: '/auth/login'),
      ];
}
