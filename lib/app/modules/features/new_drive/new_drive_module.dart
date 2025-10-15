import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'data/datasources/drive_remote_datasource.dart';
import 'data/repositories/drive_repository_impl.dart';
import 'domain/repositories/drive_repository.dart';
import 'domain/usecases/get_recent_items_usecase.dart';
import 'external/drive_remote_datasource_impl.dart';
import 'presentation/pages/new_drive_page.dart';
import 'presentation/stores/new_drive_store.dart';

/// Módulo do New Drive (Multi Drive)
///
/// Gerencia:
/// - Rotas do módulo
/// - Injeção de dependências (Stores, Repositories, UseCases)
class NewDriveModule extends Module {
  @override
  List<Bind> get binds => [
        // DataSources
        Bind.singleton<DriveRemoteDataSource>(
          (i) => DriveRemoteDataSourceImpl(i.get<Dio>()),
        ),

        // Repositories
        Bind.singleton<DriveRepository>(
          (i) => DriveRepositoryImpl(
            remoteDataSource: i.get<DriveRemoteDataSource>(),
          ),
        ),

        // Use Cases
        Bind.singleton<GetRecentItemsUseCase>(
          (i) => GetRecentItemsUseCase(i.get<DriveRepository>()),
        ),

        // Stores
        Bind.singleton<NewDriveStore>(
          (i) => NewDriveStore(
            getRecentItemsUseCase: i.get<GetRecentItemsUseCase>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        // Rota principal do módulo
        ChildRoute(
          '/',
          child: (context, args) => const NewDrivePage(),
        ),

        // TODO: Adicionar rotas para:
        // - Detalhes de arquivo
        // - Lista de arquivos por categoria
        // - Visualização de arquivo (preview)
      ];
}
