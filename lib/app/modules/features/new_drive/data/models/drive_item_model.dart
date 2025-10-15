import '../../domain/entities/drive_item.dart';

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
  });

  /// Converte JSON para Model
  factory DriveItemModel.fromJson(Map<String, dynamic> json) {
    final fileData = json['fileData'] as Map<String, dynamic>?;

    return DriveItemModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      type: json['type'] as String,
      mimeType: json['mimeType'] as String?,
      size: json['size'] as int,
      thumbnailPath: fileData?['thumbnailPath'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      hasChildren: json['hasChildren'] as bool? ?? false,
    );
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
      'fileData': {
        'thumbnailPath': thumbnailPath,
      },
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
      thumbnailUrl:
          'https://parceiro.multimidiaeducacional.com.br/api/files/$id/thumbnail',
      itemCount:
          hasChildren ? 0 : null, // TODO: Implementar contagem real para pastas
    );
  }

  /// Converte Entity para Model
  factory DriveItemModel.fromEntity(DriveItem entity) {
    return DriveItemModel(
      id: entity.id,
      name: entity.name,
      type: _typeToString(entity.type),
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

  /// Converte DriveItemType para string
  static String _typeToString(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return 'file';
      case DriveItemType.video:
        return 'file';
      case DriveItemType.image:
        return 'file';
      case DriveItemType.folder:
        return 'folder';
    }
  }
}
