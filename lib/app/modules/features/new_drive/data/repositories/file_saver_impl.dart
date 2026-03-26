import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/repositories/file_saver.dart';

/// Concrete implementation of [FileSaver] that uses the MediaStore API
/// on Android 10+ and direct file I/O on older Android versions / other platforms.
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

  /// Android 10+ (API 29+): uses MediaStore.Downloads — no special permission.
  /// Android 9 and below: uses direct file I/O with WRITE_EXTERNAL_STORAGE.
  Future<String> _saveOnAndroid(List<int> bytes, String fileName) async {
    final sdkInt = await _getAndroidSdkVersion();

    if (sdkInt >= 29) {
      return _saveViaMediaStore(bytes, fileName);
    }

    return _saveViaDirectIo(bytes, fileName);
  }

  /// Saves using Android's MediaStore.Downloads content provider.
  /// Available on API 29+ and requires NO storage permissions.
  Future<String> _saveViaMediaStore(List<int> bytes, String fileName) async {
    // Ensure MediaStore is initialized and appFolder is set
    await MediaStore.ensureInitialized();
    if (MediaStore.appFolder.isEmpty) {
      MediaStore.appFolder = 'MultimidiaParceiro';
    }

    // Write bytes to a temp file first (media_store_plus works with file paths)
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

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (result != null) {
        // media_store_plus returns a SaveInfo with a non-nullable Uri
        return result.uri.toString();
      }

      throw const FileSystemException(
        'MediaStore retornou nulo ao salvar o arquivo',
      );
    } catch (e) {
      // Clean up temp file on error
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      if (e is FileSystemException) rethrow;
      throw FileSystemException(
        'Erro ao salvar via MediaStore: $e',
      );
    }
  }

  /// Saves directly to /storage/emulated/0/Download using file I/O.
  /// Used on Android 9 (API 28) and below, where WRITE_EXTERNAL_STORAGE suffices.
  Future<String> _saveViaDirectIo(List<int> bytes, String fileName) async {
    final hasPermission = await _requestLegacyStoragePermission();
    if (!hasPermission) {
      throw const FileSystemException(
        'Permissão de armazenamento negada',
      );
    }

    final directory = await _resolveLegacyDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final uniqueName = await _buildUniqueFilePath(directory.path, fileName);
    final file = File(uniqueName);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Fallback for iOS, macOS, Windows, Linux.
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

  Future<int> _getAndroidSdkVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// Requests WRITE_EXTERNAL_STORAGE for Android 9 and below only.
  Future<bool> _requestLegacyStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted || status.isLimited) return true;

    final requested = await Permission.storage.request();
    return requested.isGranted || requested.isLimited;
  }

  Future<Directory> _resolveLegacyDirectory() async {
    final candidates = <Directory>[
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Documents'),
    ];

    for (final candidate in candidates) {
      if (await _canUseDirectory(candidate)) return candidate;
    }

    // App-scoped fallback
    final externalDirs =
        await getExternalStorageDirectories(type: StorageDirectory.downloads);
    if (externalDirs != null && externalDirs.isNotEmpty) {
      return externalDirs.first;
    }

    return getApplicationDocumentsDirectory();
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

  /// Generates a unique file name for MediaStore to avoid collisions.
  Future<String> _buildUniqueDownloadName(String fileName) async {
    // MediaStore handles duplicates internally for most cases,
    // but we add a timestamp to be safe
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
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
      'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Ç': 'C', 'Ñ': 'N',
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
