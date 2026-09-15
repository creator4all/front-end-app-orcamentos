import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/reports/domain/entities/report_budget.dart';
import 'package:multimidiaapp/app/modules/features/reports/domain/entities/report_user.dart';
import 'package:multimidiaapp/app/modules/features/reports/domain/repositories/reports_repository.dart';
import 'package:multimidiaapp/app/modules/features/reports/presentation/stores/report_budget_list_store.dart';
import 'package:multimidiaapp/app/modules/features/reports/presentation/stores/report_filter_store.dart';
import 'package:multimidiaapp/app/modules/features/reports/presentation/stores/report_user_list_store.dart';
import 'package:multimidiaapp/app/shared/core/errors/failures.dart';

typedef _Budgets = Either<Failure, List<ReportBudget>>;

class _Repository implements ReportsRepository {
  Future<_Budgets> Function(DateTime?, DateTime?) budgets =
      (start, end) async => const Right([]);
  final periods = <List<DateTime?>>[];

  @override
  Future<Either<Failure, List<ReportUser>>> getPartnerUsers(int partnerId,
          {DateTime? dataInicio, DateTime? dataFim}) async =>
      const Right([
        ReportUser(
            id: 7,
            nome: 'Maria',
            email: 'm@example.com',
            cargo: 'Vendedor',
            totalVendas: 0,
            aprovados: 0,
            pendentes: 0,
            expirados: 0,
            naoAprovados: 0),
      ]);

  @override
  Future<_Budgets> getPartnerSales(int partnerId,
      {DateTime? dataInicio, DateTime? dataFim}) {
    periods.add([dataInicio, dataFim]);
    return budgets(dataInicio, dataFim);
  }

  @override
  Future<_Budgets> getUserBudgets(int userId,
      {DateTime? dataInicio, DateTime? dataFim, String? status}) {
    periods.add([dataInicio, dataFim]);
    return budgets(dataInicio, dataFim);
  }
}

ReportBudget _budget(int id, String status, double total,
        {bool archived = false, int userId = 7}) =>
    ReportBudget(
      id: id,
      codigo: 'ORC-$id',
      dataOrcamento: DateTime(2026, 9, 1),
      diasRestantes: 0,
      status: status,
      total: total,
      isArchived: archived,
      usuarioId: userId,
    );

void main() {
  test('resumo e detalhe somam o mesmo conjunto incluindo rascunhos e versões',
      () async {
    final repository = _Repository()
      ..budgets = (start, end) async => Right([
            _budget(1, 'aprovado', 100),
            _budget(2, 'rascunho', 20),
            _budget(3, 'pendente', 30),
            _budget(4, 'pendente', 40),
            _budget(5, 'aprovado', 999, archived: true),
            _budget(6, 'aprovado', 9999, userId: 99),
          ]);
    final filter = ReportFilterStore()
      ..setDateRange(DateTime(2026, 9, 1), null);
    final users =
        ReportUserListStore(reportsRepository: repository, filterStore: filter);
    final budgets = ReportBudgetListStore(
        reportsRepository: repository, filterStore: filter);
    await users.loadUsers(3);
    await budgets.loadBudgets(7);
    expect(users.allUsers.single.totalVendas, 190);
    expect(users.allUsers.single.totalOrcamentos, 4);
    expect(users.allUsers.single.rascunhos, 1);
    expect(users.allUsers.single.aprovados, 1);
    expect(budgets.totalValue, users.totalVendasGeral);
    expect(budgets.filteredBudgets, hasLength(4));
    expect(budgets.statusCounts['aprovado'], 1);
    expect(budgets.statusCounts['rascunho'], 1);
    expect(budgets.statusCounts['arquivado'], 1);
    expect(repository.periods, [
      [DateTime(2026, 9, 1), null],
      [DateTime(2026, 9, 1), null]
    ]);

    filter.setSelectedStatuses({'arquivado'});
    expect(budgets.filteredBudgets.map((b) => b.id), [5]);
    expect(budgets.totalValue, 999);
    filter.setSelectedStatuses({'rascunho'});
    expect(budgets.filteredBudgets.map((b) => b.id), [2]);
    filter.clearStatusFilter();
    expect(budgets.totalValue, 190);
  });

  test('erro no resumo fica visível e remove totais antigos', () async {
    final repository = _Repository()
      ..budgets = (start, end) async => Right([_budget(1, 'pendente', 100)]);
    final store = ReportUserListStore(
        reportsRepository: repository, filterStore: ReportFilterStore());
    await store.loadUsers(3);
    expect(store.totalVendasGeral, 100);
    repository.budgets = (start, end) async =>
        const Left(ServerFailure('Falha na segunda página'));
    await store.loadPartnerSales(3);
    expect(store.error, 'Falha na segunda página');
    expect(store.allUsers, isEmpty);
    expect(store.allPartnerBudgets, isEmpty);
    expect(store.totalVendasGeral, 0);
    expect(store.isLoading, isFalse);
  });

  test('resumo publica apenas a carga completa mais recente ao trocar período',
      () async {
    final first = Completer<_Budgets>();
    final second = Completer<_Budgets>();
    final repository = _Repository()
      ..budgets = (start, end) => start == null ? first.future : second.future;
    final filter = ReportFilterStore();
    final store =
        ReportUserListStore(reportsRepository: repository, filterStore: filter);
    final oldLoad = store.loadUsers(3);
    await Future<void>.delayed(Duration.zero);
    expect(store.isLoading, isTrue);
    expect(store.allUsers, isEmpty);
    filter.setDataInicio(DateTime(2026, 9, 1));
    final newLoad = store.refresh();
    await Future<void>.delayed(Duration.zero);
    second.complete(Right([_budget(2, 'rascunho', 20)]));
    await newLoad;
    first.complete(const Left(ServerFailure('erro antigo')));
    await oldLoad;
    expect(store.totalVendasGeral, 20);
    expect(store.error, isNull);
    expect(store.isLoading, isFalse);
  });

  test('detalhamento descarta resposta antiga e limpa dados em falha',
      () async {
    final first = Completer<_Budgets>();
    final second = Completer<_Budgets>();
    final repository = _Repository()
      ..budgets = (start, end) => start == null ? first.future : second.future;
    final filter = ReportFilterStore();
    final store = ReportBudgetListStore(
        reportsRepository: repository, filterStore: filter);
    final oldLoad = store.loadBudgets(7);
    filter.setDataInicio(DateTime(2026, 9, 1));
    final newLoad = store.refresh();
    second.complete(Right([_budget(2, 'rascunho', 20)]));
    await newLoad;
    first.complete(Right([_budget(1, 'pendente', 100)]));
    await oldLoad;
    expect(store.filteredBudgets.map((b) => b.id), [2]);
    repository.budgets =
        (start, end) async => const Left(ServerFailure('Falha'));
    await store.refresh();
    expect(store.allBudgets, isEmpty);
    expect(store.error, 'Falha');
  });

  test(
      'reset remove datas e status; limites isolados são válidos e preservados',
      () {
    final filter = ReportFilterStore();
    expect(filter.hasDateFilter, isFalse);
    expect(filter.selectedStatuses, isEmpty);
    filter.setDataFim(DateTime(2026, 9, 7));
    expect(filter.dateRangeError, isNull);
    expect(filter.shouldPreserveDateFilters, isTrue);
    filter.setDataInicio(DateTime(2026, 9, 8));
    expect(filter.dateRangeError, isNotNull);
    filter.setDataInicio(DateTime(2026, 9, 7, 20));
    expect(filter.dateRangeError, isNull);
    filter.toggleStatus('pendente');
    filter.resetFilters();
    expect(filter.dataInicio, isNull);
    expect(filter.dataFim, isNull);
    expect(filter.selectedStatuses, isEmpty);
  });

  test('intervalo inválido limpa resultado e não consulta repositório',
      () async {
    final repository = _Repository();
    final filter = ReportFilterStore()
      ..setDateRange(DateTime(2026, 9, 8), DateTime(2026, 9, 7));
    final users =
        ReportUserListStore(reportsRepository: repository, filterStore: filter);
    final budgets = ReportBudgetListStore(
        reportsRepository: repository, filterStore: filter);
    await users.loadUsers(3);
    await budgets.loadBudgets(7);
    expect(users.error, filter.dateRangeError);
    expect(budgets.error, filter.dateRangeError);
    expect(users.isLoading, isFalse);
    expect(budgets.isLoading, isFalse);
    expect(repository.periods, isEmpty);
  });
}
