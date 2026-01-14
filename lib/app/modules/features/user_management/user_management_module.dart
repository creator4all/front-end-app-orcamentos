import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/user_management_api_datasource.dart';
import 'data/datasources/user_management_datasource.dart';
import 'data/repositories/user_management_repository_impl.dart';
import 'domain/repositories/user_management_repository.dart';
import 'domain/usecases/list_users_usecase.dart';
import 'domain/usecases/update_users_usecase.dart';
import 'presentation/pages/user_management_page.dart';
import 'presentation/stores/user_management_store.dart';

/// Módulo de gerenciamento de usuários
/// Segue Clean Architecture com injeção de dependências
class UserManagementModule extends Module {
  @override
  List<Bind> get binds => [
        // Datasource
        Bind.lazySingleton<UserManagementDatasource>(
          (i) => UserManagementApiDatasource(
            httpClient: i.get<AppHttpClient>(),
          ),
        ),

        // Repository
        Bind.lazySingleton<UserManagementRepository>(
          (i) => UserManagementRepositoryImpl(
            datasource: i.get<UserManagementDatasource>(),
          ),
        ),

        // UseCases
        Bind.lazySingleton<ListUsersUsecase>(
          (i) => ListUsersUsecase(i.get<UserManagementRepository>()),
        ),
        Bind.lazySingleton<UpdateUsersUsecase>(
          (i) => UpdateUsersUsecase(i.get<UserManagementRepository>()),
        ),

        // Store
        Bind.lazySingleton<UserManagementStore>(
          (i) => UserManagementStore(
            listUsersUsecase: i.get<ListUsersUsecase>(),
            updateUsersUsecase: i.get<UpdateUsersUsecase>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        // Rota principal (Gestor - seus usuários)
        ChildRoute(
          '/',
          child: (context, args) => const UserManagementPage(),
        ),
        // Rota com partnerId (Admin - usuários de um parceiro específico)
        ChildRoute(
          '/partner/:partnerId',
          child: (context, args) => UserManagementPage(
            partnerId: int.tryParse(args.params['partnerId'] ?? ''),
          ),
        ),
      ];
}
