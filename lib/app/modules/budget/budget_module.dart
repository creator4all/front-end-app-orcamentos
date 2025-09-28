import 'external/services/budget_service.dart';
import 'presentation/stores/budget_list_store.dart';

import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/stores/category_store.dart';
import 'presentation/stores/subcategory_store.dart';
import 'presentation/stores/books_subcategory_store.dart';
import 'presentation/stores/product_store.dart';
import 'presentation/stores/card_selection_store.dart';
import 'external/services/category_service.dart';
import 'external/services/subcategory_service.dart';
import 'external/services/product_service.dart';
import 'package:multimidiaapp/services/api_service.dart';
import '../../shared/core/http/dio_client.dart';

import 'presentation/pages/budget_list_page.dart';
import 'presentation/pages/config_new_budget.dart';
import 'presentation/pages/new_budget_page.dart';
import 'presentation/pages/school_census.dart';
import 'presentation/pages/edit_budget_page.dart';

class BudgetModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton((i) => DioClient()),
        Bind.lazySingleton((i) => ApiService(dio: i.get<DioClient>().dio)),
        Bind.lazySingleton((i) => CategoryService(i.get())),
        Bind.lazySingleton((i) => SubcategoryService(i.get())),
        Bind.lazySingleton((i) => ProductService(i.get())),
        Bind.lazySingleton((i) => BudgetService(i.get<ApiService>())),
        Bind.lazySingleton((i) => BudgetListStore(i.get<BudgetService>())),

        Bind.lazySingleton((i) => CategoryStore(i.get())),
        Bind.lazySingleton((i) => SubcategoryStore(i.get())),
        Bind.lazySingleton((i) => BooksSubcategoryStore(i.get())),
        Bind.lazySingleton((i) => ProductStore(i.get())),
        Bind.lazySingleton((i) => CardSelectionStore()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const BudgetListPage()),
        ChildRoute('/new', child: (context, args) => const NewBudgetPage()),
        ChildRoute('/config',
            child: (context, args) => const ConfigNewBudgetPage()),
        ChildRoute('/census',
            child: (context, args) => const SchoolCensusPage()),
        ChildRoute('/edit', child: (context, args) {
          final budget = args.data['budget'];
          return EditBudgetPage(budget: budget);
        }),
      ];
}
