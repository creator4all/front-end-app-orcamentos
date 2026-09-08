import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/reports/data/models/report_budget_dto.dart';

void main() {
  test(
      'usa criação, conta cidades e calcula dias pela validade, não pelo prazo original',
      () {
    final now = DateTime.now();
    final target =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 3));
    final dto = ReportBudgetDto.fromOrcamentoJson({
      'id': 17,
      'created_at': '2026-01-02T10:00:00',
      'data_validade': target.toIso8601String(),
      'dias_validade': 60,
      'cidades': [
        {'id': 1},
        {'id': 2}
      ],
      'is_archived': true,
      'status': 'rascunho',
      'usuario': {'id': 7},
      'total': '123.45',
    });
    expect(dto.dataOrcamento, DateTime(2026, 1, 2, 10));
    expect(dto.diasRestantes, 3);
    expect(dto.cidadesCount, 2);
    expect(dto.isArchived, isTrue);
    expect(dto.toEntity().status, 'rascunho');
    expect(dto.toEntity().total, 123.45);
    expect(dto.toEntity().usuarioId, 7);
  });

  test('validade vencida resulta em zero, criação ausente permanece ausente',
      () {
    final dto = ReportBudgetDto.fromOrcamentoJson(
        {'data_validade': '2000-01-01', 'dias_validade': 30});
    expect(dto.diasRestantes, 0);
    expect(dto.dataOrcamento, isNull);
    expect(dto.cidadesCount, 0);
  });
}
