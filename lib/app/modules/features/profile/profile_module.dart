import 'package:flutter_modular/flutter_modular.dart';
import 'package:multimidiaapp/services/api_service.dart';

import 'data/services/profile_service.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/stores/profile_store.dart';

class ProfileModule extends Module {
  @override
  List<Bind> get binds => [
        // Profile Service
        Bind.lazySingleton<ProfileService>(
            (i) => ProfileService(i<ApiService>())),

        // Profile Store
        Bind.lazySingleton<ProfileStore>(
            (i) => ProfileStore(i<ProfileService>())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const ProfilePage()),
      ];
}
