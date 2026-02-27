import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

class DownloadFileUsecase {
  final DriveRepository repository;

  DownloadFileUsecase(this.repository);

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
            final directory = await _resolveTargetDirectory();
            if (directory == null) {
              return left(
                const DownloadFileFailure(
                  'Não foi possível localizar uma pasta para salvar o arquivo',
                ),
              );
            }

            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }

            final sanitizedName = _sanitizeFileName(item.name);
            final targetPath = await _buildUniqueFilePath(
              directory.path,
              sanitizedName,
            );

            onProgress?.call(0.7);
            await _writeFileWithAndroidRetry(targetPath, bytes);
            onProgress?.call(1.0);
            return right(targetPath);
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

  Future<Directory?> _resolveTargetDirectory() async {
    if (Platform.isAndroid) {
      final candidates = <Directory>[
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Documents'),
      ];

      for (final candidate in candidates) {
        if (await _canUseDirectory(candidate)) {
          return candidate;
        }
      }

      final granted = await _requestAndroidStoragePermission();
      if (granted) {
        for (final candidate in candidates) {
          if (await _canUseDirectory(candidate)) {
            return candidate;
          }
        }
      }

      final externalDownloadDirs =
          await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (externalDownloadDirs != null && externalDownloadDirs.isNotEmpty) {
        return externalDownloadDirs.first;
      }

      final externalDocumentDirs =
          await getExternalStorageDirectories(type: StorageDirectory.documents);
      if (externalDocumentDirs != null && externalDocumentDirs.isNotEmpty) {
        return externalDocumentDirs.first;
      }
    }

    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      return downloadsDirectory;
    }

    return getApplicationDocumentsDirectory();
  }

  Future<void> _writeFileWithAndroidRetry(String targetPath, List<int> bytes) async {
    try {
      final file = File(targetPath);
      await file.writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      if (!Platform.isAndroid) {
        rethrow;
      }

      final hasPermission = await _requestAndroidStoragePermission();
      if (!hasPermission) {
        rethrow;
      }

      final file = File(targetPath);
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      await file.writeAsBytes(bytes, flush: true);
    }
  }

  Future<bool> _requestAndroidStoragePermission() async {
    final manageStatus = await Permission.manageExternalStorage.status;
    if (manageStatus.isGranted) {
      return true;
    }

    final requestedManage = await Permission.manageExternalStorage.request();
    if (requestedManage.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted || storageStatus.isLimited) {
      return true;
    }

    final requestedStorage = await Permission.storage.request();
    return requestedStorage.isGranted || requestedStorage.isLimited;
  }

  Future<bool> _canUseDirectory(Directory directory) async {
    try {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> _buildUniqueFilePath(String directoryPath, String fileName) async {
    final extensionIndex = fileName.lastIndexOf('.');
    final hasExtension = extensionIndex > 0 && extensionIndex < fileName.length - 1;
    final baseName = hasExtension ? fileName.substring(0, extensionIndex) : fileName;
    final extension = hasExtension ? fileName.substring(extensionIndex) : '';

    var counter = 0;
    while (true) {
      final candidateName =
          counter == 0 ? fileName : '$baseName ($counter)$extension';
      final candidatePath = _joinPath(directoryPath, candidateName);
      final file = File(candidatePath);
      if (!await file.exists()) {
        return candidatePath;
      }
      counter++;
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

  String _sanitizeFileName(String fileName) {
    const accentMap = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
      'Á': 'A',
      'À': 'A',
      'Ã': 'A',
      'Â': 'A',
      'Ä': 'A',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Õ': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C',
      'Ñ': 'N',
    };

    var sanitized = fileName;

    accentMap.forEach((accent, replacement) {
      sanitized = sanitized.replaceAll(accent, replacement);
    });

    return sanitized.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  String _joinPath(String left, String right) {
    if (left.endsWith('/')) {
      return '$left$right';
    }
    return '$left/$right';
  }
}
