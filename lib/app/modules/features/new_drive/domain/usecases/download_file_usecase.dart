import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../helpers/download_cancel_token.dart';
import '../helpers/file_name_sanitizer.dart';
import '../repositories/drive_repository.dart';
import '../repositories/file_saver.dart';
import '../repositories/temp_file_store.dart';

class DownloadFileUsecase {
  final DriveRepository repository;
  final FileSaver fileSaver;
  final TempFileStore tempFileStore;

  DownloadCancelToken? _currentCancelDownload;

  DownloadFileUsecase(this.repository, this.fileSaver, this.tempFileStore);

  void cancelCurrentDownload() {
    final cancelDownload = _currentCancelDownload;
    if (cancelDownload == null || cancelDownload.isCanceled) {
      return;
    }
    cancelDownload.cancel();
  }

  Future<Either<NewDriveFailure, String>> call(
    DriveItem item, {
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.05);
      final sanitizedName = FileNameSanitizer.sanitize(item.name);
      final tempPath = await tempFileStore.getTempFilePath(sanitizedName);
      final cancelDownload = DownloadCancelToken();
      _currentCancelDownload = cancelDownload;

      final downloadResult = await repository.downloadFileToPath(
        item.id,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress?.call(0.05 + (received / total) * 0.8);
          }
        },
        cancelToken: cancelDownload,
      );

      final outcome = downloadResult;

      return await outcome.fold(
        (failure) async {
          await _cleanupTempFile(tempPath);
          return left(failure);
        },
        (downloadedPath) async {
          try {
            onProgress?.call(0.9);
            final savedPath = await fileSaver.saveDownloadedFile(
              downloadedPath,
              item.name,
            );

            await tempFileStore.delete(downloadedPath);

            onProgress?.call(1.0);
            return right(savedPath);
          } on FileSystemException {
            return left(
              const PermissionDeniedFailure(
                'Permissão negada para salvar o arquivo. '
                'Verifique as permissões de armazenamento.',
              ),
            );
          } catch (e) {
            return left(
              DownloadFileFailure('Erro ao salvar arquivo: $e'),
            );
          }
        },
      );
    } catch (e) {
      if (e is DownloadCancelledFailure) {
        return left(e);
      }

      return left(
        DownloadFileFailure('Erro ao processar solicitação: $e'),
      );
    } finally {
      _currentCancelDownload = null;
    }
  }

  Future<void> _cleanupTempFile(String tempPath) async {
    try {
      await tempFileStore.delete(tempPath);
    } catch (_) {}
  }
}
