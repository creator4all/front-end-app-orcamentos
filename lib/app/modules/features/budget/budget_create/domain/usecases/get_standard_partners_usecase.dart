import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/partner_entity.dart';
import '../repositories/partner_repository.dart';

/// Caso de uso para buscar parceiros padrão (standard)
/// Apenas administradores podem acessar essa lista
class GetStandardPartnersUseCase {
  final PartnerRepository _repository;

  GetStandardPartnersUseCase(this._repository);

  /// Executa o caso de uso
  /// Retorna Either<BudgetFailure, List<PartnerEntity>>
  /// [excludePartnerId] - ID do parceiro a ser excluído da lista (parceiro do usuário logado)
  Future<Either<BudgetFailure, List<PartnerEntity>>> call(
      {int? excludePartnerId}) async {
    try {
      final result = await _repository.getStandardPartners();

      return result.fold(
        (failure) => Left(failure),
        (partners) {
          // Filtra parceiros ativos e exclui o parceiro do usuário logado
          final activePartners = partners.where((partner) {
            if (!partner.canReceiveBudget()) return false;
            // Excluir parceiro do usuário logado
            if (excludePartnerId != null && partner.id == excludePartnerId)
              return false;
            return true;
          }).toList();

          // Ordena alfabeticamente por nome
          activePartners.sort((a, b) => a.name.compareTo(b.name));

          return Right(activePartners);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
