import 'package:flutter_modular/flutter_modular.dart';

import '../../../../services/api_service.dart';
import '../../../shared/core/http/dio_client.dart';
// Budget Config - Clean Architecture
import 'budget_config/data/datasources/budget_detail_remote_datasource.dart';
import 'budget_config/data/datasources/budget_detail_remote_datasource_impl.dart';
import 'budget_config/data/datasources/census_remote_datasource.dart';
import 'budget_config/data/datasources/census_remote_datasource_impl.dart';
import 'budget_config/data/repositories/budget_detail_repository_impl.dart';
import 'budget_config/data/repositories/census_repository_impl.dart';
import 'budget_config/domain/repositories/budget_detail_repository.dart';
import 'budget_config/domain/repositories/census_repository.dart';
import 'budget_config/domain/usecases/calculate_totals_usecase.dart';
import 'budget_config/domain/usecases/finalize_budget_usecase.dart';
import 'budget_config/domain/usecases/get_all_budget_products_usecase.dart';
import 'budget_config/domain/usecases/get_budget_detail_usecase.dart';
import 'budget_config/domain/usecases/get_category_products_usecase.dart';
import 'budget_config/domain/usecases/get_census_data_usecase.dart';
import 'budget_config/domain/usecases/save_budget_usecase.dart';
import 'budget_config/domain/usecases/toggle_category_usecase.dart';
import 'budget_config/presentation/pages/config_new_budget_page.dart';
import 'budget_config/presentation/stores/budget_config_store.dart';
// Budget Create - Clean Architecture
import 'budget_create/data/datasources/budget_draft_remote_datasource.dart';
import 'budget_create/data/datasources/budget_draft_remote_datasource_impl.dart';
import 'budget_create/data/datasources/partner_remote_datasource.dart';
import 'budget_create/data/datasources/partner_remote_datasource_impl.dart';
import 'budget_create/data/repositories/budget_draft_repository_impl.dart';
import 'budget_create/data/repositories/partner_repository_impl.dart';
import 'budget_create/domain/repositories/budget_draft_repository.dart';
import 'budget_create/domain/repositories/partner_repository.dart';
import 'budget_create/domain/usecases/create_draft_budget_usecase.dart';
import 'budget_create/domain/usecases/get_standard_partners_usecase.dart';
import 'budget_create/domain/usecases/validate_budget_data_usecase.dart';
import 'budget_create/presentation/pages/new_budget_page.dart';
import 'budget_create/presentation/stores/budget_create_store.dart';
// Budget Edit - Clean Architecture
import 'budget_edit/data/datasources/budget_edit_remote_datasource.dart';
import 'budget_edit/data/datasources/budget_edit_remote_datasource_impl.dart';
import 'budget_edit/data/repositories/budget_edit_repository_impl.dart';
import 'budget_edit/domain/repositories/budget_edit_repository.dart';
import 'budget_edit/domain/usecases/get_all_budget_products_for_edit_usecase.dart';
import 'budget_edit/domain/usecases/get_budget_for_edit_usecase.dart';
import 'budget_edit/domain/usecases/update_budget_usecase.dart';
import 'budget_edit/presentation/pages/edit_budget_page.dart';
import 'budget_edit/presentation/stores/budget_edit_store.dart';
// Budget List - Clean Architecture
import 'budget_list/data/datasources/budget_remote_datasource.dart';
import 'budget_list/data/datasources/budget_remote_datasource_impl.dart';
import 'budget_list/data/repositories/budget_list_repository_impl.dart';
import 'budget_list/domain/repositories/budget_list_repository.dart';
import 'budget_list/domain/usecases/delete_budget_usecase.dart';
import 'budget_list/domain/usecases/get_budget_by_id_usecase.dart';
import 'budget_list/domain/usecases/get_budgets_usecase.dart';
import 'budget_list/domain/usecases/rename_budget_usecase.dart';
import 'budget_list/presentation/pages/budget_list_page.dart';
import 'budget_list/presentation/stores/budget_list_store.dart';

// TODO: Imports para Budget Edit (a implementar)

class BudgetModuleNew extends Module {
  @override
  List<Bind> get binds => [
        // ==================== CORE ====================
        Bind.lazySingleton((i) => DioClient()),
        Bind.lazySingleton((i) => ApiService(dio: i.get<DioClient>().dio)),

        // ==================== BUDGET LIST ====================
        // DataSources
        Bind.lazySingleton<BudgetRemoteDataSource>(
          (i) => BudgetRemoteDataSourceImpl(i.get<ApiService>()),
        ),

        // Repositories
        Bind.lazySingleton<BudgetListRepository>(
          (i) => BudgetListRepositoryImpl(i.get<BudgetRemoteDataSource>()),
        ),

        // UseCases
        Bind.lazySingleton(
          (i) => GetBudgetsUseCase(i.get<BudgetListRepository>()),
        ),
        Bind.lazySingleton(
          (i) => GetBudgetByIdUseCase(i.get<BudgetListRepository>()),
        ),
        Bind.lazySingleton(
          (i) => RenameBudgetUseCase(i.get<BudgetListRepository>()),
        ),
        Bind.lazySingleton(
          (i) => DeleteBudgetUseCase(i.get<BudgetListRepository>()),
        ),

        // Stores
        Bind.lazySingleton(
          (i) => BudgetListStore(
            getBudgetsUseCase: i.get<GetBudgetsUseCase>(),
            renameBudgetUseCase: i.get<RenameBudgetUseCase>(),
            deleteBudgetUseCase: i.get<DeleteBudgetUseCase>(),
          ),
        ),

        // ==================== BUDGET CREATE ====================
        // DataSources
        Bind.lazySingleton<PartnerRemoteDataSource>(
          (i) => PartnerRemoteDataSourceImpl(i.get<ApiService>()),
        ),
        Bind.lazySingleton<BudgetDraftRemoteDataSource>(
          (i) => BudgetDraftRemoteDataSourceImpl(i.get<ApiService>()),
        ),

        // Repositories
        Bind.lazySingleton<PartnerRepository>(
          (i) => PartnerRepositoryImpl(i.get<PartnerRemoteDataSource>()),
        ),
        Bind.lazySingleton<BudgetDraftRepository>(
          (i) =>
              BudgetDraftRepositoryImpl(i.get<BudgetDraftRemoteDataSource>()),
        ),

        // UseCases
        Bind.lazySingleton<GetStandardPartnersUseCase>(
          (i) => GetStandardPartnersUseCase(i.get<PartnerRepository>()),
        ),
        Bind.lazySingleton<ValidateBudgetDataUseCase>(
          (i) => ValidateBudgetDataUseCase(i.get<BudgetDraftRepository>()),
        ),
        Bind.lazySingleton<CreateDraftBudgetUseCase>(
          (i) => CreateDraftBudgetUseCase(i.get<BudgetDraftRepository>()),
        ),

        // Stores
        Bind.lazySingleton<BudgetCreateStore>(
          (i) => BudgetCreateStore(
            getStandardPartnersUseCase: i.get<GetStandardPartnersUseCase>(),
            createDraftBudgetUseCase: i.get<CreateDraftBudgetUseCase>(),
            validateBudgetDataUseCase: i.get<ValidateBudgetDataUseCase>(),
          ),
        ),

        // ==================== BUDGET CONFIG ====================
        // DataSources
        Bind.lazySingleton<BudgetDetailRemoteDataSource>(
          (i) => BudgetDetailRemoteDataSourceImpl(i.get<ApiService>()),
        ),
        Bind.lazySingleton<CensusRemoteDataSource>(
          (i) => CensusRemoteDataSourceImpl(i.get<ApiService>()),
        ),

        // Repositories
        Bind.lazySingleton<BudgetDetailRepository>(
          (i) =>
              BudgetDetailRepositoryImpl(i.get<BudgetDetailRemoteDataSource>()),
        ),
        Bind.lazySingleton<CensusRepository>(
          (i) => CensusRepositoryImpl(i.get<CensusRemoteDataSource>()),
        ),

        // UseCases
        Bind.lazySingleton<GetBudgetDetailUseCase>(
          (i) => GetBudgetDetailUseCase(i.get<BudgetDetailRepository>()),
        ),
        Bind.lazySingleton<GetAllBudgetProductsUseCase>(
          (i) => GetAllBudgetProductsUseCase(i.get<BudgetDetailRepository>()),
        ),
        Bind.lazySingleton<GetCategoryProductsUseCase>(
          (i) => GetCategoryProductsUseCase(i.get<BudgetDetailRepository>()),
        ),
        Bind.lazySingleton<GetCensusDataUseCase>(
          (i) => GetCensusDataUseCase(i.get<CensusRepository>()),
        ),
        Bind.lazySingleton<ToggleCategoryUseCase>(
          (i) => ToggleCategoryUseCase(),
        ),
        Bind.lazySingleton<CalculateTotalsUseCase>(
          (i) => CalculateTotalsUseCase(),
        ),
        Bind.lazySingleton<FinalizeBudgetUseCase>(
          (i) => FinalizeBudgetUseCase(i.get<BudgetDetailRepository>()),
        ),
        Bind.lazySingleton<SaveBudgetUseCase>(
          (i) => SaveBudgetUseCase(i.get<BudgetDetailRepository>()),
        ),

        // Stores
        Bind.lazySingleton<BudgetConfigStore>(
          (i) => BudgetConfigStore(
            getBudgetDetailUseCase: i.get<GetBudgetDetailUseCase>(),
            getAllBudgetProductsUseCase: i.get<GetAllBudgetProductsUseCase>(),
            getCategoryProductsUseCase: i.get<GetCategoryProductsUseCase>(),
            getCensusDataUseCase: i.get<GetCensusDataUseCase>(),
            toggleCategoryUseCase: i.get<ToggleCategoryUseCase>(),
            calculateTotalsUseCase: i.get<CalculateTotalsUseCase>(),
            finalizeBudgetUseCase: i.get<FinalizeBudgetUseCase>(),
            saveBudgetUseCase: i.get<SaveBudgetUseCase>(),
          ),
        ),

        // ==================== BUDGET EDIT ====================
        // DataSources
        Bind.lazySingleton<BudgetEditRemoteDataSource>(
          (i) => BudgetEditRemoteDataSourceImpl(i.get<ApiService>()),
        ),

        // Repositories
        Bind.lazySingleton<BudgetEditRepository>(
          (i) => BudgetEditRepositoryImpl(i.get<BudgetEditRemoteDataSource>()),
        ),

        // UseCases
        Bind.lazySingleton<GetBudgetForEditUseCase>(
          (i) => GetBudgetForEditUseCase(i.get<BudgetEditRepository>()),
        ),
        Bind.lazySingleton<GetAllBudgetProductsForEditUseCase>(
          (i) =>
              GetAllBudgetProductsForEditUseCase(i.get<BudgetEditRepository>()),
        ),
        Bind.lazySingleton<UpdateBudgetUseCase>(
          (i) => UpdateBudgetUseCase(i.get<BudgetEditRepository>()),
        ),

        // Stores
        Bind.lazySingleton<BudgetEditStore>(
          (i) => BudgetEditStore(
            getBudgetForEditUseCase: i.get<GetBudgetForEditUseCase>(),
            getAllProductsUseCase: i.get<GetAllBudgetProductsForEditUseCase>(),
            updateBudgetUseCase: i.get<UpdateBudgetUseCase>(),
            getCensusDataUseCase: i.get<GetCensusDataUseCase>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        // Budget List
        ChildRoute('/', child: (context, args) => const BudgetListPage()),

        // Budget Create
        ChildRoute('/new', child: (context, args) => const NewBudgetPage()),

        // Budget Config
        ChildRoute('/config/:budgetId', child: (context, args) {
          final budgetId = int.parse(args.params['budgetId']);
          return ConfigNewBudgetPage(budgetId: budgetId);
        }),

        // Budget Edit
        ChildRoute('/edit/:budgetId', child: (context, args) {
          final budgetId = int.parse(args.params['budgetId']);
          return EditBudgetPage(budgetId: budgetId);
        }),
      ];
}
