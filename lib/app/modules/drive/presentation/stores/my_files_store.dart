import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobx/mobx.dart';

import '../../domain/models/breadcrumb_item.dart';
import '../../domain/models/file_item.dart';
import '../../external/services/drive_service.dart';

part 'my_files_store.g.dart';

class MyFilesStore = _MyFilesStore with _$MyFilesStore;

abstract class _MyFilesStore with Store {
  final DriveService _service;
  final String? Function() _getToken;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  _MyFilesStore(this._service, this._getToken);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  ObservableList<FileItem> files = ObservableList<FileItem>();

  @observable
  ObservableList<FileItem> allFiles = ObservableList<FileItem>();

  @observable
  String searchQuery = '';

  @observable
  String filterType =
      'all'; // 'all', 'folders', 'documents', 'images', 'videos'

  @observable
  int? currentFolderId;

  @observable
  ObservableList<BreadcrumbItem> breadcrumb = ObservableList<BreadcrumbItem>();

  @observable
  ObservableMap<int, double> downloadProgress = ObservableMap();

  @observable
  ObservableSet<int> downloadingFiles = ObservableSet();

  @computed
  List<FileItem> get filteredFiles {
    List<FileItem> filtered = List.from(allFiles);

    // Filtrar por tipo
    if (filterType != 'all') {
      filtered = filtered.where((file) {
        switch (filterType) {
          case 'folders':
            return file.isFolder;
          case 'documents':
            return file.isDocument;
          case 'images':
            return file.isImage;
          case 'videos':
            return file.isVideo;
          default:
            return true;
        }
      }).toList();
    }

    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((file) {
        final name = file.name.toLowerCase();
        final desc = file.description?.toLowerCase() ?? '';
        return name.contains(query) || desc.contains(query);
      }).toList();
    }

    return filtered;
  }

  @computed
  String get currentPath {
    if (breadcrumb.isEmpty) return 'Início';
    return breadcrumb.map((b) => b.name).join(' > ');
  }

  @computed
  bool get canGoBack => breadcrumb.length > 1;

  @action
  Future<void> loadMyFiles({int? folderId}) async {
    isLoading = true;
    error = null;

    try {
      print('📁 Carregando meus arquivos (pasta: $folderId)...');

      var token = _getToken();
      token ??= await _storage.read(key: 'auth_token');

      final loadedFiles = await _service.listarArquivos(
        parentId: folderId,
        token: token,
      );

      allFiles.clear();
      allFiles.addAll(loadedFiles);

      files.clear();
      files.addAll(filteredFiles);

      currentFolderId = folderId;

      print('✅ Meus arquivos carregados: ${allFiles.length}');
    } catch (e) {
      error = 'Erro ao carregar arquivos: $e';
      print('❌ Erro: $error');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refresh() async {
    await loadMyFiles(folderId: currentFolderId);
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
    files.clear();
    files.addAll(filteredFiles);
  }

  @action
  void setFilterType(String type) {
    filterType = type;
    files.clear();
    files.addAll(filteredFiles);
  }

  @action
  Future<void> navigateToFolder(FileItem folder) async {
    if (!folder.isFolder) return;

    // Adicionar ao breadcrumb
    breadcrumb.add(BreadcrumbItem.fromFolder(id: folder.id, name: folder.name));

    // Carregar arquivos da pasta
    await loadMyFiles(folderId: folder.id);
  }

  @action
  Future<void> navigateToBreadcrumb(int index) async {
    if (index < 0 || index >= breadcrumb.length) return;

    // Remover itens após o índice clicado
    final itemsToRemove = breadcrumb.length - index - 1;
    for (int i = 0; i < itemsToRemove; i++) {
      breadcrumb.removeLast();
    }

    // Carregar arquivos da pasta
    final item = breadcrumb[index];
    await loadMyFiles(folderId: item.id);
  }

  @action
  Future<void> navigateBack() async {
    if (!canGoBack) return;

    breadcrumb.removeLast();

    final previousFolder = breadcrumb.isNotEmpty ? breadcrumb.last.id : null;
    await loadMyFiles(folderId: previousFolder);
  }

  @action
  Future<void> navigateToRoot() async {
    breadcrumb.clear();
    breadcrumb.add(BreadcrumbItem.root());
    await loadMyFiles();
  }

  @action
  Future<void> downloadFile(FileItem file) async {
    try {
      downloadingFiles.add(file.id);
      downloadProgress[file.id] = 0.0;

      print('📥 Iniciando download: ${file.name}');

      var token = _getToken();
      token ??= await _storage.read(key: 'auth_token');

      await _service.baixarArquivo(
        file.id,
        file.name,
        token: token,
        onProgress: (received, total) {
          runInAction(() {
            downloadProgress[file.id] = received / total;
          });
        },
      );

      print('✅ Download concluído: ${file.name}');
    } catch (e) {
      print('❌ Erro ao baixar arquivo: $e');
      error = 'Erro ao baixar arquivo: $e';
      rethrow;
    } finally {
      downloadingFiles.remove(file.id);
      downloadProgress.remove(file.id);
    }
  }

  @action
  Future<void> openFileWithNativeApp(FileItem file) async {
    try {
      if (file.isFolder) return;

      downloadingFiles.add(file.id);
      downloadProgress[file.id] = 0.0;

      print('📱 Abrindo arquivo: ${file.name}');

      var token = _getToken();
      token ??= await _storage.read(key: 'auth_token');

      await _service.baixarEAbrirArquivo(
        file.id,
        file.name,
        token: token,
        onProgress: (received, total) {
          runInAction(() {
            downloadProgress[file.id] = received / total;
          });
        },
      );

      print('✅ Arquivo aberto com sucesso');
    } catch (e) {
      print('❌ Erro ao abrir arquivo: $e');
      error = 'Erro ao abrir arquivo: $e';
      rethrow;
    } finally {
      downloadingFiles.remove(file.id);
      downloadProgress.remove(file.id);
    }
  }

  @action
  void clearError() {
    error = null;
  }

  @action
  void reset() {
    files.clear();
    allFiles.clear();
    searchQuery = '';
    filterType = 'all';
    currentFolderId = null;
    breadcrumb.clear();
    breadcrumb.add(BreadcrumbItem.root());
    downloadProgress.clear();
    downloadingFiles.clear();
    error = null;
  }
}
