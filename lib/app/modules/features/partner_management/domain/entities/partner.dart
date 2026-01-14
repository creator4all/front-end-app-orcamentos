import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um Parceiro (empresa)
/// Usada na tela de Gestão de Empresas (Admin)
class Partner extends Equatable {
  final int id;
  final String legalName;
  final String tradeName;
  final String email;
  final String? phone;
  final String cnpj;
  final bool status;

  const Partner({
    required this.id,
    required this.legalName,
    required this.tradeName,
    required this.email,
    this.phone,
    required this.cnpj,
    required this.status,
  });

  /// Cria uma cópia do parceiro com valores alterados
  Partner copyWith({
    int? id,
    String? legalName,
    String? tradeName,
    String? email,
    String? phone,
    String? cnpj,
    bool? status,
  }) {
    return Partner(
      id: id ?? this.id,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cnpj: cnpj ?? this.cnpj,
      status: status ?? this.status,
    );
  }

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

/// Entidade que representa a resposta paginada de parceiros
class PaginatedPartners extends Equatable {
  final List<Partner> partners;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedPartners({
    required this.partners,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [partners, currentPage, perPage, total, lastPage];
}
