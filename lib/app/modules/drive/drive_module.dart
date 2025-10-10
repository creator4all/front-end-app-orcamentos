import 'package:flutter_modular/flutter_modular.dart';
import 'package:multimidiaapp/services/api_service.dart';
import 'package:multimidiaapp/stores/auth_store.dart';

import 'external/services/drive_service.dart';
import 'presentation/pages/drive_page_new.dart';
import 'presentation/pages/file_detail_page.dart';
import 'presentation/stores/drive_store.dart';
import 'presentation/stores/my_files_store.dart';
import 'presentation/stores/shared_files_store.dart';

class DriveModule extends Module {
  @override
  List<Bind> get binds => [
        // Services
        Bind.lazySingleton((i) => DriveService(i.get<ApiService>())),

        // Stores - Registrar primeiro o DriveStore
        Bind.lazySingleton(
          (i) {
            final authStore = i.get<AuthStore>();
            return DriveStore(() => authStore.isAdmin);
          },
        ),

        Bind.lazySingleton(
          (i) {
            final authStore = i.get<AuthStore>();
            return SharedFilesStore(
              i.get<DriveService>(),
              () => authStore.user?.token,
            );
          },
        ),

        Bind.lazySingleton(
          (i) {
            final authStore = i.get<AuthStore>();
            return MyFilesStore(
              i.get<DriveService>(),
              () => authStore.user?.token,
            );
          },
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const DrivePageNew()),
        ChildRoute(
          '/file/:id',
          child: (context, args) {
            final file = args.data;
            return FileDetailPage(file: file);
          },
        ),
      ];
}
