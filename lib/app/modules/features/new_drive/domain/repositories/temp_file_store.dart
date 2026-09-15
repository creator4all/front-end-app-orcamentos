abstract class TempFileStore {
  Future<String> getTempFilePath(String fileName);

  Future<String> getCacheFilePath(String folderId, String fileName);

  Future<bool> exists(String path);

  Future<void> createDirectory(String path);

  Future<void> delete(String path);

  Future<void> rename(String from, String to);

  Future<void> writeBytes(String path, List<int> bytes);
}
