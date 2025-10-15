import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../new_drive_failure.dart';
import '../entities/drive_item.dart';
import '../repositories/drive_repository.dart';

/// Caso de uso para download e abertura de arquivos
///
/// Orquestra o processo completo:
/// 1. Faz o download dos bytes do arquivo
/// 2. Salva temporariamente no dispositivo
/// 3. Abre o arquivo com o app nativo apropriado
class DownloadAndOpenFileUsecase {
  final DriveRepository repository;

  DownloadAndOpenFileUsecase(this.repository);

  /// Executa o caso de uso de download e abertura
  ///
  /// [item] - Item do drive a ser aberto
  /// [onProgress] - Callback opcional para progresso do download (0.0 a 1.0)
  ///
  /// Retorna Either com:
  /// - Left(NewDriveFailure): Em caso de erro
  /// - Right(String): Caminho do arquivo salvo em caso de sucesso
  Future<Either<NewDriveFailure, String>> call(
    DriveItem item, {
    Function(double)? onProgress,
  }) async {
    try {
      // 1. Validar tipo de arquivo
      if (!_isFileTypeSupported(item.name)) {
        return left(
          const UnsupportedFileTypeFailure('Tipo de arquivo não suportado'),
        );
      }

      // 2. Baixar bytes do arquivo
      debugPrint('📥 Iniciando download do arquivo: ${item.name}');
      final bytesResult = await repository.downloadFileBytes(item.id);

      return bytesResult.fold(
        (failure) => left(failure),
        (bytes) async {
          try {
            // 3. Obter diretório temporário
            final directory = await getTemporaryDirectory();
            final filePath =
                '${directory.path}/${_sanitizeFileName(item.name)}';

            // 4. Salvar arquivo
            debugPrint('💾 Salvando arquivo em: $filePath');
            final file = File(filePath);
            await file.writeAsBytes(bytes);

            debugPrint('✅ Arquivo salvo com sucesso: ${bytes.length} bytes');

            // 5. Abrir arquivo com app nativo
            debugPrint('📱 Abrindo arquivo...');
            final result = await OpenFilex.open(filePath);

            // 6. Verificar resultado da abertura
            if (result.type == ResultType.done) {
              debugPrint('✅ Arquivo aberto com sucesso');
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
            debugPrint('❌ Erro ao salvar/abrir arquivo: $e');
            return left(
              DownloadFileFailure('Erro ao processar arquivo: $e'),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Erro no usecase: $e');
      return left(
        DownloadFileFailure('Erro ao processar solicitação: $e'),
      );
    }
  }

  /// Verifica se o tipo de arquivo é suportado
  bool _isFileTypeSupported(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    const supportedExtensions = [
      // Documentos
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      // Imagens
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      // Vídeos
      'mp4',
      'avi',
      'mov',
      'mkv',
      'webm',
      '3gp',
      // Áudio
      'mp3',
      'wav',
      'aac',
      'm4a',
    ];
    return supportedExtensions.contains(extension);
  }

  /// Remove caracteres especiais do nome do arquivo
  String _sanitizeFileName(String fileName) {
    // Remove caracteres que podem causar problemas no sistema de arquivos
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
