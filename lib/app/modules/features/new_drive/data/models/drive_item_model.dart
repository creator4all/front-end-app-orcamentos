import '../../../../../../config/api_config.dart';
import '../../domain/entities/drive_item.dart';
import '../../domain/entities/shared_by_user.dart';
import '../utils/drive_type_utils.dart';

class DriveItemModel {
  final String id;
  final String name;
  final String type;
  final String? mimeType;
  final int size;
  final String? thumbnailPath;
  final String createdAt;
  final String updatedAt;
  final bool hasChildren;
  final int? parentId;
  final String? parentName;
  final List<DriveItemModel>? children;
  final Map<String, dynamic>? sharedBy;
  final String? downloadUrl;

  DriveItemModel({
    required this.id,
    required this.name,
    required this.type,
    this.mimeType,
    required this.size,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
    required this.hasChildren,
    this.parentId,
    this.parentName,
    this.children,
    this.sharedBy,
    this.downloadUrl,
  });

  factory DriveItemModel.fromJson(Map<String, dynamic> json) {
    final isHierarchyFormat = json.containsKey('ite_itemId');

    if (isHierarchyFormat) {
      return DriveItemModel._fromHierarchyJson(json);
    }
    return DriveItemModel._fromListJson(json);
  }

  factory DriveItemModel._fromListJson(Map<String, dynamic> json) {
    final fileData = json['fileData'] as Map<String, dynamic>?;
    final parent = json['parent'] as Map<String, dynamic>?;
    final sharedBy = json['sharedBy'] as Map<String, dynamic>?;

    return DriveItemModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      type: json['type'] as String,
      mimeType: json['mimeType'] as String?,
      size: (json['size'] as int?) ?? 0,
      thumbnailPath: fileData?['thumbnailPath'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      hasChildren: json['hasChildren'] as bool? ?? false,
      parentId: json['parentId'] as int?,
      parentName: parent?['name'] as String?,
      children: null,
      sharedBy: sharedBy,
      downloadUrl: json['downloadUrl'] as String?,
    );
  }

  factory DriveItemModel._fromHierarchyJson(Map<String, dynamic> json) {
    final fileData = json['file_data'] as Map<String, dynamic>?;
    final childrenJson = json['children'] as List<dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;

    return DriveItemModel(
      id: json['ite_itemId'].toString(),
      name: json['ite_name'] as String,
      type: json['ite_type'] as String,
      mimeType: json['ite_mimeType'] as String?,
      size: (json['ite_size'] as int?) ?? 0,
      thumbnailPath: fileData?['fi_thumbnailPath'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      hasChildren: childrenJson != null && childrenJson.isNotEmpty,
      parentId: json['ite_parentId'] as int?,
      parentName: null,
      children: childrenJson
          ?.map(
              (child) => DriveItemModel.fromJson(child as Map<String, dynamic>))
          .toList(),
      sharedBy: user,
      downloadUrl: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'mimeType': mimeType,
      'size': size,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'hasChildren': hasChildren,
      'parentId': parentId,
      'parentName': parentName,
      'fileData': {
        'thumbnailPath': thumbnailPath,
      },
      if (children != null)
        'children': children!.map((c) => c.toJson()).toList(),
    };
  }

  DriveItem toEntity() {
    return DriveItem(
      id: id,
      name: name,
      type: _parseTypeFromMime(type, mimeType),
      size: _formatSize(size),
      lastViewed: DateTime.parse(updatedAt),
      thumbnailUrl: '${ApiConfig.baseUrl}/api/files/$id/thumbnail',
      parentId: parentId,
      parentName: parentName,
      children: children?.map((child) => child.toEntity()).toList(),
      sharedBy: _parseSharedByUser(),
      downloadUrl: downloadUrl,
    );
  }

  SharedByUser? _parseSharedByUser() {
    if (sharedBy == null) return null;

    final isUserFormat = sharedBy!.containsKey('usr_userId');

    if (isUserFormat) {
      return SharedByUser(
        id: sharedBy!['usr_userId'] as int,
        name: sharedBy!['usr_name'] as String,
        email: sharedBy!['usr_email'] as String,
        avatarUrl: sharedBy!['usr_avatar'] as String?,
      );
    }

    return SharedByUser(
      id: sharedBy!['id'] as int,
      name: sharedBy!['name'] as String,
      email: sharedBy!['email'] as String,
      avatarUrl: sharedBy!['avatarUrl'] as String?,
    );
  }

  factory DriveItemModel.fromEntity(DriveItem entity) {
    return DriveItemModel(
      id: entity.id,
      name: entity.name,
      type: DriveTypeUtils.typeToFileString(entity.type),
      mimeType: null,
      size: 0,
      thumbnailPath: entity.thumbnailUrl,
      createdAt: entity.lastViewed.toIso8601String(),
      updatedAt: entity.lastViewed.toIso8601String(),
      hasChildren: entity.children != null && entity.children!.isNotEmpty,
    );
  }

  static DriveItemType _parseTypeFromMime(String type, String? mimeType) {
    if (type == 'folder' || type == 'directory') {
      return DriveItemType.folder;
    }

    if (mimeType == null) return DriveItemType.document;

    if (mimeType.startsWith('video/')) {
      return DriveItemType.video;
    } else if (mimeType.startsWith('image/')) {
      return DriveItemType.image;
    } else {
      return DriveItemType.document;
    }
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
