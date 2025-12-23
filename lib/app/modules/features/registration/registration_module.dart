import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/registration_api_datasource.dart';
import 'data/repositories/registration_repository_impl.dart';
import 'domain/usecases/register_user_usecase.dart';
import 'domain/usecases/request_partner_usecase.dart';
import 'domain/usecases/verify_document_usecase.dart';
import 'presentation/pages/cnpj_search_page.dart';
import 'presentation/pages/partner_request_page.dart';
import 'presentation/pages/user_registration_page.dart';
import 'presentation/stores/registration_store.dart';

/// Módulo de cadastro/registro seguindo Clean Architecture
class RegistrationModule extends Module {
  @override
  List<Bind> get binds => [
        // Datasource
        Bind.lazySingleton<RegistrationApiDatasource>(
          (i) => RegistrationApiDatasource(
            httpClient: i.get<AppHttpClient>(),
          ),
        ),

        // Repository
        Bind.lazySingleton<RegistrationRepositoryImpl>(
          (i) => RegistrationRepositoryImpl(
            datasource: i.get<RegistrationApiDatasource>(),
          ),
        ),

        // UseCases
        Bind.lazySingleton<VerifyDocumentUseCase>(
          (i) => VerifyDocumentUseCase(
            i.get<RegistrationRepositoryImpl>(),
          ),
        ),
        Bind.lazySingleton<RegisterUserUseCase>(
          (i) => RegisterUserUseCase(
            i.get<RegistrationRepositoryImpl>(),
          ),
        ),
        Bind.lazySingleton<RequestPartnerUseCase>(
          (i) => RequestPartnerUseCase(
            i.get<RegistrationRepositoryImpl>(),
          ),
        ),

        // Store
        Bind.lazySingleton<RegistrationStore>(
          (i) => RegistrationStore(
            verifyDocumentUseCase: i.get<VerifyDocumentUseCase>(),
            registerUserUseCase: i.get<RegisterUserUseCase>(),
            requestPartnerUseCase: i.get<RequestPartnerUseCase>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        // Rota principal - Pesquisa CNPJ
        ChildRoute(
          '/',
          child: (context, args) => const CnpjSearchPage(),
        ),

        // Rota de cadastro de usuário
        ChildRoute(
          '/user-registration',
          child: (context, args) => const UserRegistrationPage(),
        ),

        // Rota de solicitação de parceria
        ChildRoute(
          '/partner-request',
          child: (context, args) => const PartnerRequestPage(),
        ),
      ];
}
