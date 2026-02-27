import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String nome;
  final bool status;
  final int ordem;

  const CategoryEntity({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
  });

  @override
  List<Object?> get props => [id, nome, status, ordem];
}
