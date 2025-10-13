import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa uma Role (Papel/Permissão) do usuário
/// Esta é uma entidade pura sem dependências externas
class Role extends Equatable {
  final int id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
