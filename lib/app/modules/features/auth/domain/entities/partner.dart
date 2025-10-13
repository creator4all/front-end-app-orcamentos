import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um Partner (Parceiro/Empresa)
/// Esta é uma entidade pura sem dependências externas
class Partner extends Equatable {
  final int id;
  final String legalName;
  final String tradeName;
  final String email;
  final String phone;
  final String? logo;
  final String cnpj;
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Partner({
    required this.id,
    required this.legalName,
    required this.tradeName,
    required this.email,
    required this.phone,
    this.logo,
    required this.cnpj,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        legalName,
        tradeName,
        email,
        phone,
        logo,
        cnpj,
        status,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
