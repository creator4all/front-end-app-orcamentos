import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/forgot_password_store.dart';
import 'package:multimidiaapp/app/modules/features/partner_management/partner_management_module.dart';
import 'package:multimidiaapp/app/modules/features/product_management/product_management_module.dart';

import 'app/modules/features/auth/auth_module.dart';
// Auth - Clean Architecture (compartilhado globalmente)
import 'app/modules/features/auth/data/datasources/auth_api_datasource.dart';
import 'app/modules/features/auth/data/datasources/auth_datasource.dart';
import 'app/modules/features/auth/data/repositories/auth_repository_impl.dart';
import 'app/modules/features/auth/domain/repositories/auth_repository.dart';
import 'app/modules/features/auth/domain/usecases/login_usecase.dart';
// Forgot Password Use Cases
import 'app/modules/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'app/modules/features/auth/domain/usecases/resend_otp_code_usecase.dart';
import 'app/modules/features/auth/domain/usecases/reset_password_usecase.dart';
import 'app/modules/features/auth/domain/usecases/verify_otp_code_usecase.dart';
import 'app/modules/features/auth/presentation/stores/auth_store.dart';
// import 'app/modules/budget/budget_module.dart'; // ANTIGO
import 'app/modules/features/budget/budget_module_new.dart'; // NOVO - Clean Architecture
// import 'app/modules/drive/drive_module.dart'; // ANTIGO - Legacy
import 'app/modules/features/new_drive/new_drive_module.dart'; // NOVO - Clean Architecture
import 'app/modules/features/partner/data/services/partner_service.dart';
import 'app/modules/features/partner/partner_module.dart';
import 'app/modules/features/profile/data/services/profile_service.dart';
import 'app/modules/features/profile/profile_module.dart';
import 'app/modules/features/prospect/prospect_module.dart';
import 'app/modules/features/reports/reports_module.dart';
import 'app/modules/features/user_management/user_management_module.dart';
import 'app/shared/core/http/app_http_client.dart';
import 'app/shared/core/http/dio_config_factory.dart';
import 'app/shared/core/http/dio_http_client_impl.dart';
import 'app/shared/core/http/http_client_config.dart';
import 'app/shared/core/utils/token_cache.dart';
import 'config/api_config.dart';
import 'services/auth_service.dart';
import 'services/censo_service.dart';
import 'services/geo_service.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
    // ==================== NOVO HTTP CLIENT ====================

    // Configuração do cliente HTTP
    Bind.singleton<HttpClientConfig>(
      (i) => DioConfigFactory.createDefault(
        baseUrl: ApiConfig.baseUrl,
        getToken: () => TokenCache.instance.getTokenOrEmpty(),
        enableLogger: _isDebugMode(),
      ),
    ),

    // Cliente HTTP (implementação concreta do AppHttpClient)
    Bind.singleton<AppHttpClient>(
      (i) => DioHttpClientImpl(i.get<HttpClientConfig>()),
    ),

    // ==================== SERVICES (Usando AppHttpClient) ====================

    // Auth Service
    Bind.singleton<AuthService>(
      (i) => AuthService(client: i.get<AppHttpClient>()),
    ),

    // Geo Service
    Bind.singleton<GeoService>(
      (i) => GeoService(client: i.get<AppHttpClient>()),
    ),

    // Censo Service
    Bind.singleton<CensoService>(
      (i) => CensoService(client: i.get<AppHttpClient>()),
    ),

    // ==================== CORE ====================

    // Secure Storage (compartilhado globalmente)
    Bind.singleton<FlutterSecureStorage>((i) => const FlutterSecureStorage()),

    // ==================== AUTH (Compartilhado Globalmente) ====================

    // DataSource
    Bind.singleton<AuthDatasource>(
      (i) => AuthApiDatasource(
        httpClient: i.get<AppHttpClient>(),
        secureStorage: i.get<FlutterSecureStorage>(),
      ),
    ),

    // Repository
    Bind.singleton<AuthRepository>(
      (i) => AuthRepositoryImpl(i.get<AuthDatasource>()),
    ),

    // Use Cases
    Bind.singleton<LoginUsecase>((i) => LoginUsecase(i.get<AuthRepository>())),

    // Forgot Password Use Cases
    Bind.singleton<RequestPasswordResetUsecase>(
      (i) => RequestPasswordResetUsecase(i.get<AuthRepository>()),
    ),
    Bind.singleton<ResendOtpCodeUsecase>(
      (i) => ResendOtpCodeUsecase(i.get<AuthRepository>()),
    ),
    Bind.singleton<VerifyOtpCodeUsecase>(
      (i) => VerifyOtpCodeUsecase(i.get<AuthRepository>()),
    ),
    Bind.singleton<ResetPasswordUsecase>(
      (i) => ResetPasswordUsecase(i.get<AuthRepository>()),
    ),

    // Store (Disponível para todos os módulos)
    Bind.singleton<AuthStore>(
      (i) => AuthStore(
        loginUsecase: i.get<LoginUsecase>(),
        authRepository: i.get<AuthRepository>(),
        secureStorage: i.get<FlutterSecureStorage>(),
      ),
    ),

    // Forgot Password Store
    Bind.singleton<ForgotPasswordStore>(
      (i) => ForgotPasswordStore(
        i.get<RequestPasswordResetUsecase>(),
        i.get<ResendOtpCodeUsecase>(),
        i.get<VerifyOtpCodeUsecase>(),
        i.get<ResetPasswordUsecase>(),
      ),
    ),

    // ==================== PARTNER SERVICE ====================

    // Partner Service (compartilhado globalmente)
    Bind.singleton<PartnerService>(
      (i) => PartnerService(i<AppHttpClient>(), i<FlutterSecureStorage>()),
    ),

    // ==================== PROFILE SERVICE ====================

    // Profile Service (compartilhado globalmente para deletar conta)
    Bind.singleton<ProfileService>((i) => ProfileService(i<AppHttpClient>())),
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

    // User Management Module - Gestão de Usuários
    ModuleRoute('/user-management', module: UserManagementModule()),

    // Partner Management Module - Gestão de Parceiros (Admin)
    ModuleRoute('/partner-management', module: PartnerManagementModule()),

    // Prospect Module - Prospecção de Parceiros
    ModuleRoute('/prospect', module: ProspectModule()),

    // Product Management Module - Gestão de Produtos (Admin)
    ModuleRoute('/product-management', module: ProductManagementModule()),

    // Reports Module - Relatórios de Orçamentos (Admin)
    ModuleRoute('/reports', module: ReportsModule()),

    // Redirect to auth by default
    RedirectRoute('/', to: '/auth/login'),
  ];

  /// Verifica se está em modo debug
  bool _isDebugMode() {
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }
}
