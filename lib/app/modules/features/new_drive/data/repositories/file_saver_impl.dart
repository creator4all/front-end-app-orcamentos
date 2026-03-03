import 'dart:io';

import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/file_saver.dart';

/// Implementação concreta de [FileSaver] que usa a API MediaStore
/// no Android e I/O direto de arquivo nas demais plataformas (iOS, desktop).
class FileSaverImpl implements FileSaver {
  final MediaStore _mediaStore = MediaStore();

  @override
  Future<String> saveToDownloads(List<int> bytes, String fileName) async {
    final sanitizedName = _sanitizeFileName(fileName);

    if (Platform.isAndroid) {
      return _saveOnAndroid(bytes, sanitizedName);
    }

    return _saveOnOtherPlatforms(bytes, sanitizedName);
  }

  /// Usa MediaStore.Downloads — nenhuma permissão especial necessária.
  Future<String> _saveOnAndroid(List<int> bytes, String fileName) async {
    return _saveViaMediaStore(bytes, fileName);
  }

  Future<String> _saveViaMediaStore(List<int> bytes, String fileName) async {
    await MediaStore.ensureInitialized();
    if (MediaStore.appFolder.isEmpty) {
      MediaStore.appFolder = 'MultimidiaParceiro';
    }

    // media_store_plus exige um caminho de arquivo, não aceita bytes diretamente
    final tempDir = await getTemporaryDirectory();
    final uniqueName = await _buildUniqueDownloadName(fileName);
    final tempFile = File(_joinPath(tempDir.path, uniqueName));
    await tempFile.writeAsBytes(bytes, flush: true);

    try {
      final result = await _mediaStore.saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (result != null) {
        // media_store_plus retorna um SaveInfo com Uri não-nulável
        return result.uri.toString();
      }

      throw const FileSystemException(
        'MediaStore retornou nulo ao salvar o arquivo',
      );
    } catch (e) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      if (e is FileSystemException) rethrow;
      throw FileSystemException(
        'Erro ao salvar via MediaStore: $e',
      );
    }
  }

  Future<String> _saveOnOtherPlatforms(List<int> bytes, String fileName) async {
    final downloadsDir = await getDownloadsDirectory();
    final directory = downloadsDir ?? await getApplicationDocumentsDirectory();

    final uniquePath = await _buildUniqueFilePath(directory.path, fileName);
    final file = File(uniquePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<String> _buildUniqueDownloadName(String fileName) async {
    // O MediaStore lida com duplicatas internamente na maioria dos casos,
    // mas adicionamos um timestamp por segurança
    final extensionIndex = fileName.lastIndexOf('.');
    final hasExtension =
        extensionIndex > 0 && extensionIndex < fileName.length - 1;
    final baseName =
        hasExtension ? fileName.substring(0, extensionIndex) : fileName;
    final extension = hasExtension ? fileName.substring(extensionIndex) : '';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${baseName}_$timestamp$extension';
  }

  Future<String> _buildUniqueFilePath(
      String directoryPath, String fileName) async {
    final extensionIndex = fileName.lastIndexOf('.');
    final hasExtension =
        extensionIndex > 0 && extensionIndex < fileName.length - 1;
    final baseName =
        hasExtension ? fileName.substring(0, extensionIndex) : fileName;
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
    if (left.endsWith('/')) return '$left$right';
    return '$left/$right';
  }
}
