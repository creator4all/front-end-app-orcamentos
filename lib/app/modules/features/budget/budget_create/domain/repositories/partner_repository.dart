import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/partner_entity.dart';

/// Repositório abstrato para operações com Parceiros
/// Define os contratos que devem ser implementados pela camada de dados
abstract class PartnerRepository {
  /// Busca todos os parceiros padrão (standard)
  /// Retorna Either<BudgetFailure, List<PartnerEntity>>
  Future<Either<BudgetFailure, List<PartnerEntity>>> getStandardPartners();

  /// Busca um parceiro específico por ID
  /// Retorna Either<BudgetFailure, PartnerEntity>
  Future<Either<BudgetFailure, PartnerEntity>> getPartnerById(int partnerId);
}
