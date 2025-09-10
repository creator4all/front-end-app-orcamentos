import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, phone, createdAt];
}
