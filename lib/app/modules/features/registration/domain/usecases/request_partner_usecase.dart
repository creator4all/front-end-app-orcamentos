import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/partner_request.dart';
import '../repositories/registration_repository.dart';

/// Use case para solicitar parceria (prospecção)
class RequestPartnerUseCase {
  final RegistrationRepository repository;

  RequestPartnerUseCase(this.repository);

  /// Executa o envio da solicitação de parceria
  Future<Either<Failure, void>> call(PartnerRequest request) {
    return repository.requestPartner(request);
  }
}
