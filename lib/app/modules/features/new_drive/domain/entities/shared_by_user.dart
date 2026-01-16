import 'package:equatable/equatable.dart';

/// Entidade que representa o usuário que compartilhou um item
class SharedByUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl; // base64 ou null

  const SharedByUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}
