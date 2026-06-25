import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../helpers/file_name_sanitizer.dart';
import '../repositories/drive_repository.dart';
import '../repositories/file_saver.dart';
import '../repositories/temp_file_store.dart';

class DownloadFileToCacheUsecase {
  final DriveRepository repository;
  final FileSaver fileSaver;
  final TempFileStore tempFileStore;

  DownloadFileToCacheUsecase(
      this.repository, this.fileSaver, this.tempFileStore);

  Future<Either<NewDriveFailure, String>> call(
    DriveItem item, {
    Function(double)? onProgress,
  }) async {
    String? partialPath;

    try {
      final sanitizedName = FileNameSanitizer.sanitize(item.name);
      final cacheDirPath =
          await tempFileStore.getCacheFilePath(item.id, sanitizedName);
      final cacheDir = cacheDirPath.substring(0, cacheDirPath.lastIndexOf('/'));
      await tempFileStore.createDirectory(cacheDir);

      final filePath = cacheDirPath;
      partialPath = '$filePath.part';

      if (await tempFileStore.exists(filePath)) {
        onProgress?.call(1.0);
        return right(filePath);
      }

      await _deleteIfExists(partialPath);

      onProgress?.call(0.1);
      final downloadResult = await repository.downloadFileToPath(
        item.id,
        partialPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress?.call(0.1 + (received / total) * 0.9);
          }
        },
      );

      return await downloadResult.fold(
        (failure) async {
          if (partialPath != null) {
            await _deleteIfExists(partialPath);
          }
          return left(failure);
        },
        (savedPath) async {
          if (!await tempFileStore.exists(savedPath)) {
            return left(
              const FileNotFoundFailure(
                'Arquivo temporario nao encontrado apos download',
              ),
            );
          }

          await _deleteIfExists(filePath);
          await tempFileStore.rename(savedPath, filePath);
          onProgress?.call(1.0);
          return right(filePath);
        },
      );
    } catch (e) {
      if (partialPath != null) {
        await _deleteIfExists(partialPath);
      }

      return left(
        DownloadFileFailure('Erro ao processar solicitacao: $e'),
      );
    }
  }

  Future<void> _deleteIfExists(String path) async {
    if (await tempFileStore.exists(path)) {
      await tempFileStore.delete(path);
    }
  }
}
