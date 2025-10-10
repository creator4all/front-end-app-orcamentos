class FileShare {
  final int id;
  final int itemId;
  final int userId;
  final String userName;
  final String? userEmail;
  final DateTime sharedAt;
  final int? sharedBy;
  final String? sharedByName;

  const FileShare({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.sharedAt,
    this.sharedBy,
    this.sharedByName,
  });

  factory FileShare.fromJson(Map<String, dynamic> json) {
    return FileShare(
      id: json['id'] as int? ?? 0,
      itemId: json['item_id'] as int? ?? json['itemId'] as int? ?? 0,
      userId: json['user_id'] as int? ?? json['userId'] as int? ?? 0,
      userName: json['user_name'] as String? ??
          json['userName'] as String? ??
          json['nome_usuario'] as String? ??
          'Usuário',
      userEmail: json['user_email'] as String? ??
          json['userEmail'] as String? ??
          json['email_usuario'] as String?,
      sharedAt: json['shared_at'] != null
          ? DateTime.parse(json['shared_at'] as String)
          : json['compartilhado_em'] != null
              ? DateTime.parse(json['compartilhado_em'] as String)
              : DateTime.now(),
      sharedBy: json['shared_by'] as int? ??
          json['sharedBy'] as int? ??
          json['compartilhado_por'] as int?,
      sharedByName: json['shared_by_name'] as String? ??
          json['sharedByName'] as String? ??
          json['nome_compartilhou'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'shared_at': sharedAt.toIso8601String(),
      'shared_by': sharedBy,
      'shared_by_name': sharedByName,
    };
  }

  FileShare copyWith({
    int? id,
    int? itemId,
    int? userId,
    String? userName,
    String? userEmail,
    DateTime? sharedAt,
    int? sharedBy,
    String? sharedByName,
  }) {
    return FileShare(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      sharedAt: sharedAt ?? this.sharedAt,
      sharedBy: sharedBy ?? this.sharedBy,
      sharedByName: sharedByName ?? this.sharedByName,
    );
  }

  @override
  String toString() {
    return 'FileShare(id: $id, itemId: $itemId, userId: $userId, userName: $userName, sharedAt: $sharedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileShare &&
        other.id == id &&
        other.itemId == itemId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ itemId.hashCode ^ userId.hashCode;
  }
}
