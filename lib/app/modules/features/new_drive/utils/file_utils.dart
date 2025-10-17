/// Utilitários para validação e manipulação de arquivos
///
/// Contém helpers para:
/// - Verificação de tipos de arquivo suportados
/// - Obtenção de ícones e cores por tipo
/// - Formatação de tamanho de arquivo
class FileUtils {
  /// Verifica se o arquivo é suportado para abertura
  static bool isFileSupported(String fileName) {
    final extension = getFileExtension(fileName);
    return supportedExtensions.contains(extension);
  }

  /// Obtém a extensão do arquivo
  static String getFileExtension(String fileName) {
    if (!fileName.contains('.')) return '';
    return fileName.split('.').last.toLowerCase();
  }

  /// Lista de extensões suportadas
  static const List<String> supportedExtensions = [
    // Documentos
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'rtf',
    'odt',
    'ods',
    // Imagens
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'svg',
    'ico',
    // Vídeos
    'mp4',
    'avi',
    'mov',
    'mkv',
    'webm',
    '3gp',
    'flv',
    'wmv',
    // Áudio
    'mp3',
    'wav',
    'aac',
    'm4a',
    'flac',
    'ogg',
    'wma',
  ];

  /// Verifica se é um documento
  static bool isDocument(String fileName) {
    final extension = getFileExtension(fileName);
    return [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'rtf',
      'odt',
      'ods'
    ].contains(extension);
  }

  /// Verifica se é uma imagem
  static bool isImage(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg', 'ico']
        .contains(extension);
  }

  /// Verifica se é um vídeo
  static bool isVideo(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'avi', 'mov', 'mkv', 'webm', '3gp', 'flv', 'wmv']
        .contains(extension);
  }

  /// Verifica se é um áudio
  static bool isAudio(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'wma']
        .contains(extension);
  }

  /// Formata tamanho de arquivo (bytes para formato legível)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Remove caracteres especiais do nome do arquivo
  static String sanitizeFileName(String fileName) {
    // Remove caracteres que podem causar problemas no sistema de arquivos
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// Obtém uma mensagem amigável sobre tipo de arquivo não suportado
  static String getUnsupportedFileMessage(String fileName) {
    final extension = getFileExtension(fileName);

    if (extension.isEmpty) {
      return 'Arquivo sem extensão não pode ser aberto';
    }

    return 'Arquivos .$extension não são suportados.\n'
        'Tipos suportados: PDF, DOC, DOCX, XLS, XLSX, imagens, vídeos e áudios.';
  }

  /// Retorna o tipo MIME aproximado baseado na extensão
  static String? getMimeType(String fileName) {
    final extension = getFileExtension(fileName);

    // Documentos
    if (extension == 'pdf') return 'application/pdf';
    if (extension == 'doc') return 'application/msword';
    if (extension == 'docx') {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (extension == 'xls') return 'application/vnd.ms-excel';
    if (extension == 'xlsx') {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }

    // Imagens
    if (extension == 'jpg' || extension == 'jpeg') return 'image/jpeg';
    if (extension == 'png') return 'image/png';
    if (extension == 'gif') return 'image/gif';
    if (extension == 'webp') return 'image/webp';

    // Vídeos
    if (extension == 'mp4') return 'video/mp4';
    if (extension == 'avi') return 'video/x-msvideo';
    if (extension == 'mov') return 'video/quicktime';

    // Áudio
    if (extension == 'mp3') return 'audio/mpeg';
    if (extension == 'wav') return 'audio/wav';
    if (extension == 'aac') return 'audio/aac';

    return null;
  }
}
