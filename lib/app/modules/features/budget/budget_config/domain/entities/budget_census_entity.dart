import 'package:equatable/equatable.dart';

import 'censo_escolar_entity.dart';

class BudgetCensusEntity extends Equatable {
  final int orcamentoId;
  final bool multiCidade;
  final List<CensoEscolarEntity> cidades;
  final Map<String, double> censoAgregado;

  const BudgetCensusEntity({
    required this.orcamentoId,
    required this.multiCidade,
    required this.cidades,
    required this.censoAgregado,
  });

  @override
  List<Object?> get props => [orcamentoId, multiCidade, cidades, censoAgregado];
}
