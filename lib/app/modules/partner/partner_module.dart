import 'package:flutter_modular/flutter_modular.dart';

import 'external/services/partner_service.dart';
import 'presentation/pages/partner_edit_page.dart';
import 'presentation/stores/partner_store.dart';

class PartnerModule extends Module {
  @override
  List<Bind> get binds => [
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
