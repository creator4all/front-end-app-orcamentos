import 'package:flutter_modular/flutter_modular.dart';
import 'presentation/pages/profile_page.dart';

class ProfileModule extends Module {
  @override
  List<Bind> get binds => [
        // TODO: Implementar binds do módulo de perfil
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const ProfilePage()),
      ];
}
