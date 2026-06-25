import 'package:dartz/dartz.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../helpers/file_name_sanitizer.dart';
import '../repositories/drive_repository.dart';
import '../repositories/file_opener.dart';
import '../repositories/temp_file_store.dart';

class DownloadAndOpenFileUsecase {
  final DriveRepository repository;
  final TempFileStore tempFileStore;
  final FileOpener fileOpener;

  DownloadAndOpenFileUsecase(
      this.repository, this.tempFileStore, this.fileOpener);

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
            final filePath = await tempFileStore.getTempFilePath(
              FileNameSanitizer.sanitize(item.name),
            );

            await tempFileStore.writeBytes(filePath, bytes);

            final result = await fileOpener.open(filePath);

            if (result.type == FileOpenResultType.done) {
              return right(filePath);
            } else if (result.type == FileOpenResultType.noAppToOpen) {
              return left(
                const NoAppToOpenFailure(
                  'Nenhum aplicativo disponível para abrir este arquivo',
                ),
              );
            } else if (result.type == FileOpenResultType.permissionDenied) {
              return left(
                const PermissionDeniedFailure(
                    'Permissão negada para abrir o arquivo'),
              );
            } else if (result.type == FileOpenResultType.fileNotFound) {
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
