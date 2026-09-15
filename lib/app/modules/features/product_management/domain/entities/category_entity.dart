import 'package:equatable/equatable.dart';

import '../../../../../shared/domain/value_objects/fractional_order.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String nome;
  final bool status;
  final FractionalOrder ordem;

  const CategoryEntity({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
  });

  @override
  List<Object?> get props => [id, nome, status, ordem];
}
