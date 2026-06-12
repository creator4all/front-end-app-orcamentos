import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/helpers/file_name_sanitizer.dart';
import '../../domain/repositories/file_saver.dart';

/// Concrete implementation of [FileSaver] that uses the MediaStore API
/// on Android 10+ and direct file I/O on older Android versions.
/// No iOS, salva em Documents/Downloads/ para visibilidade no app Arquivos.
class FileSaverImpl implements FileSaver {
  @override
  Future<String> saveToDownloads(List<int> bytes, String fileName) async {
    final sanitizedName = FileNameSanitizer.sanitize(fileName);

    if (Platform.isAndroid) {
      return _saveOnAndroid(bytes, sanitizedName);
    }

    if (Platform.isIOS) {
      return _saveOnIOS(bytes, sanitizedName);
    }

    return _saveOnDesktop(bytes, sanitizedName);
  }

  @override
  Future<String> saveDownloadedFile(String sourcePath, String fileName) async {
    final sanitizedName = FileNameSanitizer.sanitize(fileName);

    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      if (sdkInt >= 29) {
        return _savePathViaMediaStore(sourcePath, sanitizedName);
      }
      return _copyToDirectory(
        sourcePath,
        await _resolveLegacyDirectory(),
        sanitizedName,
        requestPermission: true,
      );
    }

    if (Platform.isIOS) {
      final documentsDir = await getApplicationDocumentsDirectory();
      final downloadsSubDir = Directory('${documentsDir.path}/Downloads');
      return _copyToDirectory(sourcePath, downloadsSubDir, sanitizedName);
    }

    final downloadsDir = await getDownloadsDirectory();
    final directory = downloadsDir ?? await getApplicationDocumentsDirectory();
    return _copyToDirectory(sourcePath, directory, sanitizedName);
  }

  /// Copia [sourcePath] para [directory] com nome único, retornando o path.
  Future<String> _copyToDirectory(
    String sourcePath,
    Directory directory,
    String fileName, {
    bool requestPermission = false,
  }) async {
    if (requestPermission) {
      final hasPermission = await _requestLegacyStoragePermission();
      if (!hasPermission) {
        throw const FileSystemException('Permissão de armazenamento negada');
      }
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final uniquePath = await _buildUniqueFilePath(directory.path, fileName);
    await File(sourcePath).copy(uniquePath);
    return uniquePath;
  }

  /// Salva um arquivo já em disco via MediaStore (Android 10+), sem reescrever
  /// os bytes. O MediaStore deriva o nome do arquivo a partir do tempFilePath.
  Future<String> _savePathViaMediaStore(
    String sourcePath,
    String fileName,
  ) async {
    final mediaStore = MediaStore();
    await MediaStore.ensureInitialized();
    if (MediaStore.appFolder.isEmpty) {
      MediaStore.appFolder = 'Multimidia B2B';
    }

    final tempDir = await getTemporaryDirectory();
    final tempPath = _joinPath(tempDir.path, fileName);
    final tempFile = File(tempPath);
    final isDistinctTemp = sourcePath != tempPath;
    if (isDistinctTemp) {
      await File(sourcePath).copy(tempPath);
    }

    try {
      final result = await mediaStore.saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      if (isDistinctTemp && await tempFile.exists()) {
        await tempFile.delete();
      }

      if (result != null) {
        return result.uri.toString();
      }

      throw const FileSystemException(
        'MediaStore retornou nulo ao salvar o arquivo',
      );
    } catch (e) {
      if (isDistinctTemp && await tempFile.exists()) {
        await tempFile.delete();
      }
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Erro ao salvar via MediaStore: $e');
    }
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
    final mediaStore = MediaStore();
    await MediaStore.ensureInitialized();
    if (MediaStore.appFolder.isEmpty) {
      MediaStore.appFolder = 'Multimidia B2B';
    }

    // Write bytes to a temp file first (media_store_plus works with file paths)
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(_joinPath(tempDir.path, fileName));
    await tempFile.writeAsBytes(bytes, flush: true);

    try {
      final result = await mediaStore.saveFile(
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

  /// iOS: salva em Documents/Downloads/ para visibilidade no app Arquivos.
  /// Requer UIFileSharingEnabled e LSSupportsOpeningDocumentsInPlace no Info.plist.
  Future<String> _saveOnIOS(List<int> bytes, String fileName) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final downloadsSubDir = Directory('${documentsDir.path}/Downloads');

    if (!await downloadsSubDir.exists()) {
      await downloadsSubDir.create(recursive: true);
    }

    final uniquePath =
        await _buildUniqueFilePath(downloadsSubDir.path, fileName);
    final file = File(uniquePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Fallback para desktop (macOS, Windows, Linux).
  Future<String> _saveOnDesktop(List<int> bytes, String fileName) async {
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

  @override
  Future<String?> findInDownloads(String fileName) async {
    final sanitizedName = FileNameSanitizer.sanitize(fileName);

    if (Platform.isAndroid) {
      return _findOnAndroid(sanitizedName);
    }

    if (Platform.isIOS) {
      return _findOnIOS(sanitizedName);
    }

    return _findOnDesktop(sanitizedName);
  }

  Future<String?> _findOnAndroid(String fileName) async {
    final sdkInt = await _getAndroidSdkVersion();

    if (sdkInt >= 29) {
      return _findViaMediaStore(fileName);
    }

    return _findViaDirectIo(fileName);
  }

  Future<String?> _findViaMediaStore(String fileName) async {
    File? tempFile;
    try {
      final mediaStore = MediaStore();
      await MediaStore.ensureInitialized();
      if (MediaStore.appFolder.isEmpty) {
        MediaStore.appFolder = 'Multimidia B2B';
      }

      // Timeout defensivo: a chamada nativa do MediaStore pode não retornar
      // (ex.: fluxo de permissão), o que travaria o compartilhamento.
      final exists = await mediaStore
          .isFileExist(
            fileName: fileName,
            dirType: DirType.download,
            dirName: DirName.download,
          )
          .timeout(const Duration(seconds: 8), onTimeout: () => false);

      if (exists != true) return null;

      // Cria arquivo temp vazio para o MediaStore copiar o conteúdo
      final tempDir = await getTemporaryDirectory();
      final tempPath = _joinPath(tempDir.path, fileName);
      tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        await tempFile.create(recursive: true);
      }

      final readOk = await mediaStore
          .readFile(
            fileName: fileName,
            tempFilePath: tempPath,
            dirType: DirType.download,
            dirName: DirName.download,
          )
          .timeout(const Duration(seconds: 30), onTimeout: () => false);

      // Só reaproveita se realmente copiou conteúdo (evita temp vazio).
      if (readOk == true &&
          await tempFile.exists() &&
          await tempFile.length() > 0) {
        return tempPath;
      }

      await _deleteIfExists(tempFile);
      return null;
    } catch (_) {
      await _deleteIfExists(tempFile);
      return null;
    }
  }

  Future<void> _deleteIfExists(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<String?> _findViaDirectIo(String fileName) async {
    try {
      final candidates = <String>[
        _joinPath('/storage/emulated/0/Download', fileName),
        _joinPath('/storage/emulated/0/Documents', fileName),
      ];

      for (final candidatePath in candidates) {
        final file = File(candidatePath);
        if (await file.exists()) {
          final tempDir = await getTemporaryDirectory();
          final tempPath = _joinPath(tempDir.path, fileName);
          await file.copy(tempPath);
          return tempPath;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _findOnIOS(String fileName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final filePath = _joinPath(
        _joinPath(documentsDir.path, 'Downloads'),
        fileName,
      );

      final file = File(filePath);
      if (await file.exists()) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = _joinPath(tempDir.path, fileName);
        await file.copy(tempPath);
        return tempPath;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _findOnDesktop(String fileName) async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      final directory =
          downloadsDir ?? await getApplicationDocumentsDirectory();
      final filePath = _joinPath(directory.path, fileName);

      final file = File(filePath);
      if (await file.exists()) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = _joinPath(tempDir.path, fileName);
        await file.copy(tempPath);
        return tempPath;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  String _joinPath(String left, String right) {
    if (left.endsWith('/')) return '$left$right';
    return '$left/$right';
  }
}
