import '../../domain/entities/prospect_entity.dart';

/// DTO para parsing do JSON da API de prospecção
class ProspectDto {
  final int prpId;
  final String prpNome;
  final String prpEmail;
  final String prpTelefone;
  final String prpEmpresa;
  final String prpDocumento;
  final bool prpIsContatado;
  final String prpExperienciaVendasPublicas;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProspectDto({
    required this.prpId,
    required this.prpNome,
    required this.prpEmail,
    required this.prpTelefone,
    required this.prpEmpresa,
    required this.prpDocumento,
    required this.prpIsContatado,
    required this.prpExperienciaVendasPublicas,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria o DTO a partir do JSON da API
  factory ProspectDto.fromJson(Map<String, dynamic> json) {
    return ProspectDto(
      prpId: json['prp_id'] as int,
      prpNome: json['prp_nome'] as String? ?? '',
      prpEmail: json['prp_email'] as String? ?? '',
      prpTelefone: json['prp_telefone'] as String? ?? '',
      prpEmpresa: json['prp_empresa'] as String? ?? 'Não informado.',
      prpDocumento: json['prp_documento'] as String? ?? 'Não informado.',
      prpIsContatado:
          json['prp_is_contatado'] == true || json['prp_is_contatado'] == 1,
      prpExperienciaVendasPublicas:
          json['prp_experiencia_vendas_publicas'] as String? ?? 'nao_atuo',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte o DTO para a entidade de domínio
  ProspectEntity toEntity() {
    return ProspectEntity(
      id: prpId,
      nome: prpNome,
      email: prpEmail,
      telefone: prpTelefone,
      empresa: prpEmpresa.isEmpty ? 'Não informado.' : prpEmpresa,
      documento: prpDocumento.isEmpty ? 'Não informado.' : prpDocumento,
      isContatado: prpIsContatado,
      experiencia:
          ExperienciaVendasPublicas.fromString(prpExperienciaVendasPublicas),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// DTO para a resposta paginada
class PaginatedProspectsDto {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final List<ProspectDto> data;

  PaginatedProspectsDto({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.data,
  });

  /// Cria o DTO a partir do JSON da API
  factory PaginatedProspectsDto.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'] as Map<String, dynamic>;
    final dataList = (dados['data'] as List<dynamic>?) ?? [];

    return PaginatedProspectsDto(
      currentPage: dados['current_page'] as int? ?? 1,
      perPage: dados['per_page'] as int? ?? 15,
      total: dados['total'] as int? ?? 0,
      lastPage: dados['last_page'] as int? ?? 1,
      data: dataList
          .map((item) => ProspectDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converte para a entidade paginada de domínio
  PaginatedProspects toEntity() {
    return PaginatedProspects(
      currentPage: currentPage,
      perPage: perPage,
      total: total,
      lastPage: lastPage,
      prospects: data.map((dto) => dto.toEntity()).toList(),
    );
  }
}
