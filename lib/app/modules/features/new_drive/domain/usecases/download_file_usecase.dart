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
      if (!_isFileTypeSupported(item.name)) {
        return left(
          const UnsupportedFileTypeFailure('Tipo de arquivo não suportado'),
        );
      }

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

  bool _isFileTypeSupported(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    const supportedExtensions = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'mp4',
      'avi',
      'mov',
      'mkv',
      'webm',
      '3gp',
      'mp3',
      'wav',
      'aac',
      'm4a',
    ];
    return supportedExtensions.contains(extension);
  }
}
