class UserEntity {
  final String id;
  final String email;
  final String name;
  final String token;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
    };
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name)';
  }
}
