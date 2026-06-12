import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../helpers/file_name_sanitizer.dart';
import '../repositories/drive_repository.dart';
import '../repositories/file_saver.dart';

class DownloadFileToCacheUsecase {
  final DriveRepository repository;
  final FileSaver fileSaver;

  DownloadFileToCacheUsecase(this.repository, this.fileSaver);

  Future<Either<NewDriveFailure, String>> call(
    DriveItem item, {
    Function(double)? onProgress,
  }) async {
    String? partialPath;

    try {
      final sanitizedName = FileNameSanitizer.sanitize(item.name);
      final directory = await getTemporaryDirectory();
      final cacheDirectory = Directory(
        '${directory.path}/new_drive_share_cache/${item.id}',
      );
      await cacheDirectory.create(recursive: true);

      final filePath = '${cacheDirectory.path}/$sanitizedName';
      partialPath = '$filePath.part';

      final cachedFile = File(filePath);
      if (await cachedFile.exists()) {
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
          final partialFile = File(savedPath);
          if (!await partialFile.exists()) {
            return left(
              const FileNotFoundFailure(
                'Arquivo temporario nao encontrado apos download',
              ),
            );
          }

          await _deleteIfExists(filePath);
          await partialFile.rename(filePath);
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
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
