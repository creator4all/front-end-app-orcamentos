import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/prospect_api_datasource.dart';
import 'data/datasources/prospect_datasource.dart';
import 'data/repositories/prospect_repository_impl.dart';
import 'domain/repositories/prospect_repository.dart';
import 'presentation/pages/contacted_prospects_page.dart';
import 'presentation/pages/prospect_list_page.dart';
import 'presentation/stores/prospect_store.dart';

class ProspectModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<ProspectDatasource>(
          (i) => ProspectApiDatasource(httpClient: i.get<AppHttpClient>()),
        ),
        Bind.lazySingleton<ProspectRepository>(
          (i) =>
              ProspectRepositoryImpl(datasource: i.get<ProspectDatasource>()),
        ),
        Bind.lazySingleton<ProspectStore>(
          (i) => ProspectStore(prospectRepository: i.get<ProspectRepository>()),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const ProspectListPage()),
        ChildRoute(
          '/contacted',
          child: (context, args) => const ContactedProspectsPage(),
        ),
      ];
}
