import 'package:multimidiaapp/config/api_config.dart';
import 'package:multimidiaapp/services/api_service.dart';

import '../../domain/models/file_item.dart';
import '../../domain/models/file_share.dart';
import '../../domain/models/file_thumbnail.dart';
import '../helpers/file_opener_helper.dart';

class DriveService {
  final ApiService _api;

  DriveService(this._api);

  // ==================== LISTAGEM (READ-ONLY) ====================

  /// Lista todos os arquivos do usuário (compartilhados + próprios se admin)
  Future<List<FileItem>> listarArquivos({int? parentId, String? token}) async {
    try {
      final queryParams = parentId != null ? '?parent_id=$parentId' : '';
      final endpoint = '${ApiConfig.baseUrl}/api/files$queryParams';

      print('🌐 Buscando arquivos: $endpoint');

      final response = await _api.get(endpoint, token: token);

      if (response['success'] == true) {
        final data = response['data'];
        final List items;

        if (data is Map && data['dados'] is List) {
          items = data['dados'] as List;
        } else if (data is List) {
          items = data;
        } else {
          items = [];
        }

        print('✅ Arquivos carregados: ${items.length}');
        return items
            .map((e) => FileItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        throw Exception(response['error'] ?? 'Erro ao listar arquivos');
      }
    } catch (e) {
      print('❌ Erro ao listar arquivos: $e');
      rethrow;
    }
  }

  /// Lista apenas arquivos compartilhados com o usuário
  Future<List<FileItem>> listarArquivosCompartilhados({String? token}) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}/api/share';

      print('🌐 Buscando arquivos compartilhados: $endpoint');

      final response = await _api.get(endpoint, token: token);

      print('📦 Resposta completa: $response');

      if (response['sucesso'] == true || response['success'] == true) {
        var data = response['dados'] ?? response['data'];

        // Se data tem um campo 'dados' dentro, desça mais um nível
        if (data is Map && data['dados'] != null) {
          data = data['dados'];
        }

        final List items;

        // A API retorna: {sucesso: true, dados: {data: [...], pagination: {...}}}
        if (data is Map && data['data'] is List) {
          items = data['data'] as List;
        } else if (data is List) {
          items = data;
        } else {
          print('⚠️  Estrutura de dados não reconhecida: $data');
          items = [];
        }

        print('✅ Arquivos compartilhados carregados: ${items.length}');

        // Extrair o item de dentro da estrutura de compartilhamento
        final List<FileItem> fileItems = items.map((shareItem) {
          final Map<String, dynamic> share =
              Map<String, dynamic>.from(shareItem as Map);

          // O arquivo está dentro de share['item']
          if (share['item'] != null) {
            final Map<String, dynamic> itemData =
                Map<String, dynamic>.from(share['item'] as Map);

            // Obter nome de quem compartilhou (pode vir de share['sharedBy'])
            String? sharedByName;
            if (share['sharedBy'] != null) {
              final sharedBy =
                  Map<String, dynamic>.from(share['sharedBy'] as Map);
              sharedByName = sharedBy['usr_name'] as String?;
            }

            // Mapear os campos da API para o formato esperado
            final mappedData = {
              'id': itemData['ite_itemId'],
              'name': itemData['ite_name'],
              'mime_type': itemData['ite_mimeType'],
              'size': itemData['ite_size'],
              'path': itemData['ite_path'],
              'parent_id': itemData['ite_parentId'],
              'is_folder': itemData['ite_type'] == 'folder' ? 1 : 0,
              'created_at': itemData['created_at'],
              'updated_at': itemData['updated_at'],
              'uploaded_by': itemData['ite_userId'],
              'uploader_name':
                  sharedByName, // Nome de quem compartilhou com o usuário
            };

            print(
                '📄 Mapeando arquivo: ${mappedData['name']} (parent_id: ${mappedData['parent_id']}, compartilhado por: $sharedByName)');

            return FileItem.fromJson(mappedData);
          }

          // Fallback caso não tenha a estrutura esperada
          print('⚠️  Usando fallback para: $share');
          return FileItem.fromJson(share);
        }).toList();

        print('🎯 Total de arquivos mapeados: ${fileItems.length}');
        return fileItems;
      } else {
        throw Exception(
            response['error'] ?? 'Erro ao listar arquivos compartilhados');
      }
    } catch (e) {
      print('❌ Erro ao listar arquivos compartilhados: $e');
      rethrow;
    }
  }

  /// Busca detalhes de um arquivo específico
  Future<FileItem> buscarPorId(int id, {String? token}) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}/api/files/$id';

      print('🔍 Buscando arquivo ID: $id');

      final response = await _api.get(endpoint, token: token);

      if (response['success'] == true) {
        final data = response['data'];
        final Map<String, dynamic> fileData;

        if (data is Map && data['dados'] is Map) {
          fileData = Map<String, dynamic>.from(data['dados'] as Map);
        } else if (data is Map) {
          fileData = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Formato de resposta inválido');
        }

        print('✅ Arquivo carregado: ${fileData['name']}');
        return FileItem.fromJson(fileData);
      } else {
        throw Exception(response['error'] ?? 'Erro ao buscar arquivo');
      }
    } catch (e) {
      print('❌ Erro ao buscar arquivo: $e');
      rethrow;
    }
  }

  /// Obtém hierarquia de pastas
  Future<Map<String, dynamic>> obterHierarquia(int id, {String? token}) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}/api/files/$id/hierarchy';

      print('📂 Buscando hierarquia do arquivo ID: $id');

      final response = await _api.get(endpoint, token: token);

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        print('✅ Hierarquia carregada');
        return Map<String, dynamic>.from(data is Map ? data : {});
      } else {
        throw Exception(response['error'] ?? 'Erro ao obter hierarquia');
      }
    } catch (e) {
      print('❌ Erro ao obter hierarquia: $e');
      rethrow;
    }
  }

  // ==================== COMPARTILHAMENTOS (INFO ONLY) ====================

  /// Lista compartilhamentos de um arquivo específico
  Future<List<FileShare>> listarCompartilhamentos(int itemId,
      {String? token}) async {
    try {
      final endpoint =
          '${ApiConfig.baseUrl}/api/files/$itemId/compartilhamentos';

      print('🔗 Buscando compartilhamentos do arquivo ID: $itemId');

      final response = await _api.get(endpoint, token: token);

      if (response['success'] == true) {
        final data = response['data'];
        final List items;

        if (data is Map && data['dados'] is List) {
          items = data['dados'] as List;
        } else if (data is List) {
          items = data;
        } else {
          items = [];
        }

        print('✅ Compartilhamentos carregados: ${items.length}');
        return items
            .map((e) => FileShare.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        throw Exception(
            response['error'] ?? 'Erro ao listar compartilhamentos');
      }
    } catch (e) {
      print('❌ Erro ao listar compartilhamentos: $e');
      rethrow;
    }
  }

  /// Lista itens compartilhados por um arquivo
  Future<List<FileItem>> listarMeusCompartilhamentos({String? token}) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}/api/share';

      print('🔗 Buscando meus compartilhamentos');

      final response = await _api.get(endpoint, token: token);

      if (response['success'] == true) {
        final data = response['data'];
        final List items;

        if (data is Map && data['dados'] is List) {
          items = data['dados'] as List;
        } else if (data is List) {
          items = data;
        } else {
          items = [];
        }

        print('✅ Meus compartilhamentos carregados: ${items.length}');
        return items
            .map((e) => FileItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        throw Exception(
            response['error'] ?? 'Erro ao listar meus compartilhamentos');
      }
    } catch (e) {
      print('❌ Erro ao listar meus compartilhamentos: $e');
      rethrow;
    }
  }

  // ==================== THUMBNAILS ====================

  /// Lista todos os thumbnails de um arquivo
  Future<List<ThumbnailModel>> listarThumbnails(int itemId,
      {String? token}) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}/api/files/$itemId/thumbnails';

      print('🖼️ Buscando thumbnails do arquivo ID: $itemId');

      final response = await _api.get(endpoint, token: token);

      if (response['success'] == true) {
        final data = response['data'];
        final List items;

        if (data is Map && data['dados'] is List) {
          items = data['dados'] as List;
        } else if (data is List) {
          items = data;
        } else {
          items = [];
        }

        print('✅ Thumbnails carregados: ${items.length}');
        return items
            .map((e) =>
                ThumbnailModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        throw Exception(response['error'] ?? 'Erro ao listar thumbnails');
      }
    } catch (e) {
      print('❌ Erro ao listar thumbnails: $e');
      rethrow;
    }
  }

  /// Obtém URL do thumbnail padrão
  String obterThumbnailUrl(int itemId) {
    return '${ApiConfig.baseUrl}/api/files/$itemId/thumbnail';
  }

  // ==================== DOWNLOADS E VISUALIZAÇÃO ====================

  /// Obtém URL de download do arquivo
  String obterUrlDownload(int itemId) {
    return '${ApiConfig.baseUrl}/api/files/$itemId/download';
  }

  /// Obtém URL de visualização do arquivo
  String obterUrlVisualizacao(int itemId) {
    return '${ApiConfig.baseUrl}/api/files/$itemId/view';
  }

  /// Baixa arquivo e retorna o caminho local
  Future<String> baixarArquivo(
    int itemId,
    String fileName, {
    String? token,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final url = obterUrlDownload(itemId);
      final sanitizedFileName = FileOpenerHelper.sanitizeFileName(fileName);

      print('📥 Baixando arquivo: $sanitizedFileName');

      final filePath = await FileOpenerHelper.downloadFile(
        fileUrl: url,
        fileName: sanitizedFileName,
        token: token,
        onProgress: onProgress != null
            ? (progress) => onProgress(
                  (progress * 100).toInt(),
                  100,
                )
            : null,
      );

      print('✅ Arquivo baixado: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Erro ao baixar arquivo: $e');
      rethrow;
    }
  }

  /// Baixa arquivo e abre com app nativo (DOCX, PDF, XLSX, etc)
  Future<void> baixarEAbrirArquivo(
    int itemId,
    String fileName, {
    String? token,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final url = obterUrlDownload(itemId);
      final sanitizedFileName = FileOpenerHelper.sanitizeFileName(fileName);

      print('📱 Baixando e abrindo arquivo: $sanitizedFileName');

      await FileOpenerHelper.openWithNativeApp(
        fileUrl: url,
        fileName: sanitizedFileName,
        token: token,
        onProgress: onProgress != null
            ? (progress) => onProgress(
                  (progress * 100).toInt(),
                  100,
                )
            : null,
      );

      print('✅ Arquivo aberto com sucesso');
    } catch (e) {
      print('❌ Erro ao abrir arquivo: $e');
      rethrow;
    }
  }

  /// Obtém arquivo em cache ou baixa se necessário
  Future<String> obterArquivoLocal(
    int itemId,
    String fileName, {
    String? token,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final sanitizedFileName = FileOpenerHelper.sanitizeFileName(fileName);

      // Verificar se já está em cache
      final cachedPath =
          await FileOpenerHelper.getCachedFilePath(sanitizedFileName);

      if (cachedPath != null) {
        print('✅ Arquivo encontrado em cache: $cachedPath');
        return cachedPath;
      }

      // Se não estiver em cache, baixar
      print('📥 Arquivo não encontrado em cache, baixando...');
      return await baixarArquivo(
        itemId,
        fileName,
        token: token,
        onProgress: onProgress,
      );
    } catch (e) {
      print('❌ Erro ao obter arquivo local: $e');
      rethrow;
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Verifica se arquivo está em cache
  Future<bool> isFileInCache(String fileName) async {
    final sanitizedFileName = FileOpenerHelper.sanitizeFileName(fileName);
    return await FileOpenerHelper.isFileInCache(sanitizedFileName);
  }

  /// Deleta arquivo do cache
  Future<void> deleteFromCache(String fileName) async {
    final sanitizedFileName = FileOpenerHelper.sanitizeFileName(fileName);
    await FileOpenerHelper.deleteFromCache(sanitizedFileName);
  }

  /// Limpa todo o cache
  Future<void> clearCache() async {
    await FileOpenerHelper.clearCache();
  }

  /// Obtém tamanho do cache
  Future<int> getCacheSize() async {
    return await FileOpenerHelper.getCacheSize();
  }

  /// Formata tamanho do cache
  String formatCacheSize(int bytes) {
    return FileOpenerHelper.formatBytes(bytes);
  }
}
