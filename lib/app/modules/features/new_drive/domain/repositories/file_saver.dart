abstract class FileSaver {
  Future<String> saveToDownloads(List<int> bytes, String fileName);

  Future<String> saveDownloadedFile(String sourcePath, String fileName);

  Future<String?> findInDownloads(String fileName);
}
