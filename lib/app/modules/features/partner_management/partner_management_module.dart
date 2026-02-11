import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/partner_management_api_datasource.dart';
import 'data/datasources/partner_management_datasource.dart';
import 'data/repositories/partner_management_repository_impl.dart';
import 'domain/repositories/partner_management_repository.dart';
import 'presentation/pages/partner_management_page.dart';
import 'presentation/stores/partner_management_store.dart';

/// Módulo de gerenciamento de parceiros (empresas)
/// Acessível apenas para Administradores
class PartnerManagementModule extends Module {
  @override
  List<Bind> get binds => [
    // Datasource
    Bind.lazySingleton<PartnerManagementDatasource>(
      (i) => PartnerManagementApiDatasource(httpClient: i.get<AppHttpClient>()),
    ),

    // Repository
    Bind.lazySingleton<PartnerManagementRepository>(
      (i) => PartnerManagementRepositoryImpl(
        datasource: i.get<PartnerManagementDatasource>(),
      ),
    ),

    // Store
    Bind.lazySingleton<PartnerManagementStore>(
      (i) => PartnerManagementStore(
        partnerManagementRepository: i.get<PartnerManagementRepository>(),
      ),
    ),
  ];

  @override
  List<ModularRoute> get routes => [
    // Rota principal
    ChildRoute('/', child: (context, args) => const PartnerManagementPage()),
  ];
}
