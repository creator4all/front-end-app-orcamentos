import '../../domain/entities/user_registration.dart';

/// DTO para envio de dados de cadastro de usuário
class UserRegistrationDto {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String cargo;
  final int partnerId;

  const UserRegistrationDto({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.cargo,
    required this.partnerId,
  });

  /// Cria DTO a partir da entidade
  factory UserRegistrationDto.fromEntity(UserRegistration entity) {
    return UserRegistrationDto(
      name: entity.name,
      email: entity.email,
      password: entity.password,
      phone: entity.phone,
      cargo: entity.cargo,
      partnerId: entity.partnerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usr_name': name,
      'usr_email': email,
      'usr_password': password,
      'usr_phone': phone,
      'usr_cargo': cargo,
      'partners_par_partnerId': partnerId,
    };
  }
}

/// Response do cadastro de usuário
class UserRegistrationResponse {
  final String mensagem;
  final int? userId;
  final String? nome;
  final String? email;

  const UserRegistrationResponse({
    required this.mensagem,
    this.userId,
    this.nome,
    this.email,
  });

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'] as Map<String, dynamic>;
    final usuario = dados['usuario'] as Map<String, dynamic>?;
    return UserRegistrationResponse(
      mensagem: dados['mensagem'] ?? '',
      userId: usuario?['id'],
      nome: usuario?['nome'],
      email: usuario?['email'],
    );
  }
}
