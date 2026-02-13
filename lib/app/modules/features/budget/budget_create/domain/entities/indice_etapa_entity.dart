import 'package:equatable/equatable.dart';

class IndiceEtapaEntity extends Equatable {
  final int id;
  final String nome;
  final String titulo;
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
