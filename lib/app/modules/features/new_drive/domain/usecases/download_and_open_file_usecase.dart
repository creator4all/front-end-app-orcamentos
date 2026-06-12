import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../helpers/file_name_sanitizer.dart';
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
                '${directory.path}/${FileNameSanitizer.sanitize(item.name)}';

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
}
