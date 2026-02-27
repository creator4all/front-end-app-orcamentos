import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/product_config_api_datasource.dart';
import 'data/datasources/product_config_datasource.dart';
import 'data/repositories/product_config_repository_impl.dart';
import 'domain/repositories/product_config_repository.dart';
import 'presentation/pages/product_management_page.dart';
import 'presentation/stores/product_management_store.dart';

class ProductManagementModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<ProductConfigDatasource>(
          (i) => ProductConfigApiDatasource(
            httpClient: i.get<AppHttpClient>(),
          ),
        ),
        Bind.lazySingleton<ProductConfigRepository>(
          (i) => ProductConfigRepositoryImpl(
            datasource: i.get<ProductConfigDatasource>(),
          ),
        ),
        Bind.lazySingleton<ProductManagementStore>(
          (i) => ProductManagementStore(
            repository: i.get<ProductConfigRepository>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => const ProductManagementPage(),
        ),
      ];
}
