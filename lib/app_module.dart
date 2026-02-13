import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/forgot_password_store.dart';
import 'package:multimidiaapp/app/modules/features/partner_management/partner_management_module.dart';
import 'package:multimidiaapp/app/modules/features/product_management/product_management_module.dart';

import 'app/modules/features/auth/auth_module.dart';
import 'app/modules/features/auth/data/datasources/auth_api_datasource.dart';
import 'app/modules/features/auth/data/datasources/auth_datasource.dart';
import 'app/modules/features/auth/data/repositories/auth_repository_impl.dart';
import 'app/modules/features/auth/domain/repositories/auth_repository.dart';
import 'app/modules/features/auth/domain/usecases/login_usecase.dart';
import 'app/modules/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'app/modules/features/auth/domain/usecases/resend_otp_code_usecase.dart';
import 'app/modules/features/auth/domain/usecases/reset_password_usecase.dart';
import 'app/modules/features/auth/domain/usecases/verify_otp_code_usecase.dart';
import 'app/modules/features/auth/presentation/stores/auth_store.dart';
import 'app/modules/features/budget/budget_module_new.dart';
import 'app/modules/features/new_drive/new_drive_module.dart';
import 'app/modules/features/partner/data/services/partner_service.dart';
import 'app/modules/features/partner/partner_module.dart';
import 'app/modules/features/profile/data/datasources/profile_api_datasource.dart';
import 'app/modules/features/profile/data/datasources/profile_datasource.dart';
import 'app/modules/features/profile/data/repositories/profile_repository_impl.dart';
import 'app/modules/features/profile/domain/repositories/profile_repository.dart';
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

        Bind.singleton<HttpClientConfig>(
          (i) => DioConfigFactory.createDefault(
            baseUrl: ApiConfig.baseUrl,
            getToken: () => TokenCache.instance.getTokenOrEmpty(),
            enableLogger: _isDebugMode(),
          ),
        ),

        Bind.singleton<AppHttpClient>(
          (i) => DioHttpClientImpl(i.get<HttpClientConfig>()),
        ),


        Bind.singleton<AuthService>(
          (i) => AuthService(client: i.get<AppHttpClient>()),
        ),

        Bind.singleton<GeoService>(
          (i) => GeoService(client: i.get<AppHttpClient>()),
        ),

        Bind.singleton<CensoService>(
          (i) => CensoService(client: i.get<AppHttpClient>()),
        ),


        Bind.singleton<FlutterSecureStorage>(
            (i) => const FlutterSecureStorage()),


        Bind.singleton<AuthDatasource>(
          (i) => AuthApiDatasource(
            httpClient: i.get<AppHttpClient>(),
            secureStorage: i.get<FlutterSecureStorage>(),
          ),
        ),

        Bind.singleton<AuthRepository>(
          (i) => AuthRepositoryImpl(i.get<AuthDatasource>()),
        ),

        Bind.singleton<LoginUsecase>(
            (i) => LoginUsecase(i.get<AuthRepository>())),

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

        Bind.singleton<AuthStore>(
          (i) => AuthStore(
            loginUsecase: i.get<LoginUsecase>(),
            authRepository: i.get<AuthRepository>(),
            secureStorage: i.get<FlutterSecureStorage>(),
          ),
        ),

        Bind.singleton<ForgotPasswordStore>(
          (i) => ForgotPasswordStore(
            i.get<RequestPasswordResetUsecase>(),
            i.get<ResendOtpCodeUsecase>(),
            i.get<VerifyOtpCodeUsecase>(),
            i.get<ResetPasswordUsecase>(),
          ),
        ),


        Bind.singleton<PartnerService>(
          (i) => PartnerService(i<AppHttpClient>(), i<FlutterSecureStorage>()),
        ),


        Bind.singleton<ProfileDatasource>(
            (i) => ProfileApiDatasource(i<AppHttpClient>())),
        Bind.singleton<ProfileRepository>(
            (i) => ProfileRepositoryImpl(i<ProfileDatasource>())),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/auth', module: AuthModule()),

        ModuleRoute('/budget', module: BudgetModuleNew()),

        ModuleRoute('/profile', module: ProfileModule()),

        ModuleRoute('/partner', module: PartnerModule()),

        ModuleRoute('/drive', module: NewDriveModule()),

        ModuleRoute('/user-management', module: UserManagementModule()),

        ModuleRoute('/partner-management', module: PartnerManagementModule()),

        ModuleRoute('/prospect', module: ProspectModule()),

        ModuleRoute('/product-management', module: ProductManagementModule()),

        ModuleRoute('/reports', module: ReportsModule()),

        RedirectRoute('/', to: '/auth/login'),
      ];

  bool _isDebugMode() {
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }
}
