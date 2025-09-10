import 'package:flutter_modular/flutter_modular.dart';
import 'presentation/pages/budget_list_page.dart';

class BudgetModule extends Module {
  @override
  List<Bind> get binds => [
        // TODO: Implementar binds do módulo de orçamentos
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const BudgetListPage()),
      ];
}
