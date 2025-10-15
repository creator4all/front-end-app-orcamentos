import 'package:equatable/equatable.dart';

/// Entidade que representa um Parceiro no domínio de negócio
/// Parceiros são empresas para as quais orçamentos podem ser criados
class PartnerEntity extends Equatable {
  final int id;
  final String name;
  final String? cnpj;
  final String? logo;
  final bool isActive;

  const PartnerEntity({
    required this.id,
    required this.name,
    this.cnpj,
    this.logo,
    this.isActive = true,
  });

  /// Verifica se o parceiro pode receber novos orçamentos
  bool canReceiveBudget() => isActive;

  /// Retorna o nome formatado para exibição
  String get displayName => name.trim();

  /// Verifica se o parceiro tem logo configurada
  bool get hasLogo => logo != null && logo!.isNotEmpty;

  /// Verifica se o CNPJ está presente
  bool get hasCnpj => cnpj != null && cnpj!.isNotEmpty;

  @override
  List<Object?> get props => [id, name, cnpj, logo, isActive];

  @override
  bool get stringify => true;

  PartnerEntity copyWith({
    int? id,
    String? name,
    String? cnpj,
    String? logo,
    bool? isActive,
  }) {
    return PartnerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      logo: logo ?? this.logo,
      isActive: isActive ?? this.isActive,
    );
  }
}
