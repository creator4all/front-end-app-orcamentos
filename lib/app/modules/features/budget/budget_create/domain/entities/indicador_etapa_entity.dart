import 'package:equatable/equatable.dart';

import 'indice_etapa_entity.dart';

class IndicadorEtapaEntity extends Equatable {
  final int id;
  final bool valor;
  final int produtoId;
  final int indiceEtapaId;
  final IndiceEtapaEntity indiceEtapa;

  const IndicadorEtapaEntity({
    required this.id,
    required this.valor,
    required this.produtoId,
    required this.indiceEtapaId,
    required this.indiceEtapa,
  });

  @override
  List<Object?> get props => [id, valor, produtoId, indiceEtapaId, indiceEtapa];

  @override
  bool get stringify => true;
}
