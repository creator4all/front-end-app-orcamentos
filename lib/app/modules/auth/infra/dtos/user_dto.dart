import 'package:copy_with_extension/copy_with_extension.dart';
import '../../domain/entities/user_entity.dart';

part 'user_dto.g.dart';

@CopyWith()
class UserDto {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? createdAt;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }

  factory UserDto.fromEntity(UserEntity entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      createdAt: entity.createdAt?.toIso8601String(),
    );
  }
}
