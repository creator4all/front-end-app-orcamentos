import 'package:mobx/mobx.dart';

import '../../domain/entities/prospect_entity.dart';
import '../../domain/usecases/list_prospects_usecase.dart';
import '../../domain/usecases/mark_contacted_usecase.dart';

part 'prospect_store.g.dart';

/// Store MobX para gerenciamento de estado da tela de prospecção
class ProspectStore = _ProspectStoreBase with _$ProspectStore;

abstract class _ProspectStoreBase with Store {
  final ListProspectsUsecase listProspectsUsecase;
  final MarkContactedUsecase markContactedUsecase;

  _ProspectStoreBase({
    required this.listProspectsUsecase,
    required this.markContactedUsecase,
  });

  // ========== OBSERVABLES ==========

  /// Lista de prospects carregados (não contactados)
  @observable
  ObservableList<ProspectEntity> prospects = ObservableList<ProspectEntity>();

  /// Lista de prospects contactados
  @observable
  ObservableList<ProspectEntity> contactedProspects =
      ObservableList<ProspectEntity>();

  /// Estado de carregamento inicial (não contactados)
  @observable
  bool isLoading = false;

  /// Estado de carregamento inicial (contactados)
  @observable
  bool isLoadingContacted = false;

  /// Estado de carregamento de mais itens (scroll infinito)
  @observable
  bool isLoadingMore = false;

  /// Estado de carregamento de mais itens contactados
  @observable
  bool isLoadingMoreContacted = false;

  /// Estado de marcação como contactado
  @observable
  bool isMarkingContacted = false;

  /// ID do prospect sendo marcado como contactado
  @observable
  int? markingContactedId;

  /// Mensagem de erro
  @observable
  String? error;

  /// Página atual (não contactados)
  @observable
  int currentPage = 1;

  /// Última página (não contactados)
  @observable
  int lastPage = 1;

  /// Página atual (contactados)
  @observable
  int currentPageContacted = 1;

  /// Última página (contactados)
  @observable
  int lastPageContacted = 1;

  /// Total de prospects não contactados
  @observable
  int totalProspects = 0;

  /// Total de prospects contactados
  @observable
  int totalContactedProspects = 0;

  // ========== COMPUTED ==========

  /// Verifica se há mais páginas de não contactados
  @computed
  bool get hasMore => currentPage < lastPage;

  /// Verifica se há mais páginas de contactados
  @computed
  bool get hasMoreContacted => currentPageContacted < lastPageContacted;

  // ========== ACTIONS ==========

  /// Função interna que centraliza a lógica de carregamento de prospects.
  /// Elimina duplicação entre load inicial e paginação para ambas as listas.
  Future<void> _loadProspectsInternal({
    required bool isContacted,
    required bool isLoadMore,
  }) async {
    // Seleciona variáveis baseado em isContacted
    final targetList = isContacted ? contactedProspects : prospects;
    final currentPageValue = isContacted ? currentPageContacted : currentPage;

    // Define página
    final page = isLoadMore ? currentPageValue + 1 : 1;

    // Controla loading states
    if (isLoadMore) {
      if (isContacted) {
        isLoadingMoreContacted = true;
      } else {
        isLoadingMore = true;
      }
    } else {
      if (isContacted) {
        isLoadingContacted = true;
      } else {
        isLoading = true;
      }
      error = null;
      targetList.clear();
    }

    final result =
        await listProspectsUsecase(page: page, isContatado: isContacted);

    result.fold(
      (failure) {
        error = failure.message;
      },
      (paginatedProspects) {
        targetList.addAll(paginatedProspects.prospects);
        if (isContacted) {
          currentPageContacted = paginatedProspects.currentPage;
          lastPageContacted = paginatedProspects.lastPage;
          if (!isLoadMore) totalContactedProspects = paginatedProspects.total;
        } else {
          currentPage = paginatedProspects.currentPage;
          lastPage = paginatedProspects.lastPage;
          if (!isLoadMore) totalProspects = paginatedProspects.total;
        }
      },
    );

    // Reset loading states
    if (isLoadMore) {
      if (isContacted) {
        isLoadingMoreContacted = false;
      } else {
        isLoadingMore = false;
      }
    } else {
      if (isContacted) {
        isLoadingContacted = false;
      } else {
        isLoading = false;
      }
    }
  }

  /// Carrega a lista inicial de prospects não contactados
  @action
  Future<void> loadProspects() async {
    await _loadProspectsInternal(isContacted: false, isLoadMore: false);
  }

  /// Carrega mais prospects não contactados (scroll infinito)
  @action
  Future<void> loadMoreProspects() async {
    if (isLoadingMore || !hasMore) return;
    await _loadProspectsInternal(isContacted: false, isLoadMore: true);
  }

  /// Carrega a lista inicial de prospects contactados
  @action
  Future<void> loadContactedProspects() async {
    await _loadProspectsInternal(isContacted: true, isLoadMore: false);
  }

  /// Carrega mais prospects contactados (scroll infinito)
  @action
  Future<void> loadMoreContactedProspects() async {
    if (isLoadingMoreContacted || !hasMoreContacted) return;
    await _loadProspectsInternal(isContacted: true, isLoadMore: true);
  }

  /// Marca um prospect como contactado
  @action
  Future<bool> markAsContacted(int prospectId) async {
    isMarkingContacted = true;
    markingContactedId = prospectId;
    error = null;

    print(
        '📝 [ProspectStore] Marcando prospect $prospectId como contactado...');

    final result = await markContactedUsecase(prospectId);

    bool success = false;

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [ProspectStore] Erro: ${failure.message}');
      },
      (updatedProspect) {
        // Remove da lista de não contactados
        prospects.removeWhere((p) => p.id == prospectId);
        totalProspects--;

        // Adiciona no início da lista de contactados (se já foi carregada)
        if (contactedProspects.isNotEmpty || totalContactedProspects > 0) {
          contactedProspects.insert(0, updatedProspect);
          totalContactedProspects++;
        }

        success = true;
        print('✅ [ProspectStore] Prospect marcado como contactado com sucesso');
      },
    );

    isMarkingContacted = false;
    markingContactedId = null;
    return success;
  }

  /// Limpa os erros
  @action
  void clearError() {
    error = null;
  }
}
