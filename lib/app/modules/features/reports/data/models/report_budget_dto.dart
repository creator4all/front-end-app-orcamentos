import '../../domain/entities/report_budget.dart';

/// DTO para conversão de JSON para entidade ReportBudget.
///
/// Responsável por fazer o parsing dos dados vindos da API
/// e converter para a entidade de domínio.
class ReportBudgetDto {
  final int id;
  final String? nome;
  final String codigo;
  final DateTime dataOrcamento;
  final DateTime? dataValidade;
  final int diasRestantes;
  final double total;
  final String status;
  final bool isArchived;
  final int cidadesCount;
  final int usuarioId; // ID do usuário dono do orçamento

  ReportBudgetDto({
    required this.id,
    this.nome,
    required this.codigo,
    required this.dataOrcamento,
    this.dataValidade,
    required this.diasRestantes,
    required this.total,
    required this.status,
    this.isArchived = false,
    this.cidadesCount = 1,
    this.usuarioId = 0,
  });

  /// Cria um DTO a partir do JSON da API.
  factory ReportBudgetDto.fromJson(Map<String, dynamic> json) {
    // Parsear datas
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    // Parsear valores numéricos
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    // Calcular dias restantes se não vier da API
    int diasRestantes =
        parseInt(json['dias_restantes'] ?? json['diasRestantes']);
    final dataValidade =
        parseDate(json['data_validade'] ?? json['dataValidade']);
    if (diasRestantes == 0 && dataValidade != null) {
      final hoje = DateTime.now();
      final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
      diasRestantes = dataValidade.difference(hojeDate).inDays;
      if (diasRestantes < 0) diasRestantes = 0;
    }

    // Gerar código se não vier da API
    String codigo = json['codigo'] ?? json['orc_codigo'] ?? '';
    if (codigo.isEmpty) {
      final id = json['id'] ?? json['orc_id'] ?? 0;
      codigo = 'ORC-${id.toString().padLeft(3, '0')}';
    }

    return ReportBudgetDto(
      id: json['id'] ?? json['orc_id'] ?? json['orc_orcamentoId'] ?? 0,
      nome: json['nome'] ?? json['orc_nome'] ?? json['titulo'],
      codigo: codigo,
      dataOrcamento: parseDate(json['data_orcamento'] ?? json['created_at']) ??
          DateTime.now(),
      dataValidade: dataValidade,
      diasRestantes: diasRestantes,
      total: parseDouble(
          json['total'] ?? json['orc_total'] ?? json['valor_total']),
      status: json['status'] ?? json['orc_status'] ?? 'pendente',
      isArchived: json['is_archived'] ?? json['arquivado'] ?? false,
      cidadesCount:
          parseInt(json['cidades_count'] ?? json['cidadesCount'] ?? 1),
      usuarioId: parseInt(json['orc_usuario_id'] ?? json['usuario_id'] ?? 0),
    );
  }

  /// Converte o DTO para a entidade de domínio.
  ReportBudget toEntity() {
    return ReportBudget(
      id: id,
      nome: nome,
      codigo: codigo,
      dataOrcamento: dataOrcamento,
      dataValidade: dataValidade,
      diasRestantes: diasRestantes,
      total: total,
      status: status,
      isArchived: isArchived,
      cidadesCount: cidadesCount,
      usuarioId: usuarioId,
    );
  }
}
