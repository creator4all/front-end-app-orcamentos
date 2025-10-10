import 'package:mobx/mobx.dart';

part 'drive_store.g.dart';

class DriveStore = _DriveStore with _$DriveStore;

abstract class _DriveStore with Store {
  final bool Function() _isAdmin;

  _DriveStore(this._isAdmin);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  String viewMode = 'shared'; // 'shared' ou 'myfiles'

  @observable
  int selectedTabIndex = 0;

  @computed
  bool get isAdmin => _isAdmin();

  @computed
  bool get canSeeMyFiles => isAdmin;

  @computed
  int get tabCount => isAdmin ? 2 : 1;

  @action
  void setViewMode(String mode) {
    if (mode == 'shared' || mode == 'myfiles') {
      viewMode = mode;
    }
  }

  @action
  void setSelectedTab(int index) {
    selectedTabIndex = index;

    // Atualizar view mode baseado na tab
    if (index == 0) {
      viewMode = 'shared';
    } else if (index == 1 && isAdmin) {
      viewMode = 'myfiles';
    }
  }

  @action
  void setError(String? errorMessage) {
    error = errorMessage;
  }

  @action
  void clearError() {
    error = null;
  }

  @action
  Future<void> initialize() async {
    isLoading = true;
    error = null;

    try {
      // Inicializar com tab de compartilhados
      viewMode = 'shared';
      selectedTabIndex = 0;

      print('✅ DriveStore inicializado');
    } catch (e) {
      error = 'Erro ao inicializar: $e';
      print('❌ Erro: $error');
    } finally {
      isLoading = false;
    }
  }

  @action
  void reset() {
    viewMode = 'shared';
    selectedTabIndex = 0;
    error = null;
  }
}
