enum FileOpenResultType {
  done,
  noAppToOpen,
  permissionDenied,
  fileNotFound,
  error
}

class FileOpenResult {
  final FileOpenResultType type;
  final String message;

  const FileOpenResult({
    required this.type,
    this.message = '',
  });
}

abstract class FileOpener {
  Future<FileOpenResult> open(
    String path, {
    String? mimeType,
    String? uti,
  });
}
