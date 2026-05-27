import 'package:equatable/equatable.dart';

class IndiceEtapaEntity extends Equatable {
  final int id;
  final String nome;
  final String titulo;
  final int grupoId;
  final String grupoNome;
  final double? percentualPopulacao;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IndiceEtapaEntity({
    required this.id,
    required this.nome,
    required this.titulo,
    required this.grupoId,
    required this.grupoNome,
    this.percentualPopulacao,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nome,
        titulo,
        grupoId,
        grupoNome,
        percentualPopulacao,
        createdAt,
        updatedAt
      ];

  @override
  bool get stringify => true;
}
