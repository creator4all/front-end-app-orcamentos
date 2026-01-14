import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/product_config_api_datasource.dart';
import 'data/datasources/product_config_datasource.dart';
import 'data/repositories/product_config_repository_impl.dart';
import 'domain/repositories/product_config_repository.dart';
import 'domain/usecases/get_categories_usecase.dart';
import 'domain/usecases/get_indicators_usecase.dart';
import 'domain/usecases/get_product_details_usecase.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'domain/usecases/get_subcategories_usecase.dart';
import 'domain/usecases/update_product_status_usecase.dart';
import 'domain/usecases/update_product_usecase.dart';
import 'presentation/pages/product_management_page.dart';
import 'presentation/stores/product_management_store.dart';

/// Módulo de gerenciamento de produtos
/// Segue Clean Architecture com injeção de dependências
class ProductManagementModule extends Module {
  @override
  List<Bind> get binds => [
        // Datasource
        Bind.lazySingleton<ProductConfigDatasource>(
          (i) => ProductConfigApiDatasource(
            httpClient: i.get<AppHttpClient>(),
          ),
        ),

        // Repository
        Bind.lazySingleton<ProductConfigRepository>(
          (i) => ProductConfigRepositoryImpl(
            datasource: i.get<ProductConfigDatasource>(),
          ),
        ),

        // UseCases
        Bind.lazySingleton<GetCategoriesUsecase>(
          (i) => GetCategoriesUsecase(i.get<ProductConfigRepository>()),
        ),
        Bind.lazySingleton<GetSubcategoriesUsecase>(
          (i) => GetSubcategoriesUsecase(i.get<ProductConfigRepository>()),
        ),
        Bind.lazySingleton<GetProductsUsecase>(
          (i) => GetProductsUsecase(i.get<ProductConfigRepository>()),
        ),
        Bind.lazySingleton<GetProductDetailsUsecase>(
          (i) => GetProductDetailsUsecase(i.get<ProductConfigRepository>()),
        ),
        Bind.lazySingleton<UpdateProductUsecase>(
          (i) => UpdateProductUsecase(i.get<ProductConfigRepository>()),
        ),
        Bind.lazySingleton<UpdateProductStatusUsecase>(
          (i) => UpdateProductStatusUsecase(
            repository: i.get<ProductConfigRepository>(),
          ),
        ),
        Bind.lazySingleton<GetIndicatorsUsecase>(
          (i) => GetIndicatorsUsecase(i.get<ProductConfigRepository>()),
        ),

        // Store
        Bind.lazySingleton<ProductManagementStore>(
          (i) => ProductManagementStore(
            getCategoriesUsecase: i.get<GetCategoriesUsecase>(),
            getSubcategoriesUsecase: i.get<GetSubcategoriesUsecase>(),
            getProductsUsecase: i.get<GetProductsUsecase>(),
            getProductDetailsUsecase: i.get<GetProductDetailsUsecase>(),
            updateProductUsecase: i.get<UpdateProductUsecase>(),
            updateProductStatusUsecase: i.get<UpdateProductStatusUsecase>(),
            getIndicatorsUsecase: i.get<GetIndicatorsUsecase>(),
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
