import 'package:equatable/equatable.dart';

import 'indicador_etapa_entity.dart';
import 'subcategoria_entity.dart';

class ProdutoEntity extends Equatable {
  final int id;
  final bool status;
  final double valor;
  final int subcategoriaId;
  final String solucao;
  final String indicacao;
  final List<IndicadorEtapaEntity> indicadores;
  final SubcategoriaEntity subcategoria;

  const ProdutoEntity({
    required this.id,
    required this.status,
    required this.valor,
    required this.subcategoriaId,
    required this.solucao,
    required this.indicacao,
    required this.indicadores,
    required this.subcategoria,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        valor,
        subcategoriaId,
        solucao,
        indicacao,
        indicadores,
        subcategoria,
      ];

  @override
  bool get stringify => true;
}
