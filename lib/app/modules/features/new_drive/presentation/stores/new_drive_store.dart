import 'package:mobx/mobx.dart';

import '../../domain/entities/drive_category.dart';
import '../../domain/entities/drive_item.dart';
import '../../domain/usecases/get_recent_items_usecase.dart';

part 'new_drive_store.g.dart';

class NewDriveStore = _NewDriveStoreBase with _$NewDriveStore;

abstract class _NewDriveStoreBase with Store {
  final GetRecentItemsUseCase? getRecentItemsUseCase;

  _NewDriveStoreBase({
    this.getRecentItemsUseCase,
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

  // Computed

  @computed
  List<DriveItem> get recentItems {
    // Retorna os 4 itens compartilhados mais recentemente
    final sorted = allItems.toList()
      ..sort((a, b) => b.lastViewed.compareTo(a.lastViewed));
    return sorted.take(4).toList();
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
        // Usar UseCase real
        final result = await getRecentItemsUseCase!();

        result.fold(
          (failure) {
            errorMessage = failure.message;
            isLoading = false;
          },
          (items) {
            allItems.clear();
            allItems.addAll(items);
            isLoading = false;
          },
        );
      } else {
        // Fallback para dados mockados
        await Future.delayed(const Duration(milliseconds: 500));
        allItems.clear();
        allItems.addAll(_getMockedRecentItems());
        isLoading = false;
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar itens compartilhados recentemente';
      isLoading = false;
    }
  }

  @action
  Future<void> loadCategories() async {
    // Categorias são fixas, mas as estatísticas vêm dos itens carregados
    categories.clear();

    // Contar itens por tipo
    final documents =
        allItems.where((item) => item.type == DriveItemType.document).length;
    final images =
        allItems.where((item) => item.type == DriveItemType.image).length;
    final videos =
        allItems.where((item) => item.type == DriveItemType.video).length;
    final folders =
        allItems.where((item) => item.type == DriveItemType.folder).length;

    // Calcular tamanho total por categoria
    final documentsSize = _calculateTotalSize(
        allItems.where((item) => item.type == DriveItemType.document));
    final imagesSize = _calculateTotalSize(
        allItems.where((item) => item.type == DriveItemType.image));
    final videosSize = _calculateTotalSize(
        allItems.where((item) => item.type == DriveItemType.video));
    final foldersSize = _calculateTotalSize(
        allItems.where((item) => item.type == DriveItemType.folder));

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

  /// Calcula tamanho total de uma lista de itens
  String _calculateTotalSize(Iterable<DriveItem> items) {
    if (items.isEmpty) return '0 MB';

    // Como o size já vem formatado (ex: "2.5 MB"), precisamos fazer parse
    // Por enquanto, vamos retornar uma estimativa baseada na contagem
    // TODO: Melhorar quando backend fornecer tamanho em bytes
    final count = items.length;
    return '${(count * 10.5).toStringAsFixed(1)} MB';
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
}
