import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/registration_api_datasource.dart';
import 'data/repositories/registration_repository_impl.dart';
import 'domain/repositories/registration_repository.dart';
import 'domain/usecases/verify_document_usecase.dart';
import 'presentation/pages/cnpj_search_page.dart';
import 'presentation/pages/partner_request_page.dart';
import 'presentation/pages/user_registration_page.dart';
import 'presentation/stores/registration_store.dart';

class RegistrationModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.lazySingleton<RegistrationApiDatasource>(
      (i) => RegistrationApiDatasource(httpClient: i.get<AppHttpClient>()),
    ),

    Bind.lazySingleton<RegistrationRepository>(
      (i) => RegistrationRepositoryImpl(
        datasource: i.get<RegistrationApiDatasource>(),
      ),
    ),

    Bind.lazySingleton<VerifyDocumentUseCase>(
      (i) => VerifyDocumentUseCase(i.get<RegistrationRepository>()),
    ),

    Bind.lazySingleton<RegistrationStore>(
      (i) => RegistrationStore(
        verifyDocumentUseCase: i.get<VerifyDocumentUseCase>(),
        registrationRepository: i.get<RegistrationRepository>(),
      ),
    ),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => const CnpjSearchPage()),

    ChildRoute(
      '/user-registration',
      child: (context, args) => const UserRegistrationPage(),
    ),

    ChildRoute(
      '/partner-request',
      child: (context, args) => const PartnerRequestPage(),
    ),
  ];
}
