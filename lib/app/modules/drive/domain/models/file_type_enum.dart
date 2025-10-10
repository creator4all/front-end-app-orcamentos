enum FileTypeEnum {
  folder,
  pdf,
  docx,
  xlsx,
  pptx,
  mp4,
  mp3,
  jpg,
  jpeg,
  png,
  gif,
  txt,
  zip,
  rar,
  other;

  static FileTypeEnum fromMimeType(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) return FileTypeEnum.other;

    // Folders
    if (mimeType == 'folder' || mimeType == 'directory') {
      return FileTypeEnum.folder;
    }

    // Documents
    if (mimeType == 'application/pdf') return FileTypeEnum.pdf;
    if (mimeType == 'application/msword' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return FileTypeEnum.docx;
    }
    if (mimeType == 'application/vnd.ms-excel' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return FileTypeEnum.xlsx;
    }
    if (mimeType == 'application/vnd.ms-powerpoint' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.presentationml.presentation') {
      return FileTypeEnum.pptx;
    }

    // Videos
    if (mimeType.startsWith('video/mp4') || mimeType == 'video/mp4') {
      return FileTypeEnum.mp4;
    }

    // Audio
    if (mimeType.startsWith('audio/mpeg') || mimeType == 'audio/mp3') {
      return FileTypeEnum.mp3;
    }

    // Images
    if (mimeType == 'image/jpeg' || mimeType == 'image/jpg') {
      return FileTypeEnum.jpg;
    }
    if (mimeType == 'image/png') return FileTypeEnum.png;
    if (mimeType == 'image/gif') return FileTypeEnum.gif;

    // Text
    if (mimeType == 'text/plain') return FileTypeEnum.txt;

    // Archives
    if (mimeType == 'application/zip' ||
        mimeType == 'application/x-zip-compressed') {
      return FileTypeEnum.zip;
    }
    if (mimeType == 'application/x-rar-compressed' ||
        mimeType == 'application/rar') {
      return FileTypeEnum.rar;
    }

    return FileTypeEnum.other;
  }

  static FileTypeEnum fromExtension(String? filename) {
    if (filename == null || filename.isEmpty) return FileTypeEnum.other;

    final extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return FileTypeEnum.pdf;
      case 'doc':
      case 'docx':
        return FileTypeEnum.docx;
      case 'xls':
      case 'xlsx':
        return FileTypeEnum.xlsx;
      case 'ppt':
      case 'pptx':
        return FileTypeEnum.pptx;
      case 'mp4':
      case 'avi':
      case 'mov':
        return FileTypeEnum.mp4;
      case 'mp3':
      case 'wav':
        return FileTypeEnum.mp3;
      case 'jpg':
      case 'jpeg':
        return FileTypeEnum.jpg;
      case 'png':
        return FileTypeEnum.png;
      case 'gif':
        return FileTypeEnum.gif;
      case 'txt':
        return FileTypeEnum.txt;
      case 'zip':
        return FileTypeEnum.zip;
      case 'rar':
        return FileTypeEnum.rar;
      default:
        return FileTypeEnum.other;
    }
  }

  String get displayName {
    switch (this) {
      case FileTypeEnum.folder:
        return 'Pasta';
      case FileTypeEnum.pdf:
        return 'PDF';
      case FileTypeEnum.docx:
        return 'Word';
      case FileTypeEnum.xlsx:
        return 'Excel';
      case FileTypeEnum.pptx:
        return 'PowerPoint';
      case FileTypeEnum.mp4:
        return 'Vídeo';
      case FileTypeEnum.mp3:
        return 'Áudio';
      case FileTypeEnum.jpg:
      case FileTypeEnum.jpeg:
      case FileTypeEnum.png:
      case FileTypeEnum.gif:
        return 'Imagem';
      case FileTypeEnum.txt:
        return 'Texto';
      case FileTypeEnum.zip:
      case FileTypeEnum.rar:
        return 'Arquivo';
      case FileTypeEnum.other:
        return 'Arquivo';
    }
  }

  String get extension {
    return name.toUpperCase();
  }
}
