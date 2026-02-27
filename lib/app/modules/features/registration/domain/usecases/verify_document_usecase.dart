import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/company.dart';
import '../repositories/registration_repository.dart';

class VerifyDocumentUseCase {
  final RegistrationRepository repository;

  VerifyDocumentUseCase(this.repository);

  Future<Either<Failure, Company>> call(String documento) {
    final cleanDocumento = documento.replaceAll(RegExp(r'[^0-9]'), '');
    return repository.verifyDocument(cleanDocumento);
  }
}
