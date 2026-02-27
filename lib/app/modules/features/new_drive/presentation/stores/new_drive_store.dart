import 'package:mobx/mobx.dart';

import '../../domain/entities/drive_category.dart';
import '../../domain/entities/drive_item.dart';
import '../../domain/repositories/drive_repository.dart';
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
  final GetRecentItemsUseCase getRecentItemsUseCase;
  final GetOwnFilesUseCase getOwnFilesUseCase;
  final GetFolderContentsUseCase getFolderContentsUseCase;
  final DriveRepository driveRepository;

  _NewDriveStoreBase({
    required this.getRecentItemsUseCase,
    required this.getOwnFilesUseCase,
    required this.getFolderContentsUseCase,
    required this.driveRepository,
  });

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
  String? viewMode;

  @observable
  ObservableList<DriveItem> ownFiles = ObservableList<DriveItem>();

  @observable
  bool isLoadingOwnFiles = false;

  @observable
  DriveItem? currentFolder;

  @observable
  bool isLoadingFolder = false;

  @observable
  ObservableList<FolderBreadcrumb> folderStack =
      ObservableList<FolderBreadcrumb>();

  @computed
  List<DriveItem> get recentItems {
    final sorted = allItems.where((item) => item.parentId == null).toList()
      ..sort((a, b) => b.lastViewed.compareTo(a.lastViewed));
    return sorted.take(4).toList();
  }

  @computed
  List<DriveItem> get selectedCategoryItems {
    if (selectedCategoryType == null) {
      return [];
    }
    return allItems
        .where(
          (item) => item.type == selectedCategoryType && item.parentId == null,
        )
        .toList();
  }

  @computed
  List<DriveItem> get filteredCategoryItems {
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
    switch (viewMode) {
      case 'category':
        return selectedCategoryItems;
      case 'my-files':
        return ownFiles.toList();
      case 'all-shared':
        return allItems;
      default:
        return [];
    }
  }

  @computed
  List<DriveItem> get filteredViewItems {
    var items = viewItems;

    if (searchQuery.isEmpty) {
      return items;
    }

    final query = searchQuery.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  Future<void> loadRecentItems() async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await getRecentItemsUseCase();

      result.fold((failure) => errorMessage = failure.message, (items) {
        allItems.clear();
        allItems.addAll(items);
      });
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
      final result = await getOwnFilesUseCase();

      result.fold((failure) => errorMessage = failure.message, (items) {
        ownFiles.clear();
        ownFiles.addAll(items);
      });
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
      final result = await getFolderContentsUseCase(folderId);

      result.fold(
        (failure) => errorMessage = failure.message,
        (folderItem) => currentFolder = folderItem,
      );
    } catch (e) {
      errorMessage = 'Erro ao carregar conteúdo da pasta';
    } finally {
      isLoadingFolder = false;
    }
  }

  @action
  Future<void> loadCategories() async {
    categories.clear();

    final rootItems = allItems.where((item) => item.parentId == null);

    final documents =
        rootItems.where((item) => item.type == DriveItemType.document).length;
    final images =
        rootItems.where((item) => item.type == DriveItemType.image).length;
    final videos =
        rootItems.where((item) => item.type == DriveItemType.video).length;
    final folders =
        rootItems.where((item) => item.type == DriveItemType.folder).length;

    final documentsSize = _calculateTotalSize(
      rootItems.where((item) => item.type == DriveItemType.document),
    );
    final imagesSize = _calculateTotalSize(
      rootItems.where((item) => item.type == DriveItemType.image),
    );
    final videosSize = _calculateTotalSize(
      rootItems.where((item) => item.type == DriveItemType.video),
    );
    final foldersSize = _calculateTotalSize(
      rootItems.where((item) => item.type == DriveItemType.folder),
    );

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

  String _calculateTotalSize(Iterable<DriveItem> items) {
    if (items.isEmpty) return '0 MB';

    double totalMB = 0.0;
    for (final item in items) {
      totalMB += _parseSizeToMB(item.size);
    }
    return '${totalMB.toStringAsFixed(1)} MB';
  }

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
    await loadCategories();
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  Future<DriveItem?> getFileDetails(String fileId) async {
    final result = await driveRepository.getFileDetails(fileId);
    return result.fold((failure) {
      errorMessage = failure.message;
      return null;
    }, (item) => item);
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
    searchQuery = '';

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
        currentFolder = null;
      }
    }
  }

  @action
  void navigateToStackIndex(int index) {
    if (index >= 0 && index < folderStack.length) {
      final itemsToRemove = folderStack.length - 1 - index;
      for (var i = 0; i < itemsToRemove; i++) {
        folderStack.removeLast();
      }
      loadFolderContents(folderStack.last.id);
    } else if (index == -1) {
      folderStack.clear();
      currentFolder = null;
    }
  }
}
