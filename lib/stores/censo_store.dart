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

  @computed
  int get totalEstudantes => censo?.cidadeData?.totalEstudantes ?? 0;

  @computed
  int get quantidadeTurmas => censo?.cidadeData?.quantidadeTurmas ?? 0;

  @computed
  List<CidadeIndice> get indicesEtapa => censo?.cidadeData?.indicesEtapa ?? [];

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
