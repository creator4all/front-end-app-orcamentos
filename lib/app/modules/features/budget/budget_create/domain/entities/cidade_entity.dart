import 'package:equatable/equatable.dart';

import 'cidade_indice_etapa_entity.dart';

class CidadeEntity extends Equatable {
  final int id;
  final String nome;
  final int estadoId;
  final bool status;
  final bool excluido;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CidadeIndiceEtapaEntity> cidadesHasIndiceEtapa;

  const CidadeEntity({
    required this.id,
    required this.nome,
    required this.estadoId,
    required this.status,
    required this.excluido,
    required this.createdAt,
    required this.updatedAt,
    required this.cidadesHasIndiceEtapa,
  });

  @override
  List<Object?> get props => [
        id,
        nome,
        estadoId,
        status,
        excluido,
        createdAt,
        updatedAt,
        cidadesHasIndiceEtapa,
      ];

  @override
  bool get stringify => true;
}
