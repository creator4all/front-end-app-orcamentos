import 'package:equatable/equatable.dart';

class SharedByUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  const SharedByUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}
