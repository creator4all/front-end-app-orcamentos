import '../../../../../shared/core/http/app_http_client.dart';
import '../models/company_dto.dart';
import '../models/partner_request_dto.dart';
import '../models/user_registration_dto.dart';
import 'registration_datasource.dart';

/// Implementação do datasource de registro usando API HTTP
class RegistrationApiDatasource implements RegistrationDatasource {
  final AppHttpClient httpClient;

  RegistrationApiDatasource({required this.httpClient});

  @override
  Future<VerifyDocumentResponse> verifyDocument(String documento) async {
    try {
      final response =
          await httpClient.get('/api/partners/verificar-documento/$documento');

      if (response.statusCode == 200) {
        return VerifyDocumentResponse.fromJson(response.body);
      }

      return const VerifyDocumentResponse(existe: false);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserRegistrationResponse> registerUser(UserRegistrationDto dto) async {
    try {
      final response = await httpClient.post(
        '/api/users/cadastro',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserRegistrationResponse.fromJson(response.body);
      }

      throw Exception('Erro ao cadastrar usuário: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> requestPartner(PartnerRequestDto dto) async {
    try {
      final response = await httpClient.post(
        '/api/prospeccao-parceiros/',
        data: dto.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Erro ao enviar solicitação de parceria: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
