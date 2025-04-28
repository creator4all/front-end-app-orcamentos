class User {
  final String id;
  final String email;
  final String name;
  final String token;
  final String role; // Nova propriedade para o papel do usuário

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    this.role = 'vendedor', // Valor padrão
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? 'vendedor', // Valor padrão se não estiver no JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'role': role,
    };
  }
}
