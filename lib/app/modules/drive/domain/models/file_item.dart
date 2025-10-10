import 'file_thumbnail.dart';
import 'file_type_enum.dart';

class FileItem {
  final int id;
  final String name;
  final String? description;
  final String? mimeType;
  final int? size;
  final String? path;
  final int? parentId;
  final bool isFolder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? uploadedBy;
  final String? uploaderName;
  final ThumbnailModel? defaultThumbnail;
  final List<ThumbnailModel>? thumbnails;

  const FileItem({
    required this.id,
    required this.name,
    this.description,
    this.mimeType,
    this.size,
    this.path,
    this.parentId,
    required this.isFolder,
    required this.createdAt,
    this.updatedAt,
    this.uploadedBy,
    this.uploaderName,
    this.defaultThumbnail,
    this.thumbnails,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    // Parse thumbnails list
    List<ThumbnailModel>? thumbList;
    if (json['thumbnails'] != null) {
      thumbList = (json['thumbnails'] as List)
          .map((t) => ThumbnailModel.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    // Parse default thumbnail
    ThumbnailModel? defaultThumb;
    if (json['default_thumbnail'] != null) {
      defaultThumb = ThumbnailModel.fromJson(
          json['default_thumbnail'] as Map<String, dynamic>);
    } else if (json['thumbnail_padrao'] != null) {
      defaultThumb = ThumbnailModel.fromJson(
          json['thumbnail_padrao'] as Map<String, dynamic>);
    }

    return FileItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? json['nome'] as String? ?? 'Sem nome',
      description:
          json['description'] as String? ?? json['descricao'] as String?,
      mimeType: json['mime_type'] as String? ?? json['tipo_mime'] as String?,
      size: json['size'] as int? ?? json['tamanho'] as int?,
      path: json['path'] as String? ?? json['caminho'] as String?,
      parentId: json['parent_id'] as int? ?? json['pasta_pai_id'] as int?,
      isFolder: json['is_folder'] == 1 ||
          json['is_folder'] == true ||
          json['tipo'] == 'pasta' ||
          json['tipo'] == 'folder',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['criado_em'] != null
              ? DateTime.parse(json['criado_em'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['atualizado_em'] != null
              ? DateTime.parse(json['atualizado_em'] as String)
              : null,
      uploadedBy: json['uploaded_by'] as int? ?? json['enviado_por'] as int?,
      uploaderName: json['uploader_name'] as String? ??
          json['nome_enviador'] as String? ??
          json['nome_usuario'] as String?,
      defaultThumbnail: defaultThumb,
      thumbnails: thumbList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mime_type': mimeType,
      'size': size,
      'path': path,
      'parent_id': parentId,
      'is_folder': isFolder ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'uploaded_by': uploadedBy,
      'uploader_name': uploaderName,
      'default_thumbnail': defaultThumbnail?.toJson(),
      'thumbnails': thumbnails?.map((t) => t.toJson()).toList(),
    };
  }

  // Getters úteis
  FileTypeEnum get fileType {
    if (isFolder) return FileTypeEnum.folder;
    return FileTypeEnum.fromMimeType(mimeType) != FileTypeEnum.other
        ? FileTypeEnum.fromMimeType(mimeType)
        : FileTypeEnum.fromExtension(name);
  }

  bool get isDocument {
    final type = fileType;
    return type == FileTypeEnum.pdf ||
        type == FileTypeEnum.docx ||
        type == FileTypeEnum.xlsx ||
        type == FileTypeEnum.pptx ||
        type == FileTypeEnum.txt;
  }

  bool get isMedia {
    return isImage || isVideo || isAudio;
  }

  bool get isImage {
    final type = fileType;
    return type == FileTypeEnum.jpg ||
        type == FileTypeEnum.jpeg ||
        type == FileTypeEnum.png ||
        type == FileTypeEnum.gif;
  }

  bool get isVideo {
    return fileType == FileTypeEnum.mp4;
  }

  bool get isAudio {
    return fileType == FileTypeEnum.mp3;
  }

  bool get isPdf {
    return fileType == FileTypeEnum.pdf;
  }

  bool get isArchive {
    final type = fileType;
    return type == FileTypeEnum.zip || type == FileTypeEnum.rar;
  }

  String get fileExtension {
    if (isFolder) return 'PASTA';
    if (name.contains('.')) {
      return name.split('.').last.toUpperCase();
    }
    return fileType.extension;
  }

  String get fileSizeFormatted {
    if (size == null || size == 0) return '-';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) {
      return '${(size! / 1024).toStringAsFixed(1)} KB';
    }
    if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get thumbnailUrl {
    if (defaultThumbnail != null) {
      return defaultThumbnail!.fullUrl;
    }
    // Retornar placeholder baseado no tipo
    return '';
  }

  String get downloadUrl {
    // TODO: Ajustar conforme a URL base do backend
    return 'https://api.example.com/api/files/$id/download';
  }

  String get viewUrl {
    // TODO: Ajustar conforme a URL base do backend
    return 'https://api.example.com/api/files/$id/view';
  }

  FileItem copyWith({
    int? id,
    String? name,
    String? description,
    String? mimeType,
    int? size,
    String? path,
    int? parentId,
    bool? isFolder,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? uploadedBy,
    String? uploaderName,
    ThumbnailModel? defaultThumbnail,
    List<ThumbnailModel>? thumbnails,
  }) {
    return FileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      path: path ?? this.path,
      parentId: parentId ?? this.parentId,
      isFolder: isFolder ?? this.isFolder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      defaultThumbnail: defaultThumbnail ?? this.defaultThumbnail,
      thumbnails: thumbnails ?? this.thumbnails,
    );
  }

  @override
  String toString() {
    return 'FileItem(id: $id, name: $name, isFolder: $isFolder, size: $fileSizeFormatted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileItem && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
