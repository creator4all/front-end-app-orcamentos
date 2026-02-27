import 'package:equatable/equatable.dart';

import 'indice_etapa_entity.dart';

class CidadeIndiceEtapaEntity extends Equatable {
  final int indiceEtapaId;
  final String nomeEtapa;
  final String tituloEtapa;
  final int grupoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double etapaValor;
  final IndiceEtapaEntity indiceEtapa;

  const CidadeIndiceEtapaEntity({
    required this.indiceEtapaId,
    required this.nomeEtapa,
    required this.tituloEtapa,
    required this.grupoId,
    required this.createdAt,
    required this.updatedAt,
    required this.etapaValor,
    required this.indiceEtapa,
  });

  @override
  List<Object?> get props => [
        indiceEtapaId,
        nomeEtapa,
        tituloEtapa,
        grupoId,
        createdAt,
        updatedAt,
        etapaValor,
        indiceEtapa,
      ];

  @override
  bool get stringify => true;
}
