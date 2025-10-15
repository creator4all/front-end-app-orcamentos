import '../../domain/entities/partner_entity.dart';

/// Interface abstrata para fonte de dados remota de Parceiros
abstract class PartnerRemoteDataSource {
  /// Busca todos os parceiros padrão (standard)
  Future<List<PartnerEntity>> getStandardPartners();

  /// Busca um parceiro específico por ID
  Future<PartnerEntity> getPartnerById(int partnerId);
}
