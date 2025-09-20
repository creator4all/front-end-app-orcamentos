import 'package:mobx/mobx.dart';
import '../entities/estado_entity.dart';
import '../entities/cidade_entity.dart';
import '../services/geo_service.dart';

part 'geo_store.g.dart';

class GeoStore = _GeoStore with _$GeoStore;

abstract class _GeoStore with Store {
  final GeoService _service;
  _GeoStore(this._service);

  @observable
  bool isLoadingEstados = false;

  @observable
  bool isLoadingCidades = false;

  @observable
  String? error;

  @observable
  ObservableList<EstadoEntity> estados = ObservableList<EstadoEntity>();

  @observable
  ObservableList<CidadeEntity> cidades = ObservableList<CidadeEntity>();

  @observable
  EstadoEntity? estadoSelecionado;

  @observable
  CidadeEntity? cidadeSelecionada;

  @action
  Future<void> carregarEstados() async {
    try {
      error = null;
      isLoadingEstados = true;
      final list = await _service.listarEstados();
      estados = ObservableList.of(list);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingEstados = false;
    }
  }

  @action
  Future<void> carregarCidades([int? estadoId]) async {
    try {
      error = null;
      isLoadingCidades = true;
      final list = await _service.listarCidades(estadoId: estadoId);
      cidades = ObservableList.of(list);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingCidades = false;
    }
  }

  @action
  Future<void> selecionarEstado(EstadoEntity? estado) async {
    estadoSelecionado = estado;
    cidadeSelecionada = null;
    cidades.clear();
    if (estado != null) {
      await carregarCidades(estado.id);
    }
  }

  @action
  void selecionarCidade(CidadeEntity? c) {
    cidadeSelecionada = c;
  }
}
