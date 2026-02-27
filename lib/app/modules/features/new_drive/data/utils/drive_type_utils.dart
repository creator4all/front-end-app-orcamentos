import '../../domain/entities/drive_item.dart';

class DriveTypeUtils {
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

  static String typeToFileString(DriveItemType type) {
    return type == DriveItemType.folder ? 'folder' : 'file';
  }
}
