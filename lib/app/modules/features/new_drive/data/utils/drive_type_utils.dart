import '../../domain/entities/drive_item.dart';

/// Utilitários para conversão de tipos do Drive
class DriveTypeUtils {
  /// Converte DriveItemType para string (formato específico: document, video, etc)
  static String typeToString(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return 'document';
      case DriveItemType.video:
        return 'video';
      case DriveItemType.image:
        return 'image';
      case DriveItemType.folder:
        return 'folder';
    }
  }

  /// Converte DriveItemType para string genérica (file/folder)
  static String typeToFileString(DriveItemType type) {
    return type == DriveItemType.folder ? 'folder' : 'file';
  }
}
