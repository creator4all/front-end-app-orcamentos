import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multimidiaapp/services/api_service.dart';
import 'external/services/partner_service.dart';
import 'presentation/pages/partner_edit_page.dart';
import 'presentation/stores/partner_store.dart';

class PartnerModule extends Module {
  @override
  List<Bind> get binds => [
        // Secure Storage
        Bind.singleton<FlutterSecureStorage>(
          (i) => const FlutterSecureStorage(),
        ),

        // Partner Service
        Bind.lazySingleton<PartnerService>(
          (i) => PartnerService(i<ApiService>(), i<FlutterSecureStorage>()),
        ),

        // Partner Store
        Bind.lazySingleton<PartnerStore>(
          (i) => PartnerStore(i<PartnerService>()),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/edit', child: (context, args) => const PartnerEditPage()),
      ];
}
