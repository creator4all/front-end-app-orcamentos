import 'package:equatable/equatable.dart';

class IndicatorEntity extends Equatable {
  final int id;
  final String nome;
  final String titulo;

  const IndicatorEntity({
    required this.id,
    required this.nome,
    required this.titulo,
  });

  @override
  List<Object?> get props => [id, nome, titulo];
}

class IndicatorGroupEntity extends Equatable {
  final int id;
  final String nome;
  final List<IndicatorEntity> indicadores;

  const IndicatorGroupEntity({
    required this.id,
    required this.nome,
    required this.indicadores,
  });

  @override
  List<Object?> get props => [id, nome, indicadores];
}
