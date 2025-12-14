import 'package:equatable/equatable.dart';

/// Entidade que representa uma Etapa/Indicador (bercario, maternal, in4ano, etc)
class IndiceEtapaEntity extends Equatable {
  final int id;
  final String nome; // bercario, maternal, in4ano, in5ano, ef1ano, etc
  final int grupoId;
  final String grupoNome;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IndiceEtapaEntity({
    required this.id,
    required this.nome,
    required this.grupoId,
    required this.grupoNome,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, nome, grupoId, grupoNome, createdAt, updatedAt];

  @override
  bool get stringify => true;
}
