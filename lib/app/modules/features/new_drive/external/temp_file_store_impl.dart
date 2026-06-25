import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/repositories/temp_file_store.dart';

class TempFileStoreImpl implements TempFileStore {
  @override
  Future<String> getTempFilePath(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/$fileName';
  }

  @override
  Future<String> getCacheFilePath(String folderId, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/new_drive_share_cache/$folderId/$fileName';
  }

  @override
  Future<bool> exists(String path) async {
    final file = File(path);
    return file.exists();
  }

  @override
  Future<void> createDirectory(String path) async {
    final dir = Directory(path);
    await dir.create(recursive: true);
  }

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> rename(String from, String to) async {
    final file = File(from);
    await file.rename(to);
  }

  @override
  Future<void> writeBytes(String path, List<int> bytes) async {
    final file = File(path);
    await file.writeAsBytes(bytes);
  }
}
