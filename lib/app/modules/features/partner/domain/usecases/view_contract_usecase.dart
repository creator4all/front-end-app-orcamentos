import '../repositories/partner_repository.dart';

class ViewContractUseCase {
  final PartnerRepository repository;

  ViewContractUseCase(this.repository);

  Future<List<int>> call(int partnerId) {
    return repository.viewContract(partnerId);
  }
}
