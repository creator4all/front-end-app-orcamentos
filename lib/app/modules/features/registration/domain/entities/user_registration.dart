import 'package:equatable/equatable.dart';

/// Entidade de domínio para cadastro de usuário
class UserRegistration extends Equatable {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String cargo;
  final int partnerId;

  const UserRegistration({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.cargo,
    required this.partnerId,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        phone,
        cargo,
        partnerId,
      ];

  @override
  bool get stringify => true;
}
