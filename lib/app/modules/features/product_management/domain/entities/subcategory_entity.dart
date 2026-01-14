import 'package:equatable/equatable.dart';

/// Entidade que representa uma subcategoria de produtos
class SubcategoryEntity extends Equatable {
  final int id;
  final String nome;
  final bool status;
  final int ordem;
  final int categoriaId;

  const SubcategoryEntity({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
    required this.categoriaId,
  });

  @override
  List<Object?> get props => [id, nome, status, ordem, categoriaId];
}
