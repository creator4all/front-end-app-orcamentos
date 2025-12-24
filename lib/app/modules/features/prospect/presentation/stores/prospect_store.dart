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

  /// Carrega a lista inicial de prospects não contactados
  @action
  Future<void> loadProspects() async {
    isLoading = true;
    error = null;
    currentPage = 1;
    prospects.clear();

    print('📋 [ProspectStore] Carregando prospects não contactados...');

    final result = await listProspectsUsecase(page: 1, isContatado: false);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [ProspectStore] Erro: ${failure.message}');
      },
      (paginatedProspects) {
        prospects.addAll(paginatedProspects.prospects);
        currentPage = paginatedProspects.currentPage;
        lastPage = paginatedProspects.lastPage;
        totalProspects = paginatedProspects.total;
        print('✅ [ProspectStore] Carregados ${prospects.length} prospects');
      },
    );

    isLoading = false;
  }

  /// Carrega mais prospects não contactados (scroll infinito)
  @action
  Future<void> loadMoreProspects() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    final nextPage = currentPage + 1;

    print('📋 [ProspectStore] Carregando página $nextPage...');

    final result =
        await listProspectsUsecase(page: nextPage, isContatado: false);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [ProspectStore] Erro: ${failure.message}');
      },
      (paginatedProspects) {
        prospects.addAll(paginatedProspects.prospects);
        currentPage = paginatedProspects.currentPage;
        lastPage = paginatedProspects.lastPage;
        print(
            '✅ [ProspectStore] Carregados mais ${paginatedProspects.prospects.length} prospects');
      },
    );

    isLoadingMore = false;
  }

  /// Carrega a lista inicial de prospects contactados
  @action
  Future<void> loadContactedProspects() async {
    isLoadingContacted = true;
    error = null;
    currentPageContacted = 1;
    contactedProspects.clear();

    print('📋 [ProspectStore] Carregando prospects contactados...');

    final result = await listProspectsUsecase(page: 1, isContatado: true);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [ProspectStore] Erro: ${failure.message}');
      },
      (paginatedProspects) {
        contactedProspects.addAll(paginatedProspects.prospects);
        currentPageContacted = paginatedProspects.currentPage;
        lastPageContacted = paginatedProspects.lastPage;
        totalContactedProspects = paginatedProspects.total;
        print(
            '✅ [ProspectStore] Carregados ${contactedProspects.length} prospects contactados');
      },
    );

    isLoadingContacted = false;
  }

  /// Carrega mais prospects contactados (scroll infinito)
  @action
  Future<void> loadMoreContactedProspects() async {
    if (isLoadingMoreContacted || !hasMoreContacted) return;

    isLoadingMoreContacted = true;
    final nextPage = currentPageContacted + 1;

    print('📋 [ProspectStore] Carregando página $nextPage de contactados...');

    final result =
        await listProspectsUsecase(page: nextPage, isContatado: true);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [ProspectStore] Erro: ${failure.message}');
      },
      (paginatedProspects) {
        contactedProspects.addAll(paginatedProspects.prospects);
        currentPageContacted = paginatedProspects.currentPage;
        lastPageContacted = paginatedProspects.lastPage;
        print(
            '✅ [ProspectStore] Carregados mais ${paginatedProspects.prospects.length} prospects contactados');
      },
    );

    isLoadingMoreContacted = false;
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
