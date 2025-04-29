class UserEntity {
  final String id;
  final String email;
  final String name;
  final String token;
  final String role; // "manager", "seller", or "admin"

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    this.role = "seller", // Default role is seller
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json["id"] ?? "",
      email: json["email"] ?? "",
      name: json["name"] ?? "",
      token: json["token"] ?? "",
      role: json["role"] ?? "seller",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "token": token,
      "role": role,
    };
  }

  @override
  String toString() {
    return "UserEntity(id: $id, email: $email, name: $name, role: $role)";
  }
  
  // Helper to normalize role values between English and Portuguese
  String get normalizedRole {
    // Map English roles to Portuguese
    if (role == "seller") return "vendedor";
    if (role == "manager") return "gestor";
    if (role == "admin") return "administrador";
    return role; // Return original if no mapping exists
  }
}
