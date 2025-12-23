import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/company.dart';
import '../entities/partner_request.dart';
import '../entities/user_registration.dart';

/// Contrato abstrato para operações de cadastro/registro
abstract class RegistrationRepository {
  /// Verifica se existe empresa com o documento (CNPJ) informado
  /// Retorna [Company] se existir e estiver ativa
  Future<Either<Failure, Company>> verifyDocument(String documento);

  /// Cadastra um novo usuário vinculado a uma empresa
  Future<Either<Failure, void>> registerUser(UserRegistration registration);

  /// Envia solicitação de parceria (prospecção)
  Future<Either<Failure, void>> requestPartner(PartnerRequest request);
}
