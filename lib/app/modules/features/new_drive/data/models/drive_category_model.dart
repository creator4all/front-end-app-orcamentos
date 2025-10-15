import '../../domain/entities/drive_category.dart';
import '../../domain/entities/drive_item.dart';

/// DTO (Data Transfer Object) para DriveCategory
///
/// Responsável pela conversão entre JSON e entidade de domínio
class DriveCategoryModel {
  final String id;
  final String name;
  final String type;
  final int itemCount;
  final String totalSize;

  DriveCategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.itemCount,
    required this.totalSize,
  });

  /// Converte JSON para Model
  factory DriveCategoryModel.fromJson(Map<String, dynamic> json) {
    return DriveCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      itemCount: json['item_count'] as int,
      totalSize: json['total_size'] as String,
    );
  }

  /// Converte Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'item_count': itemCount,
      'total_size': totalSize,
    };
  }

  /// Converte Model para Entity
  DriveCategory toEntity() {
    return DriveCategory(
      id: id,
      name: name,
      type: _parseType(type),
      itemCount: itemCount,
      totalSize: totalSize,
    );
  }

  /// Converte Entity para Model
  factory DriveCategoryModel.fromEntity(DriveCategory entity) {
    return DriveCategoryModel(
      id: entity.id,
      name: entity.name,
      type: _typeToString(entity.type),
      itemCount: entity.itemCount,
      totalSize: entity.totalSize,
    );
  }

  /// Parse string para DriveItemType
  static DriveItemType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'document':
        return DriveItemType.document;
      case 'video':
        return DriveItemType.video;
      case 'image':
        return DriveItemType.image;
      case 'folder':
        return DriveItemType.folder;
      default:
        return DriveItemType.document;
    }
  }

  /// Converte DriveItemType para string
  static String _typeToString(DriveItemType type) {
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
}
