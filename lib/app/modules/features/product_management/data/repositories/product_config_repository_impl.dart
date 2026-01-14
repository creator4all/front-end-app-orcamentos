import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/indicator_group_entity.dart';
import '../../domain/entities/product_config_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/repositories/product_config_repository.dart';
import '../datasources/product_config_datasource.dart';
import '../models/product_config_dto.dart';

/// Implementação concreta do repositório de configuração de produtos
class ProductConfigRepositoryImpl implements ProductConfigRepository {
  final ProductConfigDatasource datasource;

  ProductConfigRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final dtos = await datasource.getCategories();
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar categorias: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      int categoryId) async {
    try {
      final dtos = await datasource.getSubcategories(categoryId);
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar subcategorias: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductConfigEntity>>> getProducts(
      int subcategoryId) async {
    try {
      final dtos = await datasource.getProducts(subcategoryId);
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar produtos: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductConfigEntity>> getProductDetails(
      int productId) async {
    try {
      final dto = await datasource.getProductDetails(productId);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar detalhes do produto: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductConfigEntity>> updateProduct(
      ProductConfigEntity product) async {
    try {
      final data = ProductConfigDto.toUpdateJson(product);
      final dto = await datasource.updateProduct(product.id, data);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar produto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IndicatorGroupEntity>>> getIndicators() async {
    try {
      final dtos = await datasource.getIndicators();
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar indicadores: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProductStatus(
      int productId, bool status) async {
    try {
      await datasource.updateProductStatus(productId, status);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar status do produto: $e'));
    }
  }
}
