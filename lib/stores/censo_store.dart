import 'package:mobx/mobx.dart';
import '../entities/censo_entity.dart';
import '../services/censo_service.dart';

part 'censo_store.g.dart';

class CensoStore = _CensoStore with _$CensoStore;

abstract class _CensoStore with Store {
  final CensoService _service;
  _CensoStore(this._service);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  CensoData? censo;

  @action
  Future<void> carregarGruposCenso() async {
    try {
      error = null;
      isLoading = true;
      censo = await _service.listarGruposCenso();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> carregarCensoPorCidade(int cidadeId) async {
    try {
      error = null;
      isLoading = true;
      censo = await _service.censoPorCidade(cidadeId);
    } catch (_) {
      await carregarGruposCenso();
    } finally {
      isLoading = false;
    }
  }
}
