import 'package:flutter_modular/flutter_modular.dart';

import '../../../../config/api_config.dart';
import '../../../../services/api_service.dart';
import '../../../shared/core/http/app_http_client.dart';
import '../../../shared/core/http/dio_client.dart';
import '../../../shared/core/http/dio_config_factory.dart';
import '../../../shared/core/http/dio_http_client_impl.dart';
import '../../../shared/core/utils/token_cache.dart';
import '../auth/presentation/stores/auth_store.dart';
// Budget Config - Clean Architecture
import 'budget_config/data/datasources/budget_detail_remote_datasource.dart';
import 'budget_config/data/datasources/budget_detail_remote_datasource_impl.dart';
import 'budget_config/data/datasources/census_remote_datasource.dart';
import 'budget_config/data/datasources/census_remote_datasource_impl.dart';
import 'budget_config/data/repositories/budget_detail_repository_impl.dart';
import 'budget_config/data/repositories/census_repository_impl.dart';
import 'budget_config/domain/entities/censo_escolar_entity.dart';
import 'budget_config/domain/repositories/budget_detail_repository.dart';
import 'budget_config/domain/repositories/census_repository.dart';
import 'budget_config/domain/services/product_calculation_service.dart';
import 'budget_config/domain/usecases/calculate_totals_usecase.dart';
import 'budget_config/domain/usecases/finalize_budget_usecase.dart';
import 'budget_config/domain/usecases/get_all_budget_products_usecase.dart';
import 'budget_config/domain/usecases/get_budget_detail_usecase.dart';
import 'budget_config/domain/usecases/get_category_products_usecase.dart';
import 'budget_config/domain/usecases/get_census_data_usecase.dart';
import 'budget_config/domain/usecases/get_census_usecase.dart';
import 'budget_config/domain/usecases/save_budget_usecase.dart';
import 'budget_config/domain/usecases/toggle_category_usecase.dart';
import 'budget_config/domain/usecases/update_budget_census_usecase.dart';
import 'budget_config/domain/usecases/update_census_usecase.dart';
import 'budget_config/presentation/pages/config_new_budget_page.dart';
import 'budget_config/presentation/pages/school_census_page.dart';
import 'budget_config/presentation/stores/budget_config_store.dart';
import 'budget_config/presentation/stores/school_census_store.dart';
import 'budget_create/data/datasources/budget_draft_remote_datasource.dart';
import 'budget_create/data/datasources/budget_draft_remote_datasource_impl.dart';
import 'budget_create/data/datasources/partner_remote_datasource.dart';
import 'budget_create/data/datasources/partner_remote_datasource_impl.dart';
// Budget Create - Clean Architecture
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
import 'budget_edit/data/datasources/budget_pdf_remote_datasource.dart';
import 'budget_edit/data/datasources/budget_pdf_remote_datasource_impl.dart';
import 'budget_edit/data/datasources/indicators_remote_datasource.dart';
import 'budget_edit/data/datasources/indicators_remote_datasource_impl.dart';
import 'budget_edit/data/repositories/budget_edit_repository_impl.dart';
import 'budget_edit/data/repositories/budget_pdf_repository_impl.dart';
import 'budget_edit/data/repositories/indicators_repository_impl.dart';
import 'budget_edit/domain/repositories/budget_edit_repository.dart';
import 'budget_edit/domain/repositories/budget_pdf_repository.dart';
import 'budget_edit/domain/repositories/indicators_repository.dart';
import 'budget_edit/domain/usecases/generate_pdf_usecase.dart';
import 'budget_edit/domain/usecases/get_all_budget_products_for_edit_usecase.dart';
import 'budget_edit/domain/usecases/get_budget_for_edit_usecase.dart';
import 'budget_edit/domain/usecases/save_indicators_usecase.dart';
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
// Budget Multi-City - Clean Architecture
import 'budget_multi_city/data/datasources/multi_city_budget_remote_datasource.dart';
import 'budget_multi_city/data/datasources/multi_city_budget_remote_datasource_impl.dart';
import 'budget_multi_city/data/repositories/multi_city_budget_repository_impl.dart';
import 'budget_multi_city/domain/repositories/multi_city_budget_repository.dart';
import 'budget_multi_city/domain/usecases/create_multi_city_budget_usecase.dart';
import 'budget_multi_city/domain/usecases/get_multi_city_census_usecase.dart';
import 'budget_multi_city/presentation/pages/multi_city_census_page.dart';
import 'budget_multi_city/presentation/stores/multi_city_census_store.dart';

// TODO: Imports para Budget Edit (a implementar)

class BudgetModuleNew extends Module {
  @override
  List<Bind> get binds => [
        // ==================== CORE ====================
        Bind.lazySingleton((i) => DioClient()),
        Bind.lazySingleton((i) => ApiService(dio: i.get<DioClient>().dio)),

        // ==================== NEW HTTP CLIENT (AppHttpClient) ====================
        Bind.lazySingleton<AppHttpClient>(
          (i) => DioHttpClientImpl(
            DioConfigFactory.createDefault(
              baseUrl: ApiConfig.baseUrl,
              getToken: () => TokenCache.instance.getTokenOrEmpty(),
              enableLogger: true,
            ),
          ),
        ),

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
          (i) => PartnerRemoteDataSourceImpl(i.get<AppHttpClient>()),
        ),
        Bind.lazySingleton<BudgetDraftRemoteDataSource>(
          (i) => BudgetDraftRemoteDataSourceImpl(i.get<AppHttpClient>()),
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
        Bind.lazySingleton(
          (i) => GetCensusUseCase(i.get<CensusRepository>()),
        ),
        Bind.lazySingleton(
          (i) => UpdateCensusUseCase(i.get<CensusRepository>()),
        ),
        Bind.lazySingleton(
          (i) => UpdateBudgetCensusUseCase(i.get<CensusRepository>()),
        ),

        // Services
        Bind.lazySingleton<ProductCalculationService>(
          (i) => const ProductCalculationService(),
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
            calculationService: i.get<ProductCalculationService>(),
          ),
        ),

        Bind.lazySingleton(
          (i) => SchoolCensusStore(
            i.get<GetCensusUseCase>(),
            i.get<UpdateCensusUseCase>(),
            i.get<UpdateBudgetCensusUseCase>(),
          ),
        ),

        // ==================== BUDGET EDIT ====================
        // DataSources
        Bind.lazySingleton<BudgetEditRemoteDataSource>(
          (i) => BudgetEditRemoteDataSourceImpl(i.get<ApiService>()),
        ),
        Bind.lazySingleton<BudgetPdfRemoteDataSource>(
          (i) => BudgetPdfRemoteDataSourceImpl(i.get<AppHttpClient>()),
        ),
        Bind.lazySingleton<IndicatorsRemoteDataSource>(
          (i) => IndicatorsRemoteDataSourceImpl(i.get<AppHttpClient>()),
        ),

        // Repositories
        Bind.lazySingleton<BudgetEditRepository>(
          (i) => BudgetEditRepositoryImpl(i.get<BudgetEditRemoteDataSource>()),
        ),
        Bind.lazySingleton<BudgetPdfRepository>(
          (i) => BudgetPdfRepositoryImpl(i.get<BudgetPdfRemoteDataSource>()),
        ),
        Bind.lazySingleton<IndicatorsRepository>(
          (i) => IndicatorsRepositoryImpl(i.get<IndicatorsRemoteDataSource>()),
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
        Bind.lazySingleton<GeneratePdfUseCase>(
          (i) => GeneratePdfUseCase(i.get<BudgetPdfRepository>()),
        ),
        Bind.lazySingleton<SaveIndicatorsUseCase>(
          (i) => SaveIndicatorsUseCase(i.get<IndicatorsRepository>()),
        ),

        // Stores
        Bind.lazySingleton<BudgetEditStore>(
          (i) => BudgetEditStore(
            getBudgetForEditUseCase: i.get<GetBudgetForEditUseCase>(),
            getAllProductsUseCase: i.get<GetAllBudgetProductsForEditUseCase>(),
            updateBudgetUseCase: i.get<UpdateBudgetUseCase>(),
            getCensusDataUseCase: i.get<GetCensusDataUseCase>(),
            authStore: Modular.get<AuthStore>(),
            calculationService: i.get<ProductCalculationService>(),
          ),
        ),

        // ==================== BUDGET MULTI-CITY ====================
        // DataSources
        Bind.lazySingleton<MultiCityBudgetRemoteDataSource>(
          (i) => MultiCityBudgetRemoteDataSourceImpl(i.get<ApiService>()),
        ),

        // Repositories
        Bind.lazySingleton<MultiCityBudgetRepository>(
          (i) => MultiCityBudgetRepositoryImpl(
              i.get<MultiCityBudgetRemoteDataSource>()),
        ),

        // UseCases
        Bind.lazySingleton<GetMultiCityCensusUseCase>(
          (i) => GetMultiCityCensusUseCase(i.get<MultiCityBudgetRepository>()),
        ),
        Bind.lazySingleton<CreateMultiCityBudgetUseCase>(
          (i) =>
              CreateMultiCityBudgetUseCase(i.get<MultiCityBudgetRepository>()),
        ),

        // Stores
        Bind.lazySingleton<MultiCityCensusStore>(
          (i) => MultiCityCensusStore(
            i.get<GetMultiCityCensusUseCase>(),
            i.get<CreateMultiCityBudgetUseCase>(),
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
          final arguments = args.data as Map<String, dynamic>?;
          final location = arguments?['location'] as Map<String, dynamic>?;

          return ConfigNewBudgetPage(
            budgetId: budgetId,
            cityName: location?['cityName'],
            stateName: location?['stateName'],
          );
        }),

        // School Census
        ChildRoute('/census/:cityId', child: (context, args) {
          final cityId = int.parse(args.params['cityId']);
          // Extrai argumentos
          final argsData = args.data as Map<String, dynamic>?;
          final censoEscolar = argsData?['censoEscolar'] as CensoEscolarEntity?;
          final budgetId = argsData?['budgetId'] as int?;
          final onCensusUpdated =
              argsData?['onCensusUpdated'] as Function(CensoEscolarEntity)?;

          return SchoolCensusPage(
            cityId: cityId,
            budgetId: budgetId,
            censoInicial: censoEscolar,
            onCensusUpdated: onCensusUpdated,
          );
        }),

        // Budget Edit
        ChildRoute('/edit/:budgetId', child: (context, args) {
          final budgetId = int.parse(args.params['budgetId']);
          return EditBudgetPage(budgetId: budgetId);
        }),

        // Multi-City Census
        ChildRoute('/multi-city/census', child: (context, args) {
          final argsData = args.data as Map<String, dynamic>?;
          final budgetName = argsData?['budgetName'] as String? ?? 'Orçamento';
          final budgetId = argsData?['budgetId'] as int?;
          final selectedCities = (argsData?['selectedCities'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          return MultiCityCensusPage(
            budgetName: budgetName,
            budgetId: budgetId,
            selectedCities: selectedCities,
          );
        }),
      ];
}
