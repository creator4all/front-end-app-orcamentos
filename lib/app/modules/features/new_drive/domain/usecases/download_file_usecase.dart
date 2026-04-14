import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';
import '../repositories/file_saver.dart';

class DownloadFileUsecase {
  final DriveRepository repository;
  final FileSaver fileSaver;

  DownloadFileUsecase(this.repository, this.fileSaver);

  Future<Either<NewDriveFailure, String>> call(
    DriveItem item, {
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);
      final bytesResult = await repository.downloadFileBytes(item.id);

      return bytesResult.fold(
        (failure) => left(failure),
        (bytes) async {
          try {
            onProgress?.call(0.5);
            final savedPath = await fileSaver.saveToDownloads(
              bytes,
              item.name,
            );
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
      return left(
        DownloadFileFailure('Erro ao processar solicitação: $e'),
      );
    }
  }
}
