class ThumbnailModel {
  final int id;
  final int itemId;
  final String path;
  final bool isDefault;
  final DateTime createdAt;

  const ThumbnailModel({
    required this.id,
    required this.itemId,
    required this.path,
    required this.isDefault,
    required this.createdAt,
  });

  factory ThumbnailModel.fromJson(Map<String, dynamic> json) {
    return ThumbnailModel(
      id: json['id'] as int? ?? 0,
      itemId: json['item_id'] as int? ?? json['itemId'] as int? ?? 0,
      path: json['path'] as String? ?? json['caminho'] as String? ?? '',
      isDefault: json['is_default'] == 1 ||
          json['is_default'] == true ||
          json['padrao'] == 1 ||
          json['padrao'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['criado_em'] != null
              ? DateTime.parse(json['criado_em'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'path': path,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ThumbnailModel copyWith({
    int? id,
    int? itemId,
    String? path,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return ThumbnailModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      path: path ?? this.path,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get fullUrl {
    // Se já for uma URL completa, retorna como está
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Caso contrário, constrói a URL baseada no backend
    // TODO: Ajustar conforme a URL base do backend
    return 'https://api.example.com/storage/$path';
  }

  @override
  String toString() {
    return 'ThumbnailModel(id: $id, itemId: $itemId, path: $path, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThumbnailModel &&
        other.id == id &&
        other.itemId == itemId &&
        other.path == path &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^ itemId.hashCode ^ path.hashCode ^ isDefault.hashCode;
  }
}
