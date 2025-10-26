import 'package:flutter_modular/flutter_modular.dart';
import 'package:multimidiaapp/services/api_service.dart';

import '../../shared/core/http/dio_client.dart';
import '../features/budget/budget_config/data/datasources/census_remote_datasource.dart';
import '../features/budget/budget_config/data/datasources/census_remote_datasource_impl.dart';
import '../features/budget/budget_config/data/repositories/census_repository_impl.dart';
import '../features/budget/budget_config/domain/repositories/census_repository.dart';
// Imports para reutilizar use cases do budget_config
import '../features/budget/budget_config/domain/usecases/get_census_data_usecase.dart';
import '../features/budget/budget_edit/data/datasources/budget_edit_remote_datasource.dart';
import '../features/budget/budget_edit/data/datasources/budget_edit_remote_datasource_impl.dart';
import '../features/budget/budget_edit/data/repositories/budget_edit_repository_impl.dart';
// Imports da nova estrutura de features - Budget Edit
import '../features/budget/budget_edit/domain/repositories/budget_edit_repository.dart';
import '../features/budget/budget_edit/domain/usecases/get_all_budget_products_for_edit_usecase.dart';
import '../features/budget/budget_edit/domain/usecases/get_budget_for_edit_usecase.dart';
import '../features/budget/budget_edit/domain/usecases/update_budget_usecase.dart';
import '../features/budget/budget_edit/presentation/pages/edit_budget_page.dart'
    as edit_feature;
import '../features/budget/budget_edit/presentation/stores/budget_edit_store.dart'
    as edit_feature;
import 'external/services/budget_service.dart';
import 'external/services/category_service.dart';
import 'external/services/product_service.dart';
import 'external/services/subcategory_service.dart';
import 'presentation/pages/budget_list_page.dart';
import 'presentation/pages/config_new_budget.dart';
import 'presentation/pages/new_budget_page.dart';
import 'presentation/pages/school_census.dart';
import 'presentation/stores/books_subcategory_store.dart';
import 'presentation/stores/budget_edit_store.dart';
import 'presentation/stores/budget_list_store.dart';
import 'presentation/stores/card_selection_store.dart';
import 'presentation/stores/category_store.dart';
import 'presentation/stores/product_store.dart';
import 'presentation/stores/subcategory_store.dart';

class BudgetModule extends Module {
  @override
  List<Bind> get binds => [
        // Core services
        Bind.lazySingleton((i) => DioClient()),
        Bind.lazySingleton((i) => ApiService(dio: i.get<DioClient>().dio)),

        // Legacy services
        Bind.lazySingleton((i) => CategoryService(i.get())),
        Bind.lazySingleton((i) => SubcategoryService(i.get())),
        Bind.lazySingleton((i) => ProductService(i.get())),
        Bind.lazySingleton((i) => BudgetService(i.get<ApiService>())),

        // Legacy stores
        Bind.lazySingleton((i) => BudgetListStore(i.get<BudgetService>())),
        Bind.lazySingleton((i) =>
            BudgetEditStore(i.get<BudgetService>(), i.get<ProductStore>())),
        Bind.lazySingleton((i) => CategoryStore(i.get())),
        Bind.lazySingleton((i) => SubcategoryStore(i.get())),
        Bind.lazySingleton((i) => BooksSubcategoryStore(i.get())),
        Bind.lazySingleton((i) => ProductStore(i.get())),
        Bind.lazySingleton((i) => CardSelectionStore()),

        // ===== NOVA ESTRUTURA: Budget Edit Feature =====

        // Census (compartilhado com budget_config)
        Bind.lazySingleton<CensusRemoteDataSource>(
          (i) => CensusRemoteDataSourceImpl(i.get()),
        ),
        Bind.lazySingleton<CensusRepository>(
          (i) => CensusRepositoryImpl(i.get()),
        ),
        Bind.lazySingleton((i) => GetCensusDataUseCase(i.get())),

        // Budget Edit - Data Layer
        Bind.lazySingleton<BudgetEditRemoteDataSource>(
          (i) => BudgetEditRemoteDataSourceImpl(i.get()),
        ),
        Bind.lazySingleton<BudgetEditRepository>(
          (i) => BudgetEditRepositoryImpl(i.get()),
        ),

        // Budget Edit - Domain Layer
        Bind.lazySingleton((i) => GetBudgetForEditUseCase(i.get())),
        Bind.lazySingleton((i) => GetAllBudgetProductsForEditUseCase(i.get())),
        Bind.lazySingleton((i) => UpdateBudgetUseCase(i.get())),

        // Budget Edit - Presentation Layer
        Bind.lazySingleton((i) => edit_feature.BudgetEditStore(
              getBudgetForEditUseCase: i.get(),
              getAllProductsUseCase: i.get(),
              updateBudgetUseCase: i.get(),
              getCensusDataUseCase: i.get(),
            )),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const BudgetListPage()),
        ChildRoute('/new', child: (context, args) => const NewBudgetPage()),
        ChildRoute('/config/:budgetId', child: (context, args) {
          final budgetId = int.parse(args.params['budgetId']);
          return ConfigNewBudgetPage(budgetId: budgetId);
        }),
        ChildRoute('/census',
            child: (context, args) => const SchoolCensusPage()),

        // ===== NOVA ROTA: Edição de Orçamento =====
        ChildRoute('/edit/:budgetId', child: (context, args) {
          final budgetId = int.parse(args.params['budgetId']);
          return edit_feature.EditBudgetPage(budgetId: budgetId);
        }),
      ];
}
