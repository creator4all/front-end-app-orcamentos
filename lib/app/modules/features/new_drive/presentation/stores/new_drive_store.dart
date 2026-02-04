import 'package:mobx/mobx.dart';

import '../../domain/entities/drive_category.dart';
import '../../domain/entities/drive_item.dart';
import '../../domain/usecases/get_file_details_usecase.dart';
import '../../domain/usecases/get_folder_contents_usecase.dart';
import '../../domain/usecases/get_own_files_usecase.dart';
import '../../domain/usecases/get_recent_items_usecase.dart';

part 'new_drive_store.g.dart';

class FolderBreadcrumb {
  final String id;
  final String name;

  FolderBreadcrumb({required this.id, required this.name});
}

class NewDriveStore = _NewDriveStoreBase with _$NewDriveStore;

abstract class _NewDriveStoreBase with Store {
  final GetRecentItemsUseCase? getRecentItemsUseCase;
  final GetOwnFilesUseCase? getOwnFilesUseCase;
  final GetFolderContentsUseCase? getFolderContentsUseCase;
  final GetFileDetailsUseCase? getFileDetailsUseCase;

  _NewDriveStoreBase({
    this.getRecentItemsUseCase,
    this.getOwnFilesUseCase,
    this.getFolderContentsUseCase,
    this.getFileDetailsUseCase,
  });

  // Observables

  @observable
  ObservableList<DriveItem> allItems = ObservableList<DriveItem>();

  @observable
  ObservableList<DriveCategory> categories = ObservableList<DriveCategory>();

  @observable
  String searchQuery = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  DriveItemType? selectedCategoryType;

  @observable
  String? viewMode; // 'category', 'my-files', 'all-shared'

  @observable
  ObservableList<DriveItem> ownFiles = ObservableList<DriveItem>();

  @observable
  bool isLoadingOwnFiles = false;

  @observable
  DriveItem? currentFolder; // Pasta atualmente aberta

  @observable
  bool isLoadingFolder = false;

  @observable
  ObservableList<FolderBreadcrumb> folderStack =
      ObservableList<FolderBreadcrumb>();

  // Computed

  @computed
  List<DriveItem> get recentItems {
    // Retorna os 4 itens compartilhados mais recentemente (apenas raiz)
    final sorted = allItems.where((item) => item.parentId == null).toList()
      ..sort((a, b) => b.lastViewed.compareTo(a.lastViewed));
    return sorted.take(4).toList();
  }

  @computed
  List<DriveItem> get selectedCategoryItems {
    // Retorna itens filtrados pela categoria selecionada (apenas raiz)
    if (selectedCategoryType == null) {
      return [];
    }
    return allItems
        .where((item) =>
            item.type == selectedCategoryType && item.parentId == null)
        .toList();
  }

  @computed
  List<DriveItem> get filteredCategoryItems {
    // Retorna itens da categoria filtrados por busca
    var items = selectedCategoryItems;

    if (searchQuery.isEmpty) {
      return items;
    }

    final query = searchQuery.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  @computed
  List<DriveItem> get viewItems {
    // Retorna itens baseado no modo de visualização
    switch (viewMode) {
      case 'category':
        return selectedCategoryItems;
      case 'my-files':
        // Arquivos enviados pelo usuário
        return ownFiles.toList();
      case 'all-shared':
        // Todos os arquivos compartilhados
        return allItems;
      default:
        return [];
    }
  }

  @computed
  List<DriveItem> get filteredViewItems {
    // Retorna itens do modo de visualização filtrados por busca
    var items = viewItems;

    if (searchQuery.isEmpty) {
      return items;
    }

    final query = searchQuery.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  // Actions

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
    // TODO: Implementar busca quando usecase estiver disponível
  }

  @action
  Future<void> loadRecentItems() async {
    isLoading = true;
    errorMessage = null;

    try {
      if (getRecentItemsUseCase != null) {
        final result = await getRecentItemsUseCase!();

        result.fold(
          (failure) => errorMessage = failure.message,
          (items) {
            allItems.clear();
            allItems.addAll(items);
          },
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        allItems.clear();
        allItems.addAll(_getMockedRecentItems());
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar itens compartilhados recentemente';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadOwnFiles() async {
    isLoadingOwnFiles = true;
    errorMessage = null;

    try {
      if (getOwnFilesUseCase != null) {
        final result = await getOwnFilesUseCase!();

        result.fold(
          (failure) => errorMessage = failure.message,
          (items) {
            ownFiles.clear();
            ownFiles.addAll(items);
          },
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        ownFiles.clear();
        ownFiles.addAll(_getMockedRecentItems());
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar meus arquivos';
    } finally {
      isLoadingOwnFiles = false;
    }
  }

  @action
  Future<void> loadFolderContents(String folderId) async {
    isLoadingFolder = true;
    errorMessage = null;

    try {
      if (getFolderContentsUseCase != null) {
        final result = await getFolderContentsUseCase!(folderId);

        result.fold(
          (failure) => errorMessage = failure.message,
          (folderItem) => currentFolder = folderItem,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        currentFolder = _getMockedFolderItem();
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar conteúdo da pasta';
    } finally {
      isLoadingFolder = false;
    }
  }

  @action
  Future<void> loadCategories() async {
    // Categorias são fixas, mas as estatísticas vêm dos itens carregados (apenas raiz)
    categories.clear();

    final rootItems = allItems.where((item) => item.parentId == null);

    // Contar itens por tipo
    final documents =
        rootItems.where((item) => item.type == DriveItemType.document).length;
    final images =
        rootItems.where((item) => item.type == DriveItemType.image).length;
    final videos =
        rootItems.where((item) => item.type == DriveItemType.video).length;
    final folders =
        rootItems.where((item) => item.type == DriveItemType.folder).length;

    // Calcular tamanho total por categoria
    final documentsSize = _calculateTotalSize(
        rootItems.where((item) => item.type == DriveItemType.document));
    final imagesSize = _calculateTotalSize(
        rootItems.where((item) => item.type == DriveItemType.image));
    final videosSize = _calculateTotalSize(
        rootItems.where((item) => item.type == DriveItemType.video));
    final foldersSize = _calculateTotalSize(
        rootItems.where((item) => item.type == DriveItemType.folder));

    categories.addAll([
      DriveCategory(
        id: 'cat_documents',
        name: 'Documentos',
        type: DriveItemType.document,
        itemCount: documents,
        totalSize: documentsSize,
      ),
      DriveCategory(
        id: 'cat_images',
        name: 'Imagens',
        type: DriveItemType.image,
        itemCount: images,
        totalSize: imagesSize,
      ),
      DriveCategory(
        id: 'cat_videos',
        name: 'Vídeos',
        type: DriveItemType.video,
        itemCount: videos,
        totalSize: videosSize,
      ),
      DriveCategory(
        id: 'cat_folders',
        name: 'Pastas',
        type: DriveItemType.folder,
        itemCount: folders,
        totalSize: foldersSize,
      ),
    ]);
  }

  /// Calcula tamanho total de uma lista de itens usando os valores reais da API
  String _calculateTotalSize(Iterable<DriveItem> items) {
    if (items.isEmpty) return '0 MB';

    double totalMB = 0.0;
    for (final item in items) {
      totalMB += _parseSizeToMB(item.size);
    }
    return '${totalMB.toStringAsFixed(1)} MB';
  }

  /// Converte string de tamanho (ex: "2.5 MB", "500 KB") para megabytes
  double _parseSizeToMB(String size) {
    final regex = RegExp(r'([\d.]+)\s*(B|KB|MB|GB)', caseSensitive: false);
    final match = regex.firstMatch(size);
    if (match == null) return 0.0;

    final value = double.tryParse(match.group(1)!) ?? 0.0;
    final unit = match.group(2)!.toUpperCase();

    return switch (unit) {
      'B' => value / (1024 * 1024),
      'KB' => value / 1024,
      'MB' => value,
      'GB' => value * 1024,
      _ => 0.0,
    };
  }

  @action
  Future<void> initialize() async {
    await loadRecentItems();
    // Carregar categorias após ter os itens
    await loadCategories();
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  /// Busca detalhes de um arquivo específico
  /// Retorna DriveItem com sharedBy e downloadUrl preenchidos
  Future<DriveItem?> getFileDetails(String fileId) async {
    if (getFileDetailsUseCase == null) return null;

    final result = await getFileDetailsUseCase!(fileId);
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        return null;
      },
      (item) => item,
    );
  }

  @action
  void selectCategory(DriveItemType type) {
    selectedCategoryType = type;
  }

  @action
  void clearSelectedCategory() {
    selectedCategoryType = null;
  }

  @action
  void setViewMode(String mode) {
    viewMode = mode;
    // Limpar busca ao mudar de modo
    searchQuery = '';

    // Carregar dados específicos do modo
    if (mode == 'my-files') {
      loadOwnFiles();
    }
  }

  @action
  void clearViewMode() {
    viewMode = null;
    searchQuery = '';
  }

  @action
  void navigateToFolder(String folderId, String folderName) {
    // Evita duplicar a pasta atual se for recarregada
    if (folderStack.isNotEmpty && folderStack.last.id == folderId) {
      return;
    }
    folderStack.add(FolderBreadcrumb(id: folderId, name: folderName));
  }

  @action
  void navigateBack() {
    if (folderStack.isNotEmpty) {
      folderStack.removeLast();

      if (folderStack.isNotEmpty) {
        loadFolderContents(folderStack.last.id);
      } else {
        // Se a pilha ficou vazia, estamos voltando para a raiz
        currentFolder = null;
      }
    }
  }

  @action
  void navigateToStackIndex(int index) {
    if (index >= 0 && index < folderStack.length) {
      // Remove todos os itens após o índice selecionado
      final itemsToRemove = folderStack.length - 1 - index;
      for (var i = 0; i < itemsToRemove; i++) {
        folderStack.removeLast();
      }
      // Carrega o conteúdo da pasta que agora está no topo
      loadFolderContents(folderStack.last.id);
    } else if (index == -1) {
      // Volta para a raiz (Drive)
      folderStack.clear();
      currentFolder = null;
    }
  }

  // Métodos auxiliares para dados mockados
  // TODO: Remover quando integrar com backend

  List<DriveItem> _getMockedRecentItems() {
    final now = DateTime.now();
    return [
      DriveItem(
        id: '1',
        name: 'Relatório Mensal.pdf',
        type: DriveItemType.document,
        size: '2.5 MB',
        lastViewed: now,
      ),
      DriveItem(
        id: '2',
        name: 'Apresentação Q4.pptx',
        type: DriveItemType.document,
        size: '8.3 MB',
        lastViewed: now.subtract(const Duration(days: 1)),
      ),
      DriveItem(
        id: '3',
        name: 'Video Tutorial.mp4',
        type: DriveItemType.video,
        size: '101 MB',
        lastViewed: now,
        thumbnailUrl: 'https://via.placeholder.com/300x200',
      ),
      DriveItem(
        id: '4',
        name: 'Logo Empresa.png',
        type: DriveItemType.image,
        size: '512 KB',
        lastViewed: now.subtract(const Duration(days: 2)),
        thumbnailUrl: 'https://via.placeholder.com/300x200',
      ),
    ];
  }

  List<DriveCategory> _getMockedCategories() {
    return [
      const DriveCategory(
        id: 'cat_1',
        name: 'Documentos',
        type: DriveItemType.document,
        itemCount: 300,
        totalSize: '30.5 MB',
      ),
      const DriveCategory(
        id: 'cat_2',
        name: 'Imagens',
        type: DriveItemType.image,
        itemCount: 300,
        totalSize: '30.5 MB',
      ),
      const DriveCategory(
        id: 'cat_3',
        name: 'Vídeos',
        type: DriveItemType.video,
        itemCount: 300,
        totalSize: '30.5 MB',
      ),
      const DriveCategory(
        id: 'cat_4',
        name: 'Pastas',
        type: DriveItemType.folder,
        itemCount: 300,
        totalSize: '30.5 MB',
      ),
    ];
  }

  DriveItem _getMockedFolderItem() {
    final now = DateTime.now();
    return DriveItem(
      id: '46',
      name: 'Fundamental II',
      type: DriveItemType.folder,
      size: '0 B',
      lastViewed: now,
      parentId: null,
      parentName: null,
      children: [
        DriveItem(
          id: '45',
          name: 'Ativação VPN Opera.mp4',
          type: DriveItemType.video,
          size: '35.6 MB',
          lastViewed: now,
          thumbnailUrl: 'https://via.placeholder.com/300x200',
          parentId: 46,
          parentName: 'Fundamental II',
        ),
      ],
    );
  }
}
