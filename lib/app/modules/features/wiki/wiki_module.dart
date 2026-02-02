import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/pages/wiki_page.dart';
import 'presentation/stores/wiki_store.dart';

/// Módulo da Wiki - Página de Ajuda
class WikiModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<WikiStore>((i) => WikiStore()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const WikiPage()),
      ];
}
