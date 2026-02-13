import '../../domain/entities/report_budget.dart';

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
  final int usuarioId;

  ReportBudgetDto({
    required this.id,
    this.nome,
    required this.codigo,
    required this.dataOrcamento,
    this.dataValidade,
    this.diasRestantes = 0,
    required this.total,
    required this.status,
    this.isArchived = false,
    this.cidadesCount = 1,
    this.usuarioId = 0,
  });

  factory ReportBudgetDto.fromOrcamentoJson(Map<String, dynamic> json) {
    final dataValidade = _parseDate(json['data_validade']);
    int diasRestantes = _parseInt(json['dias_validade']);
    if (diasRestantes == 0 && dataValidade != null) {
      diasRestantes = _calcularDiasRestantes(dataValidade);
    }

    final usuario = json['usuario'] as Map<String, dynamic>?;

    return ReportBudgetDto(
      id: json['id'] ?? 0,
      nome: json['nome'],
      codigo: _gerarCodigo(json['id'] ?? 0),
      dataOrcamento: _parseDate(json['data_validade']) ?? DateTime.now(),
      dataValidade: dataValidade,
      diasRestantes: diasRestantes,
      total: _parseDouble(json['total']),
      status: json['status'] ?? 'pendente',
      isArchived: json['is_archived'] ?? false,
      cidadesCount: _parseInt(json['cidades']),
      usuarioId: _parseInt(usuario?['id']),
    );
  }

  factory ReportBudgetDto.fromVendasJson(Map<String, dynamic> json) {
    return ReportBudgetDto(
      id: json['orc_orcamentoId'] ?? 0,
      nome: json['orc_nome'],
      codigo: _gerarCodigo(json['orc_orcamentoId'] ?? 0),
      dataOrcamento: _parseDate(json['created_at']) ?? DateTime.now(),
      total: _parseDouble(json['orc_total']),
      status: json['orc_status'] ?? 'pendente',
      usuarioId: _parseInt(json['orc_usuario_id']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int _calcularDiasRestantes(DateTime dataValidade) {
    final hoje = DateTime.now();
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    final dias = dataValidade.difference(hojeDate).inDays;
    return dias < 0 ? 0 : dias;
  }

  static String _gerarCodigo(dynamic id) {
    return 'ORC-${id.toString().padLeft(3, '0')}';
  }

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
