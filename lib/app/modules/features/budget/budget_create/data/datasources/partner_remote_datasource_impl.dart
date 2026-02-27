import '../../../../../../../app/shared/core/http/app_http_client.dart';
import '../../domain/entities/partner_entity.dart';
import '../models/partner_dto.dart';
import 'partner_remote_datasource.dart';

class PartnerRemoteDataSourceImpl implements PartnerRemoteDataSource {
  final AppHttpClient client;

  PartnerRemoteDataSourceImpl(this.client);

  @override
  Future<List<PartnerEntity>> getStandardPartners() async {
    try {
      const url = '/api/partners/parceiros-standard';
      final response = await client.get(url);

      final list = response.body['dados'] as List? ?? [];

      return PartnerDto.listFromJson(list);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PartnerEntity> getPartnerById(int partnerId) async {
    try {
      final url = '/api/partners/$partnerId';
      final response = await client.get(url);

      final data = response.body['dados'];

      if (data == null) {
        throw Exception('Parceiro não encontrado');
      }

      final dto = PartnerDto.fromJson(Map<String, dynamic>.from(data as Map));
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
