import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/pages/budget_list_page.dart';
import 'presentation/pages/config_new_budget.dart';
import 'presentation/pages/new_budget_page.dart';

class BudgetModule extends Module {
  @override
  List<Bind> get binds => [
        // TODO: Implementar binds do módulo de orçamentos
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const BudgetListPage()),
        ChildRoute('/new', child: (context, args) => const NewBudgetPage()),
        ChildRoute('/config',
            child: (context, args) => const ConfigNewBudgetPage()),
      ];
}
