import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/prospect_api_datasource.dart';
import 'data/datasources/prospect_datasource.dart';
import 'data/repositories/prospect_repository_impl.dart';
import 'domain/repositories/prospect_repository.dart';
import 'domain/usecases/list_prospects_usecase.dart';
import 'domain/usecases/mark_contacted_usecase.dart';
import 'presentation/pages/contacted_prospects_page.dart';
import 'presentation/pages/prospect_list_page.dart';
import 'presentation/stores/prospect_store.dart';

/// Módulo de prospecção de parceiros
/// Segue Clean Architecture com injeção de dependências
class ProspectModule extends Module {
  @override
  List<Bind> get binds => [
        // Datasource
        Bind.lazySingleton<ProspectDatasource>(
          (i) => ProspectApiDatasource(
            httpClient: i.get<AppHttpClient>(),
          ),
        ),

        // Repository
        Bind.lazySingleton<ProspectRepository>(
          (i) => ProspectRepositoryImpl(
            datasource: i.get<ProspectDatasource>(),
          ),
        ),

        // UseCases
        Bind.lazySingleton<ListProspectsUsecase>(
          (i) => ListProspectsUsecase(i.get<ProspectRepository>()),
        ),
        Bind.lazySingleton<MarkContactedUsecase>(
          (i) => MarkContactedUsecase(i.get<ProspectRepository>()),
        ),

        // Store
        Bind.lazySingleton<ProspectStore>(
          (i) => ProspectStore(
            listProspectsUsecase: i.get<ListProspectsUsecase>(),
            markContactedUsecase: i.get<MarkContactedUsecase>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        // Rota principal - lista de prospects não contactados
        ChildRoute(
          '/',
          child: (context, args) => const ProspectListPage(),
        ),
        // Rota para empresas já contactadas
        ChildRoute(
          '/contacted',
          child: (context, args) => const ContactedProspectsPage(),
        ),
      ];
}
