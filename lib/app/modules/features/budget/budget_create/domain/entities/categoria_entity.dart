import 'package:equatable/equatable.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

class CategoriaEntity extends Equatable {
  final int id;
  final String nome;
  final int status;
  final FractionalOrder ordem;

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
