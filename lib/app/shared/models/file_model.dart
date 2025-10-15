enum FileType { pdf, docx, xlsx, pptx, mp4, jpg, png, folder }

class FileModel {
  final String id;
  final String name;
  final FileType type;
  final DateTime sharedDate;
  final String sharedBy;
  final String? thumbnailUrl; // Para vídeos e imagens
  final int? itemCount; // Para pastas - número de itens dentro

  const FileModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sharedDate,
    required this.sharedBy,
    this.thumbnailUrl,
    this.itemCount,
  });

  bool get isFolder => type == FileType.folder;

  String get extension {
    if (isFolder) return 'PASTA';
    switch (type) {
      case FileType.pdf:
        return 'PDF';
      case FileType.docx:
        return 'DOCX';
      case FileType.xlsx:
        return 'XLSX';
      case FileType.pptx:
        return 'PPTX';
      case FileType.mp4:
        return 'MP4';
      case FileType.jpg:
        return 'JPG';
      case FileType.png:
        return 'PNG';
      case FileType.folder:
        return 'PASTA';
    }
  }

  bool get canOpen =>
      isFolder ||
      type == FileType.mp4 ||
      type == FileType.jpg ||
      type == FileType.png;
  bool get canDownload =>
      !isFolder; // Pastas não podem ser baixadas diretamente
}
