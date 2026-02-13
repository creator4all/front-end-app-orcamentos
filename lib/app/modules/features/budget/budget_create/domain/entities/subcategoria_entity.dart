import 'package:equatable/equatable.dart';

import 'categoria_entity.dart';

class SubcategoriaEntity extends Equatable {
  final int id;
  final String nome;
  final int categoriaId;
  final CategoriaEntity categoria;

  const SubcategoriaEntity({
    required this.id,
    required this.nome,
    required this.categoriaId,
    required this.categoria,
  });

  @override
  List<Object?> get props => [id, nome, categoriaId, categoria];

  @override
  bool get stringify => true;
}
