import 'package:dartz/dartz.dart';
import 'package:multimidiaapp/app/shared/core/errors/http_exceptions.dart';
import 'package:multimidiaapp/app/shared/core/http/http_response.dart';

import '../../domain/entities/drive_item.dart';
import '../../domain/helpers/download_cancel_token.dart';
import '../../domain/repositories/drive_repository.dart';
import '../../new_drive_failure.dart';
import '../datasources/drive_remote_datasource.dart';

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

  @override
  Future<Either<NewDriveFailure, String>> downloadFileToPath(
    String fileId,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
    DownloadCancelToken? cancelToken,
  }) async {
    CancelDownload? httpCancelToken;
    if (cancelToken != null) {
      httpCancelToken = CancelDownload();
      cancelToken.onCancel(httpCancelToken.cancel);
    }

    try {
      await remoteDataSource.downloadFileToPath(
        fileId,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: httpCancelToken,
      );
      return Right(savePath);
    } on CancelledException {
      return const Left(DownloadCancelledFailure('Download cancelado'));
    } catch (e) {
      return Left(DownloadFileFailure('Erro ao fazer download: $e'));
    }
  }
}
