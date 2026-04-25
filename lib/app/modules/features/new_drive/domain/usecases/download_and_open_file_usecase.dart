import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

class DownloadAndOpenFileUsecase {
  final DriveRepository repository;

  DownloadAndOpenFileUsecase(this.repository);

  Future<Either<NewDriveFailure, String>> call(
    DriveItem item, {
    Function(double)? onProgress,
  }) async {
    try {
      final bytesResult = await repository.downloadFileBytes(item.id);

      return bytesResult.fold(
        (failure) => left(failure),
        (bytes) async {
          try {
            final directory = await getTemporaryDirectory();
            final filePath =
                '${directory.path}/${_sanitizeFileName(item.name)}';

            final file = File(filePath);
            await file.writeAsBytes(bytes);

            final result = await OpenFilex.open(filePath);

            if (result.type == ResultType.done) {
              return right(filePath);
            } else if (result.type == ResultType.noAppToOpen) {
              return left(
                const NoAppToOpenFailure(
                  'Nenhum aplicativo disponível para abrir este arquivo',
                ),
              );
            } else if (result.type == ResultType.permissionDenied) {
              return left(
                const PermissionDeniedFailure(
                    'Permissão negada para abrir o arquivo'),
              );
            } else if (result.type == ResultType.fileNotFound) {
              return left(
                const FileNotFoundFailure(
                    'Arquivo não encontrado após download'),
              );
            } else {
              return left(
                DownloadFileFailure('Erro ao abrir arquivo: ${result.message}'),
              );
            }
          } catch (e) {
            return left(
              DownloadFileFailure('Erro ao processar arquivo: $e'),
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
}
