import 'package:equatable/equatable.dart';

/// Entidade que representa uma Etapa/Indicador (bercario, maternal, in4ano, etc)
class IndiceEtapaEntity extends Equatable {
  final int id;
  final String nome; // bercario, maternal, in4ano, in5ano, ef1ano, etc
  final String titulo; // Berçário, Maternal, Infantil 4 anos, etc (para exibição)
  final int grupoId;
  final String grupoNome;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IndiceEtapaEntity({
    required this.id,
    required this.nome,
    required this.titulo,
    required this.grupoId,
    required this.grupoNome,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, nome, titulo, grupoId, grupoNome, createdAt, updatedAt];

  @override
  bool get stringify => true;
}
