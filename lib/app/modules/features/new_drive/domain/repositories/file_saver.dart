/// Abstraction for saving files to the device's public Downloads folder.
///
/// On Android 10+ (API 29+), implementations should use the MediaStore API
/// so that no special permissions (like MANAGE_EXTERNAL_STORAGE) are required.
abstract class FileSaver {
  /// Saves [bytes] as a file named [fileName] in the public Downloads folder.
  ///
  /// Returns the path or URI of the saved file.
  /// Throws [FileSystemException] if saving fails due to permission issues.
  Future<String> saveToDownloads(List<int> bytes, String fileName);
}
