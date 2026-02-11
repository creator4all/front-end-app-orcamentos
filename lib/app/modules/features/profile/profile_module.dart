import 'package:flutter_modular/flutter_modular.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';

import 'data/datasources/profile_api_datasource.dart';
import 'data/datasources/profile_datasource.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/stores/profile_store.dart';

class ProfileModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<ProfileDatasource>(
            (i) => ProfileApiDatasource(i<AppHttpClient>())),
        Bind.lazySingleton<ProfileRepository>(
            (i) => ProfileRepositoryImpl(i<ProfileDatasource>())),
        Bind.lazySingleton<ProfileStore>(
            (i) => ProfileStore(i<ProfileRepository>())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const ProfilePage()),
      ];
}
