import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileOpenerHelper {
  /// Baixa e abre arquivo com app nativo do sistema
  static Future<void> openWithNativeApp({
    required String fileUrl,
    required String fileName,
    String? token,
    Function(double progress)? onProgress,
  }) async {
    try {
      // 1. Verificar/Solicitar permissões (Android 13+)
      await _checkPermissions();

      // 2. Obter diretório de downloads
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      // 3. Verificar se já existe
      final file = File(filePath);
      if (!await file.exists()) {
        // 4. Baixar arquivo
        await _downloadFile(fileUrl, filePath, token, onProgress);
      }

      // 5. Abrir com app nativo (DIALOG "Abrir com...")
      final result = await OpenFilex.open(filePath);

      // 6. Tratar resultado
      if (result.type != ResultType.done) {
        throw Exception('Não foi possível abrir o arquivo: ${result.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Baixa arquivo e retorna o caminho local
  static Future<String> downloadFile({
    required String fileUrl,
    required String fileName,
    String? token,
    Function(double progress)? onProgress,
  }) async {
    try {
      // 1. Verificar/Solicitar permissões
      await _checkPermissions();

      // 2. Obter diretório de downloads
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      // 3. Verificar se já existe
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      // 4. Baixar arquivo
      await _downloadFile(fileUrl, filePath, token, onProgress);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se arquivo existe em cache
  static Future<bool> isFileInCache(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obtém caminho do arquivo em cache (se existir)
  static Future<String?> getCachedFilePath(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Deleta arquivo do cache
  static Future<void> deleteFromCache(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignora erro se arquivo não existir
    }
  }

  /// Limpa todo o cache de arquivos
  static Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
    } catch (e) {
      // Ignora erros
    }
  }

  /// Verifica e solicita permissões necessárias
  static Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) não precisa de WRITE_EXTERNAL_STORAGE
      // Mas versões antigas ainda precisam
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          throw Exception('Permissão de armazenamento negada');
        }
      }
    }
    // iOS não precisa de permissões especiais para ApplicationDocumentsDirectory
  }

  /// Download do arquivo com progress
  static Future<void> _downloadFile(
    String url,
    String savePath,
    String? token,
    Function(double)? onProgress,
  ) async {
    final dio = Dio();

    print('🌐 Baixando arquivo de: $url');
    print(
        '🔑 Token presente: ${token != null ? "Sim (${token.substring(0, 20)}...)" : "NÃO"}');

    // Adicionar token se fornecido
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    try {
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
      print('✅ Download concluído: $savePath');
    } catch (e) {
      print('❌ Erro no download: $e');
      if (e is DioException) {
        print('❌ Status Code: ${e.response?.statusCode}');
        print('❌ Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Verifica se arquivo é um documento (precisa de app externo)
  static bool isDocument(String? mimeType) {
    if (mimeType == null) return false;
    return [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
    ].contains(mimeType);
  }

  /// Verifica se arquivo é mídia (pode ter preview)
  static bool isMedia(String? mimeType) {
    if (mimeType == null) return false;
    return mimeType.startsWith('image/') || mimeType.startsWith('video/');
  }

  /// Verifica se arquivo é imagem
  static bool isImage(String? mimeType) {
    if (mimeType == null) return false;
    return mimeType.startsWith('image/');
  }

  /// Verifica se arquivo é vídeo
  static bool isVideo(String? mimeType) {
    if (mimeType == null) return false;
    return mimeType.startsWith('video/');
  }

  /// Sanitiza nome do arquivo para evitar problemas no sistema de arquivos
  static String sanitizeFileName(String fileName) {
    // Remove caracteres inválidos
    String sanitized = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    // Limita tamanho do nome
    if (sanitized.length > 255) {
      final extension = sanitized.split('.').last;
      sanitized =
          '${sanitized.substring(0, 255 - extension.length - 1)}.$extension';
    }
    return sanitized;
  }

  /// Obtém o tamanho do cache em bytes
  static Future<int> getCacheSize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      int totalSize = 0;

      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Formata tamanho em bytes para string legível
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
