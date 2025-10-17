import 'package:dartz/dartz.dart';

import '../../domain/entities/drive_category.dart';
import '../../domain/entities/drive_item.dart';
import '../../domain/repositories/drive_repository.dart';
import '../../new_drive_failure.dart';
import '../datasources/drive_remote_datasource.dart';

/// Implementação concreta do repositório de Drive
///
/// Coordena as fontes de dados (remote e local) e converte
/// os models em entities de domínio
class DriveRepositoryImpl implements DriveRepository {
  final DriveRemoteDataSource remoteDataSource;

  DriveRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<NewDriveFailure, List<DriveItem>>> getRecentItems() async {
    try {
      final models = await remoteDataSource.getRecentItems();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }

  @override
  Future<Either<NewDriveFailure, List<DriveCategory>>> getCategories() async {
    try {
      final models = await remoteDataSource.getCategories();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LoadCategoriesFailure(e.toString()));
    }
  }

  @override
  Future<Either<NewDriveFailure, List<DriveItem>>> searchFiles(
    String query,
  ) async {
    try {
      final models = await remoteDataSource.searchFiles(query);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(SearchFilesFailure(e.toString()));
    }
  }

  @override
  Future<Either<NewDriveFailure, List<DriveItem>>> getFilesByCategory(
    DriveItemType type,
  ) async {
    try {
      final typeString = _typeToString(type);
      final models = await remoteDataSource.getFilesByCategory(typeString);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }

  @override
  Future<Either<NewDriveFailure, List<DriveItem>>> getOwnFiles() async {
    try {
      final models = await remoteDataSource.getOwnFiles();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }

  @override
  Future<Either<NewDriveFailure, DriveItem>> getFileDetails(
    String fileId,
  ) async {
    try {
      final model = await remoteDataSource.getFileDetails(fileId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(LoadRecentItemsFailure(e.toString()));
    }
  }

  @override
  Future<Either<NewDriveFailure, DriveItem>> getFolderContents(
    String folderId,
  ) async {
    try {
      final model = await remoteDataSource.getItemHierarchy(folderId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(
          LoadRecentItemsFailure('Erro ao carregar conteúdo da pasta: $e'));
    }
  }

  @override
  Future<Either<NewDriveFailure, List<int>>> downloadFileBytes(
    String fileId,
  ) async {
    try {
      final bytes = await remoteDataSource.downloadFileBytes(fileId);
      return Right(bytes);
    } catch (e) {
      return Left(DownloadFileFailure('Erro ao fazer download: $e'));
    }
  }

  /// Converte DriveItemType para string
  String _typeToString(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return 'document';
      case DriveItemType.video:
        return 'video';
      case DriveItemType.image:
        return 'image';
      case DriveItemType.folder:
        return 'folder';
    }
  }
}
