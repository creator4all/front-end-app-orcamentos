import 'package:equatable/equatable.dart';

enum PublicSectorExperience {
  never('nao_atuo'),
  past('atuei_passado'),
  current('atuando');

  final String value;
  const PublicSectorExperience(this.value);

  static PublicSectorExperience fromValue(String value) {
    return PublicSectorExperience.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PublicSectorExperience.never,
    );
  }
}

class PartnerRequest extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String? company;
  final String? cnpj;
  final PublicSectorExperience publicSectorExperience;

  const PartnerRequest({
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    this.cnpj,
    required this.publicSectorExperience,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        company,
        cnpj,
        publicSectorExperience,
      ];

  @override
  bool get stringify => true;
}
