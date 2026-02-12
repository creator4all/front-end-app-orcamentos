import 'package:equatable/equatable.dart';

enum ExperienciaVendasPublicas {
  naoAtuo('nao_atuo', 'Não atuo'),
  atuando('atuando', 'Sim, estou atuando'),
  atueiPassado('atuei_passado', 'Sim, atuei no passado'),
  naoNuncaAtuei('nao_nunca_atuei', 'Não, nunca atuei');

  final String value;
  final String label;

  const ExperienciaVendasPublicas(this.value, this.label);

  static ExperienciaVendasPublicas fromString(String? value) {
    return ExperienciaVendasPublicas.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExperienciaVendasPublicas.naoAtuo,
    );
  }
}

class ProspectEntity extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String empresa;
  final String documento;
  final bool isContatado;
  final ExperienciaVendasPublicas experiencia;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProspectEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.empresa,
    required this.documento,
    required this.isContatado,
    required this.experiencia,
    required this.createdAt,
    required this.updatedAt,
  });

  ProspectEntity copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? empresa,
    String? documento,
    bool? isContatado,
    ExperienciaVendasPublicas? experiencia,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProspectEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      empresa: empresa ?? this.empresa,
      documento: documento ?? this.documento,
      isContatado: isContatado ?? this.isContatado,
      experiencia: experiencia ?? this.experiencia,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get telefoneFormatado {
    final clean = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 11) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7)}';
    } else if (clean.length == 10) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 6)}-${clean.substring(6)}';
    }
    return telefone;
  }

  String get documentoFormatado {
    final clean = documento.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 14) {
      return '${clean.substring(0, 2)}.${clean.substring(2, 5)}.${clean.substring(5, 8)}/${clean.substring(8, 12)}-${clean.substring(12)}';
    } else if (clean.length == 11) {
      return '${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6, 9)}-${clean.substring(9)}';
    }
    return documento;
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        email,
        telefone,
        empresa,
        documento,
        isContatado,
        experiencia,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}

class PaginatedProspects extends Equatable {
  final List<ProspectEntity> prospects;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedProspects({
    required this.prospects,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [prospects, currentPage, perPage, total, lastPage];
}
