import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/pages/drive_page.dart';
import 'presentation/stores/drive_store.dart';

class DriveModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton((i) => DriveStore()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const DrivePage()),
      ];
}
