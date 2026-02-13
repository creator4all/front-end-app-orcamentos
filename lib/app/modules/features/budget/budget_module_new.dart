import 'package:flutter_modular/flutter_modular.dart';

import '../../../../config/api_config.dart';
import '../../../shared/core/http/app_http_client.dart';
import '../../../shared/core/http/dio_config_factory.dart';
import '../../../shared/core/http/dio_http_client_impl.dart';
import '../../../shared/core/utils/token_cache.dart';
import '../auth/presentation/stores/auth_store.dart';
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
import 'budget_config/domain/usecases/get_budget_census_usecase.dart';
import 'budget_config/domain/usecases/get_budget_detail_usecase.dart';
import 'budget_config/domain/usecases/get_category_products_usecase.dart';
import 'budget_config/domain/usecases/get_census_data_usecase.dart';
import 'budget_config/domain/usecases/save_budget_usecase.dart';
import 'budget_config/domain/usecases/toggle_category_usecase.dart';
import 'budget_config/presentation/pages/config_new_budget_page.dart';
import 'budget_config/presentation/pages/school_census_page.dart';
import 'budget_config/presentation/stores/budget_config_store.dart';
import 'budget_config/presentation/stores/school_census_store.dart';
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
import 'budget_create/presentation/pages/new_budget_page.dart';
import 'budget_create/presentation/stores/budget_create_store.dart';
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
import 'budget_edit/domain/usecases/get_budget_for_edit_usecase.dart';
import 'budget_edit/domain/usecases/save_indicators_usecase.dart';
import 'budget_edit/domain/usecases/update_budget_usecase.dart';
import 'budget_edit/presentation/pages/edit_budget_page.dart';
import 'budget_edit/presentation/stores/budget_edit_store.dart';
import 'budget_list/data/datasources/budget_remote_datasource.dart';
import 'budget_list/data/datasources/budget_remote_datasource_impl.dart';
import 'budget_list/data/repositories/budget_list_repository_impl.dart';
import 'budget_list/domain/repositories/budget_list_repository.dart';
import 'budget_list/domain/usecases/rename_budget_usecase.dart';
import 'budget_list/presentation/pages/budget_list_page.dart';
import 'budget_list/presentation/stores/budget_list_store.dart';
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
    Bind.lazySingleton<AppHttpClient>(
      (i) => DioHttpClientImpl(
        DioConfigFactory.createDefault(
          baseUrl: ApiConfig.baseUrl,
          getToken: () => TokenCache.instance.getTokenOrEmpty(),
          enableLogger: true,
        ),
      ),
    ),

    Bind.lazySingleton<BudgetRemoteDataSource>(
      (i) => BudgetRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),

    Bind.lazySingleton<BudgetListRepository>(
      (i) => BudgetListRepositoryImpl(i.get<BudgetRemoteDataSource>()),
    ),

    Bind.lazySingleton(
      (i) => RenameBudgetUseCase(i.get<BudgetListRepository>()),
    ),

    Bind.lazySingleton(
      (i) => BudgetListStore(
        budgetListRepository: i.get<BudgetListRepository>(),
        renameBudgetUseCase: i.get<RenameBudgetUseCase>(),
      ),
    ),

    Bind.lazySingleton<PartnerRemoteDataSource>(
      (i) => PartnerRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),
    Bind.lazySingleton<BudgetDraftRemoteDataSource>(
      (i) => BudgetDraftRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),

    Bind.lazySingleton<PartnerRepository>(
      (i) => PartnerRepositoryImpl(i.get<PartnerRemoteDataSource>()),
    ),
    Bind.lazySingleton<BudgetDraftRepository>(
      (i) => BudgetDraftRepositoryImpl(i.get<BudgetDraftRemoteDataSource>()),
    ),

    Bind.lazySingleton<GetStandardPartnersUseCase>(
      (i) => GetStandardPartnersUseCase(i.get<PartnerRepository>()),
    ),
    Bind.lazySingleton<CreateDraftBudgetUseCase>(
      (i) => CreateDraftBudgetUseCase(i.get<BudgetDraftRepository>()),
    ),

    Bind.lazySingleton<BudgetCreateStore>(
      (i) => BudgetCreateStore(
        getStandardPartnersUseCase: i.get<GetStandardPartnersUseCase>(),
        createDraftBudgetUseCase: i.get<CreateDraftBudgetUseCase>(),
      ),
    ),

    Bind.lazySingleton<BudgetDetailRemoteDataSource>(
      (i) => BudgetDetailRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),
    Bind.lazySingleton<CensusRemoteDataSource>(
      (i) => CensusRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),

    Bind.lazySingleton<BudgetDetailRepository>(
      (i) => BudgetDetailRepositoryImpl(i.get<BudgetDetailRemoteDataSource>()),
    ),
    Bind.lazySingleton<CensusRepository>(
      (i) => CensusRepositoryImpl(i.get<CensusRemoteDataSource>()),
    ),

    Bind.lazySingleton<GetBudgetDetailUseCase>(
      (i) => GetBudgetDetailUseCase(i.get<BudgetDetailRepository>()),
    ),
    Bind.lazySingleton<GetCategoryProductsUseCase>(
      (i) => GetCategoryProductsUseCase(i.get<BudgetDetailRepository>()),
    ),
    Bind.lazySingleton<GetCensusDataUseCase>(
      (i) => GetCensusDataUseCase(i.get<CensusRepository>()),
    ),
    Bind.lazySingleton<ToggleCategoryUseCase>((i) => ToggleCategoryUseCase()),
    Bind.lazySingleton<CalculateTotalsUseCase>((i) => CalculateTotalsUseCase()),
    Bind.lazySingleton<FinalizeBudgetUseCase>(
      (i) => FinalizeBudgetUseCase(i.get<BudgetDetailRepository>()),
    ),
    Bind.lazySingleton<SaveBudgetUseCase>(
      (i) => SaveBudgetUseCase(i.get<BudgetDetailRepository>()),
    ),
    Bind.lazySingleton(
      (i) => GetBudgetCensusUseCase(i.get<CensusRemoteDataSource>()),
    ),

    Bind.lazySingleton<ProductCalculationService>(
      (i) => const ProductCalculationService(),
    ),

    Bind.lazySingleton<BudgetConfigStore>(
      (i) => BudgetConfigStore(
        getBudgetDetailUseCase: i.get<GetBudgetDetailUseCase>(),
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
        i.get<CensusRepository>(),
        i.get<GetBudgetCensusUseCase>(),
      ),
    ),

    Bind.lazySingleton<BudgetEditRemoteDataSource>(
      (i) => BudgetEditRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),
    Bind.lazySingleton<BudgetPdfRemoteDataSource>(
      (i) => BudgetPdfRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),
    Bind.lazySingleton<IndicatorsRemoteDataSource>(
      (i) => IndicatorsRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),

    Bind.lazySingleton<BudgetEditRepository>(
      (i) => BudgetEditRepositoryImpl(i.get<BudgetEditRemoteDataSource>()),
    ),
    Bind.lazySingleton<BudgetPdfRepository>(
      (i) => BudgetPdfRepositoryImpl(i.get<BudgetPdfRemoteDataSource>()),
    ),
    Bind.lazySingleton<IndicatorsRepository>(
      (i) => IndicatorsRepositoryImpl(i.get<IndicatorsRemoteDataSource>()),
    ),

    Bind.lazySingleton<GetBudgetForEditUseCase>(
      (i) => GetBudgetForEditUseCase(i.get<BudgetEditRepository>()),
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

    Bind.lazySingleton<BudgetEditStore>(
      (i) => BudgetEditStore(
        getBudgetForEditUseCase: i.get<GetBudgetForEditUseCase>(),
        updateBudgetUseCase: i.get<UpdateBudgetUseCase>(),
        getCensusDataUseCase: i.get<GetCensusDataUseCase>(),
        authStore: Modular.get<AuthStore>(),
        calculationService: i.get<ProductCalculationService>(),
      ),
    ),

    Bind.lazySingleton<MultiCityBudgetRemoteDataSource>(
      (i) => MultiCityBudgetRemoteDataSourceImpl(i.get<AppHttpClient>()),
    ),

    Bind.lazySingleton<MultiCityBudgetRepository>(
      (i) => MultiCityBudgetRepositoryImpl(
        i.get<MultiCityBudgetRemoteDataSource>(),
      ),
    ),

    Bind.lazySingleton<GetMultiCityCensusUseCase>(
      (i) => GetMultiCityCensusUseCase(i.get<MultiCityBudgetRepository>()),
    ),
    Bind.lazySingleton<CreateMultiCityBudgetUseCase>(
      (i) => CreateMultiCityBudgetUseCase(i.get<MultiCityBudgetRepository>()),
    ),

    Bind.lazySingleton<MultiCityCensusStore>(
      (i) => MultiCityCensusStore(
        i.get<GetMultiCityCensusUseCase>(),
        i.get<CreateMultiCityBudgetUseCase>(),
        Modular.get<
          AuthStore
        >(),
      ),
    ),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => const BudgetListPage()),

    ChildRoute('/new', child: (context, args) => const NewBudgetPage()),

    ChildRoute(
      '/config/:budgetId',
      child: (context, args) {
        final budgetId = int.parse(args.params['budgetId']);
        final arguments = args.data as Map<String, dynamic>?;
        final location = arguments?['location'] as Map<String, dynamic>?;

        return ConfigNewBudgetPage(
          budgetId: budgetId,
          cityName: location?['cityName'],
          stateName: location?['stateName'],
        );
      },
    ),

    ChildRoute(
      '/census/:cityId',
      child: (context, args) {
        final cityId = int.parse(args.params['cityId']);
        final argsData = args.data as Map<String, dynamic>?;
        final censoEscolar = argsData?['censoEscolar'] as CensoEscolarEntity?;
        final budgetId = argsData?['budgetId'] as int?;
        final isMultiCityMode = argsData?['isMultiCityMode'] as bool? ?? false;
        final onCensusUpdated =
            argsData?['onCensusUpdated'] as Function(CensoEscolarEntity)?;

        return SchoolCensusPage(
          cityId: cityId,
          budgetId: budgetId,
          censoInicial: censoEscolar,
          onCensusUpdated: onCensusUpdated,
          isMultiCityMode: isMultiCityMode,
        );
      },
    ),

    ChildRoute(
      '/edit/:budgetId',
      child: (context, args) {
        final budgetId = int.parse(args.params['budgetId']);
        return EditBudgetPage(budgetId: budgetId);
      },
    ),

    ChildRoute(
      '/multi-city/census',
      child: (context, args) {
        final argsData = args.data as Map<String, dynamic>?;
        final budgetName = argsData?['budgetName'] as String? ?? 'Orçamento';
        final budgetId = argsData?['budgetId'] as int?;
        final selectedCities =
            (argsData?['selectedCities'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        return MultiCityCensusPage(
          budgetName: budgetName,
          budgetId: budgetId,
          selectedCities: selectedCities,
        );
      },
    ),
  ];
}
