import '../../../../../../shared/utils/api_number_parser.dart';
import '../../domain/entities/budget_entity.dart';

/// Data Transfer Object para orçamento (Budget)
///
/// Responsável por parsing JSON da API e conversão para Entity
class BudgetDto {
  final int id;
  final String? nome;
  final int diasValidade;
  final DateTime? dataValidade;
  final String status;
  final bool isArchived;
  final double total;
  final int cidadesCount;
  final bool criadoPorAdmin;
  final int? partnerDestinoId;
  final int? usuarioId;
  final String? usuarioNome;
  final String? empresaRazaoSocial;

  BudgetDto({
    required this.id,
    this.nome,
    required this.diasValidade,
    this.dataValidade,
    required this.status,
    this.isArchived = false,
    required this.total,
    required this.cidadesCount,
    this.criadoPorAdmin = false,
    this.partnerDestinoId,
    this.usuarioId,
    this.usuarioNome,
    this.empresaRazaoSocial,
  });

  /// Factory para criar DTO a partir de JSON da API.
  ///
  /// A API expõe o orçamento em duas representações: o resumo canônico de
  /// `GET /api/orcamentos` (`id`, `nome`, `total`…) e o registro cru de
  /// `GET /api/orcamentos/{id}` (`orc_orcamentoId`, `orc_nome`, `orc_total`…).
  /// Ambas descrevem o mesmo recurso, então este factory aceita as duas.
  factory BudgetDto.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('orc_orcamentoId')) {
      return BudgetDto._fromStoredJson(json);
    }
    return BudgetDto._fromSummaryJson(json);
  }

  factory BudgetDto._fromSummaryJson(Map<String, dynamic> json) {
    final usuarioJson = json['usuario'] as Map<String, dynamic>?;
    final partnerDestinoJson = json['partner_destino'] as Map<String, dynamic>?;
    final cidadesJson = json['cidades'];

    return BudgetDto(
      id: ApiNumberParser.toInt(json['id']),
      nome: json['nome'] as String?,
      diasValidade: ApiNumberParser.toInt(json['dias_validade']),
      dataValidade: _parseDate(json['data_validade']),
      status: json['status'] as String? ?? '',
      isArchived: json['is_archived'] as bool? ?? false,
      total: ApiNumberParser.toDouble(json['total']),
      cidadesCount: cidadesJson is List ? cidadesJson.length : 0,
      criadoPorAdmin: json['criado_por_admin'] as bool? ?? false,
      partnerDestinoId: ApiNumberParser.toIntOrNull(json['partner_destino_id']),
      usuarioId: ApiNumberParser.toIntOrNull(usuarioJson?['id']),
      usuarioNome: usuarioJson?['nome'] as String?,
      empresaRazaoSocial: partnerDestinoJson?['razao_social'] as String?,
    );
  }

  factory BudgetDto._fromStoredJson(Map<String, dynamic> json) {
    final usuarioJson = json['usuario'] as Map<String, dynamic>?;
    final partnerDestinoJson = json['partner_destino'] as Map<String, dynamic>?;

    return BudgetDto(
      id: ApiNumberParser.toInt(json['orc_orcamentoId']),
      nome: json['orc_nome'] as String?,
      diasValidade: ApiNumberParser.toInt(json['orc_dias_validade']),
      dataValidade: _parseDate(json['orc_data_validade']),
      status: json['orc_status'] as String? ?? '',
      isArchived: json['orc_is_archived'] as bool? ?? false,
      total: ApiNumberParser.toDouble(json['orc_total']),
      cidadesCount: json['cidade'] != null ? 1 : 0,
      criadoPorAdmin: json['orc_criado_por_admin'] as bool? ?? false,
      partnerDestinoId:
          ApiNumberParser.toIntOrNull(json['orc_partner_destino_id']),
      usuarioId: ApiNumberParser.toIntOrNull(usuarioJson?['usr_userId']),
      usuarioNome: usuarioJson?['usr_name'] as String?,
      empresaRazaoSocial: partnerDestinoJson?['par_legal_name'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Converte DTO para Entity (camada de domínio)
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      nome: nome,
      diasValidade: diasValidade,
      dataValidade: dataValidade,
      status: status,
      isArchived: isArchived,
      total: total,
      cidadesCount: cidadesCount,
      criadoPorAdmin: criadoPorAdmin,
      partnerDestinoId: partnerDestinoId,
      usuarioId: usuarioId,
      usuarioNome: usuarioNome,
      empresaRazaoSocial: empresaRazaoSocial,
    );
  }

  /// Converte Entity para DTO (para envio à API)
  factory BudgetDto.fromEntity(BudgetEntity entity) {
    return BudgetDto(
      id: entity.id,
      nome: entity.nome,
      diasValidade: entity.diasValidade,
      dataValidade: entity.dataValidade,
      status: entity.status,
      isArchived: entity.isArchived,
      total: entity.total,
      cidadesCount: entity.cidadesCount,
      criadoPorAdmin: entity.criadoPorAdmin,
      partnerDestinoId: entity.partnerDestinoId,
      usuarioId: entity.usuarioId,
      usuarioNome: entity.usuarioNome,
      empresaRazaoSocial: entity.empresaRazaoSocial,
    );
  }

  /// Converte DTO para JSON (para envio à API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dias_validade': diasValidade,
      'data_validade': dataValidade?.toIso8601String(),
      'status': status,
      'is_archived': isArchived,
      'total': total,
      'criado_por_admin': criadoPorAdmin,
      'partner_destino_id': partnerDestinoId,
      'usuario': usuarioId != null
          ? {
              'id': usuarioId,
              'nome': usuarioNome,
            }
          : null,
      'partner_destino': empresaRazaoSocial != null
          ? {'razao_social': empresaRazaoSocial}
          : null,
    };
  }
}

class PaginatedBudgetsDto {
  final List<BudgetDto> budgets;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedBudgetsDto({
    required this.budgets,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginatedBudgetsDto.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'];

    if (dados is List) {
      final budgets = _parseBudgets(dados);
      return PaginatedBudgetsDto(
        budgets: budgets,
        currentPage: 1,
        perPage: budgets.length,
        total: budgets.length,
        lastPage: 1,
      );
    }

    if (dados is! Map || dados['data'] is! List) {
      throw const FormatException(
        'Contrato inválido: "dados" deve ser uma lista ou página',
      );
    }

    return PaginatedBudgetsDto(
      budgets: _parseBudgets(dados['data'] as List),
      currentPage: ApiNumberParser.toInt(dados['current_page']),
      perPage: ApiNumberParser.toInt(dados['per_page']),
      total: ApiNumberParser.toInt(dados['total']),
      lastPage: ApiNumberParser.toInt(dados['last_page']),
    );
  }

  PaginatedBudgets toEntity() {
    return PaginatedBudgets(
      budgets: budgets.map((budget) => budget.toEntity()).toList(),
      currentPage: currentPage,
      perPage: perPage,
      total: total,
      lastPage: lastPage,
    );
  }

  static List<BudgetDto> _parseBudgets(List<dynamic> data) {
    return data.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'Contrato inválido: item de orçamento deve ser um objeto',
        );
      }
      return BudgetDto.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
