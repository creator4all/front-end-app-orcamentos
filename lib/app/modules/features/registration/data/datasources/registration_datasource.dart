import '../models/company_dto.dart';
import '../models/partner_request_dto.dart';
import '../models/user_registration_dto.dart';

/// Contrato abstrato para o datasource de cadastro/registro
abstract class RegistrationDatasource {
  /// Verifica se existe empresa com o documento informado
  Future<VerifyDocumentResponse> verifyDocument(String documento);

  /// Cadastra um novo usuário
  Future<UserRegistrationResponse> registerUser(UserRegistrationDto dto);

  /// Envia solicitação de parceria
  Future<void> requestPartner(PartnerRequestDto dto);
}
