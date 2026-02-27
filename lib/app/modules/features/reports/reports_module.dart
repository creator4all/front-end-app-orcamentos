import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import '../budget/budget_config/domain/repositories/census_repository.dart';
import '../budget/budget_config/domain/usecases/get_budget_census_usecase.dart';
import '../budget/budget_config/domain/usecases/get_budget_detail_usecase.dart';
import '../budget/budget_config/presentation/stores/school_census_store.dart';
import 'data/datasources/reports_api_datasource.dart';
import 'data/datasources/reports_datasource.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'domain/repositories/reports_repository.dart';
import 'presentation/pages/report_budget_detail_page.dart';
import 'presentation/pages/report_budget_list_page.dart';
import 'presentation/pages/report_census_page.dart';
import 'presentation/pages/report_user_list_page.dart';
import 'presentation/stores/report_budget_detail_store.dart';
import 'presentation/stores/report_budget_list_store.dart';
import 'presentation/stores/report_filter_store.dart';
import 'presentation/stores/report_user_list_store.dart';

class ReportsModule extends Module {
  @override
  List<Module> get imports => [];

  @override
  List<Bind> get binds => [
    Bind.lazySingleton<ReportsDatasource>(
      (i) => ReportsApiDatasource(httpClient: i.get<AppHttpClient>()),
    ),

    Bind.lazySingleton<ReportsRepository>(
      (i) => ReportsRepositoryImpl(datasource: i.get<ReportsDatasource>()),
    ),

    Bind.lazySingleton<ReportFilterStore>((i) => ReportFilterStore()),
    Bind.lazySingleton<ReportUserListStore>(
      (i) => ReportUserListStore(
        reportsRepository: i.get<ReportsRepository>(),
        filterStore: i.get<ReportFilterStore>(),
      ),
    ),
    Bind.lazySingleton<ReportBudgetListStore>(
      (i) => ReportBudgetListStore(
        reportsRepository: i.get<ReportsRepository>(),
        filterStore: i.get<ReportFilterStore>(),
      ),
    ),

    Bind.factory<ReportBudgetDetailStore>(
      (i) => ReportBudgetDetailStore(
        getBudgetDetailUseCase: i.get<GetBudgetDetailUseCase>(),
        getBudgetCensusUseCase: i.get<GetBudgetCensusUseCase>(),
      ),
    ),

    Bind.factory<SchoolCensusStore>(
      (i) => SchoolCensusStore(
        i.get<CensusRepository>(),
        i.get<GetBudgetCensusUseCase>(),
      ),
    ),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute(
      '/partner/:partnerId',
      child:
          (context, args) => ReportUserListPage(
            partnerId: int.parse(args.params['partnerId'] ?? '0'),
            partnerName: args.data?['partnerName'] as String?,
          ),
    ),

    ChildRoute(
      '/user/:userId/budgets',
      child:
          (context, args) => ReportBudgetListPage(
            userId: int.parse(args.params['userId'] ?? '0'),
            userName: args.data?['userName'] as String?,
            userCargo: args.data?['userCargo'] as String?,
            partnerName: args.data?['partnerName'] as String?,
          ),
    ),

    ChildRoute(
      '/budget/:budgetId',
      child:
          (context, args) => ReportBudgetDetailPage(
            budgetId: int.parse(args.params['budgetId'] ?? '0'),
            partnerName: args.data?['partnerName'] as String?,
            userName: args.data?['userName'] as String?,
          ),
    ),

    ChildRoute(
      '/budget/:budgetId/census',
      child:
          (context, args) => ReportCensusPage(
            budgetId: int.parse(args.params['budgetId'] ?? '0'),
            censoData: args.data?['censoData'],
          ),
    ),
  ];
}
