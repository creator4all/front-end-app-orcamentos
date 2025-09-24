class BudgetSummaryDto {
  final int id;
  final String? nome;
  final int diasValidade;
  final DateTime? dataValidade;
  final String status;
  final double total;
  final int cidadesCount;

  BudgetSummaryDto({
    required this.id,
    required this.nome,
    required this.diasValidade,
    required this.dataValidade,
    required this.status,
    required this.total,
    required this.cidadesCount,
  });

  factory BudgetSummaryDto.fromMap(Map<String, dynamic> map) {
    return BudgetSummaryDto(
      id: (map['id'] ?? 0) is String ? int.tryParse(map['id']) ?? 0 : (map['id'] ?? 0) as int,
      nome: map['nome'] as String?,
      diasValidade: (map['dias_validade'] ?? 0) is String ? int.tryParse(map['dias_validade']) ?? 0 : (map['dias_validade'] ?? 0) as int,
      dataValidade: map['data_validade'] != null && (map['data_validade'] as String).isNotEmpty
          ? DateTime.tryParse(map['data_validade'])
          : null,
      status: (map['status'] ?? '').toString(),
      total: (map['total'] is int) ? (map['total'] as int).toDouble() : (map['total'] as num?)?.toDouble() ?? 0.0,
      cidadesCount: (map['cidades'] ?? 0) is String ? int.tryParse(map['cidades']) ?? 0 : (map['cidades'] ?? 0) as int,
    );
  }
}
