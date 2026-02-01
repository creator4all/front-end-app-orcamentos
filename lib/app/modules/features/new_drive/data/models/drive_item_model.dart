import '../../../../../../config/api_config.dart';
import '../../domain/entities/drive_item.dart';
import '../../domain/entities/shared_by_user.dart';
import '../utils/drive_type_utils.dart';

/// DTO (Data Transfer Object) para DriveItem
///
/// Responsável pela conversão entre JSON e entidade de domínio
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

  /// Converte JSON para Model
  factory DriveItemModel.fromJson(Map<String, dynamic> json) {
    try {
      final fileData = json['file_data'] as Map<String, dynamic>?;
      final parent = json['parent'] as Map<String, dynamic>?;
      final childrenJson = json['children'] as List<dynamic>?;

      // Suporta ambas as convenções de nomes: com prefixo (ite_) e sem (camelCase)
      final id = (json['ite_itemId'] ?? json['id']).toString();
      final name = (json['ite_name'] ?? json['name']) as String;
      final type = (json['ite_type'] ?? json['type']) as String;
      final mimeType = (json['ite_mimeType'] ?? json['mimeType']) as String?;
      final size = ((json['ite_size'] ?? json['size']) as int?) ?? 0;
      final createdAt = (json['created_at'] ?? json['createdAt']) as String;
      final updatedAt = (json['updated_at'] ?? json['updatedAt']) as String;
      final parentId = ((json['ite_parentId'] ?? json['parentId']) as int?);

      print(
          '[DriveItemModel] Parseando item: id=$id, name=$name, type=$type, childrenCount=${childrenJson?.length ?? 0}');

      return DriveItemModel(
        id: id,
        name: name,
        type: type,
        mimeType: mimeType,
        size: size, // ✅ Trata null como 0 (para pastas)
        thumbnailPath: fileData?['thumbnailPath'] as String?,
        createdAt: createdAt,
        updatedAt: updatedAt,
        hasChildren: childrenJson != null && childrenJson.isNotEmpty,
        parentId: parentId,
        parentName: parent?['ite_name'] ?? parent?['name'] as String?,
        children: childrenJson != null
            ? (childrenJson)
                .map((child) =>
                    DriveItemModel.fromJson(child as Map<String, dynamic>))
                .toList()
            : null,
        // Suporta tanto 'sharedBy' quanto 'user' (fallback para API atual)
        sharedBy: json['sharedBy'] as Map<String, dynamic>? ??
            json['user'] as Map<String, dynamic>?,
        downloadUrl: json['downloadUrl'] as String?,
      );
    } catch (e) {
      print('[DriveItemModel] ERRO ao parsear: $e');
      print('[DriveItemModel] JSON: $json');
      rethrow;
    }
  }

  /// Converte Model para JSON
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

  /// Converte Model para Entity
  DriveItem toEntity() {
    return DriveItem(
      id: id,
      name: name,
      type: _parseTypeFromMime(type, mimeType),
      size: _formatSize(size),
      lastViewed: DateTime.parse(updatedAt),
      thumbnailUrl: '${ApiConfig.baseUrl}/api/files/$id/thumbnail',
      itemCount:
          hasChildren ? 0 : null, // TODO: Implementar contagem real para pastas
      parentId: parentId,
      parentName: parentName,
      children: children?.map((child) => child.toEntity()).toList(),
      sharedBy: sharedBy != null
          ? SharedByUser(
              // Suporta campos com prefixo usr_ (API atual) e sem prefixo (formato sharedBy)
              id: (sharedBy!['usr_userId'] ?? sharedBy!['id']) as int,
              name: (sharedBy!['usr_name'] ?? sharedBy!['name']) as String,
              email: (sharedBy!['usr_email'] ?? sharedBy!['email']) as String,
              avatarUrl: (sharedBy!['usr_avatar'] ?? sharedBy!['avatarUrl'])
                  as String?,
            )
          : null,
      downloadUrl: downloadUrl,
    );
  }

  /// Converte Entity para Model
  factory DriveItemModel.fromEntity(DriveItem entity) {
    return DriveItemModel(
      id: entity.id,
      name: entity.name,
      type: DriveTypeUtils.typeToFileString(entity.type),
      mimeType: null,
      size: 0, // TODO: Parse do size string
      thumbnailPath: entity.thumbnailUrl,
      createdAt: entity.lastViewed.toIso8601String(),
      updatedAt: entity.lastViewed.toIso8601String(),
      hasChildren: entity.itemCount != null && entity.itemCount! > 0,
    );
  }

  /// Parse tipo baseado no mimeType e type
  static DriveItemType _parseTypeFromMime(String type, String? mimeType) {
    // Se for pasta
    if (type == 'folder' || type == 'directory') {
      return DriveItemType.folder;
    }

    // Se for arquivo, verifica o mimeType
    if (mimeType == null) return DriveItemType.document;

    if (mimeType.startsWith('video/')) {
      return DriveItemType.video;
    } else if (mimeType.startsWith('image/')) {
      return DriveItemType.image;
    } else {
      return DriveItemType.document;
    }
  }

  /// Formata tamanho de bytes para string legível
  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
