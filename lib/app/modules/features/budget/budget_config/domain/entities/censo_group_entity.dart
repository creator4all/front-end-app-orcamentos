import 'package:equatable/equatable.dart';

import 'censo_title_entity.dart';

/// Entidade que representa um grupo do censo escolar
/// Ex: "Infantil", "Ensino Fundamental", "EJA"
class CensoGroupEntity extends Equatable {
  /// ID do grupo
  final int id;

  /// Nome do grupo (ex: "Ensino Fundamental")
  final String nome;

  /// Títulos/etapas dentro deste grupo
  final List<CensoTitleEntity> titulos;

  const CensoGroupEntity({
    required this.id,
    required this.nome,
    required this.titulos,
  });

  /// Valor total somando todos os títulos do grupo
  double get valorTotal {
    return titulos.fold(0.0, (sum, titulo) => sum + titulo.valor);
  }

  /// Quantidade de títulos no grupo
  int get quantidadeTitulos => titulos.length;

  @override
  List<Object?> get props => [id, nome, titulos];

  @override
  String toString() {
    return 'CensoGroupEntity(id: $id, nome: $nome, titulos: $quantidadeTitulos, valor: R\$ $valorTotal)';
  }
}
