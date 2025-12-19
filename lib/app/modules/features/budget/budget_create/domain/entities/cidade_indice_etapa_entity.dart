import 'package:equatable/equatable.dart';

import 'indice_etapa_entity.dart';

/// Entidade que representa a relação Cidade-IndiceEtapa com valor
class CidadeIndiceEtapaEntity extends Equatable {
  final int indiceEtapaId;
  final String nomeEtapa;
  final String tituloEtapa; // Título para exibição (Berçário, Maternal, etc)
  final int grupoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double etapaValor; // Valor da etapa para esta cidade
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
