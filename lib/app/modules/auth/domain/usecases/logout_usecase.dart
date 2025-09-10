import 'package:dartz/dartz.dart';
import '../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
