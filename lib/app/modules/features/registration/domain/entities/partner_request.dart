import 'package:equatable/equatable.dart';

/// Enum para experiência em vendas no setor público
enum PublicSectorExperience {
  never('nunca'), // Não, nunca atuei
  past('passado'), // Sim, atuei no passado
  current('atuando'); // Sim, estou atuando

  final String value;
  const PublicSectorExperience(this.value);

  /// Cria enum a partir do valor string da API
  static PublicSectorExperience fromValue(String value) {
    return PublicSectorExperience.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PublicSectorExperience.never,
    );
  }
}

/// Entidade de domínio para solicitação de parceria (prospecção)
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
