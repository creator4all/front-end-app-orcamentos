import '../../../../../shared/core/http/app_http_client.dart';
import '../../../../../shared/core/http/http_request_config.dart';
import '../models/managed_user_dto.dart';
import '../models/user_update_dto.dart';
import 'user_management_datasource.dart';

class UserManagementApiDatasource implements UserManagementDatasource {
  final AppHttpClient httpClient;

  UserManagementApiDatasource({required this.httpClient});

  @override
  Future<PaginatedUsersDto> listUsers({
    required int page,
    required int perPage,
  }) async {
    final response = await httpClient.get(
      '/api/parceiro/usuarios',
      config: HttpRequestConfig(
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );

    if (response.statusCode == 200) {
      return PaginatedUsersDto.fromJson(response.body);
    }

    throw Exception('Erro ao listar usuários: ${response.statusCode}');
  }

  @override
  Future<PaginatedUsersDto> listPartnerUsers({
    required int partnerId,
    required int page,
    required int perPage,
  }) async {
    final response = await httpClient.get(
      '/api/partners/$partnerId/usuarios',
      config: HttpRequestConfig(
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );

    if (response.statusCode == 200) {
      return PaginatedUsersDto.fromJson(response.body);
    }

    throw Exception(
        'Erro ao listar usuários do parceiro: ${response.statusCode}');
  }

  @override
  Future<UpdateUsersResponseDto> updateUsers(
      List<UserUpdateDto> updates) async {
    final payload = {
      'usuarios': updates.map((u) => u.toJson()).toList(),
    };

    final response = await httpClient.patch(
      '/api/parceiro/usuarios',
      data: payload,
    );

    if (response.statusCode == 200) {
      return UpdateUsersResponseDto.fromJson(response.body);
    }

    throw Exception('Erro ao atualizar usuários: ${response.statusCode}');
  }
}
