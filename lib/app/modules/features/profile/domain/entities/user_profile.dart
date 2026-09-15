import 'package:equatable/equatable.dart';

/// Não contém lógica de parsing — isso é responsabilidade do Model/DTO.
class UserProfile extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? cargo;
  final String? phone;
  final String? avatar;
  final String? avatarBase64;
  final String? roleName;
  final int? partnerId;
  final String? partnerName;
  final bool status;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.cargo,
    this.phone,
    this.avatar,
    this.avatarBase64,
    this.roleName,
    this.partnerId,
    this.partnerName,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        cargo,
        phone,
        avatar,
        avatarBase64,
        roleName,
        partnerId,
        partnerName,
        status,
      ];

  @override
  bool get stringify => true;
}
