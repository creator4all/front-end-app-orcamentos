import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa uma Empresa/Parceiro
/// Retornada pela busca de documento (CNPJ)
class Company extends Equatable {
  final int id;
  final String legalName; // Razão social
  final String tradeName; // Nome fantasia
  final String email;
  final String phone;
  final String cnpj;
  final bool status;

  const Company({
    required this.id,
    required this.legalName,
    required this.tradeName,
    required this.email,
    required this.phone,
    required this.cnpj,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        legalName,
        tradeName,
        email,
        phone,
        cnpj,
        status,
      ];

  @override
  bool get stringify => true;
}
