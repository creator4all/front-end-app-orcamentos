import 'package:equatable/equatable.dart';

/// Entidade que representa uma Categoria de Produto
class CategoriaEntity extends Equatable {
  final int id;
  final String nome;
  final int status;
  final int ordem;

  const CategoriaEntity({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
  });

  @override
  List<Object?> get props => [id, nome, status, ordem];

  @override
  bool get stringify => true;
}
