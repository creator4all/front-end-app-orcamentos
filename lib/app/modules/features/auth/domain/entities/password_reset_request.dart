import 'package:equatable/equatable.dart';

class PasswordResetRequest extends Equatable {
  final String email;
  final DateTime requestedAt;

  const PasswordResetRequest({
    required this.email,
    required this.requestedAt,
  });

  @override
  List<Object?> get props => [email, requestedAt];

  @override
  bool get stringify => true;
}
